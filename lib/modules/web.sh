#!/usr/bin/env bash
# Kraken module: web enumeration (headers, directories, technologies, robots).

if [[ -n "${KRAKEN_MODULE_WEB_LOADED:-}" ]]; then
    return 0
fi
KRAKEN_MODULE_WEB_LOADED=1

# Common paths probed during directory enumeration.
KRAKEN_WEB_PATHS=(
    "admin" "administrator" "login" "dashboard" "panel"
    "backup" "backups" "config" "api" "test" "dev"
    "phpinfo.php" "info.php" ".git" ".env"
)

_kraken_web_curl_status() {
    local url="$1"
    curl -s -o /dev/null -w "%{http_code}" --max-time 5 "${url}" 2>/dev/null
}

_kraken_web_test_connectivity() {
    local url="$1"
    if ! command_exists curl; then
        return
    fi
    log_step "Testing web server connectivity..."
    local status
    status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "${url}" 2>/dev/null)
    if [[ "${status}" =~ ^[23] ]]; then
        log_success "Server responded with HTTP ${status}"
    else
        log_warn "Server responded with HTTP ${status}"
    fi
}

_kraken_web_headers() {
    local url="$1"
    local out_file="$2"
    if ! command_exists curl; then
        return
    fi
    log_step "Fetching HTTP headers..."
    curl -s -I --max-time 10 "${url}" > "${out_file}" 2>/dev/null || true
    log_success "Headers saved"
    echo
    printf '%s═══ Server Headers ═══%s\n' "${BRIGHT_MAGENTA}" "${RESET}"
    head -10 "${out_file}" | while IFS= read -r line; do
        printf '  %s%s%s\n' "${DIM}" "${line}" "${RESET}"
    done
}

# Number of concurrent probes during directory enumeration.
KRAKEN_WEB_JOBS="${KRAKEN_WEB_JOBS:-8}"

# Probe one path, emitting a "STATUS<TAB>path" line for interesting codes.
_kraken_web_probe_path() {
    local url="$1" dir="$2"
    local status
    status=$(_kraken_web_curl_status "${url}/${dir}")
    case "${status}" in
        200|401|403) printf '%s\t%s\n' "${status}" "${dir}" ;;
    esac
}

_kraken_web_directories() {
    local url="$1"
    local out_file="$2"
    if ! command_exists curl; then
        return
    fi
    log_step "Testing common directories (parallel, ${KRAKEN_WEB_JOBS} jobs)..."
    {
        echo "# Directory Scan - $(date)"
        echo "# Target: ${url}"
        echo
    } > "${out_file}"

    echo
    printf '%s═══ Directory Enumeration ═══%s\n' "${BRIGHT_MAGENTA}" "${RESET}"

    # Fan out probes as bounded background jobs, collect raw results, sort
    # them for deterministic output, then render and persist.
    local raw dir
    raw=$(
        for dir in "${KRAKEN_WEB_PATHS[@]}"; do
            while (( $(jobs -rp | wc -l) >= KRAKEN_WEB_JOBS )); do
                wait -n 2>/dev/null || break
            done
            _kraken_web_probe_path "${url}" "${dir}" &
        done
        wait
    )

    [[ -z "${raw}" ]] && return
    local status path
    while IFS=$'\t' read -r status path; do
        [[ -n "${status}" ]] || continue
        case "${status}" in
            200)
                printf '  %s[+] /%s%s (HTTP %s)\n' "${BRIGHT_GREEN}" "${path}" "${RESET}" "${status}"
                echo "FOUND: /${path} (HTTP ${status})" >> "${out_file}"
                ;;
            403)
                printf '  %s[!] /%s%s (HTTP %s - Forbidden)\n' "${BRIGHT_YELLOW}" "${path}" "${RESET}" "${status}"
                echo "FORBIDDEN: /${path} (HTTP ${status})" >> "${out_file}"
                ;;
            401)
                printf '  %s[!] /%s%s (HTTP %s - Auth Required)\n' "${BRIGHT_YELLOW}" "${path}" "${RESET}" "${status}"
                echo "AUTH: /${path} (HTTP ${status})" >> "${out_file}"
                ;;
        esac
    done < <(printf '%s\n' "${raw}" | sort)
}

_kraken_web_technologies() {
    local url="$1"
    local headers_file="$2"
    local out_file="$3"
    if ! command_exists curl; then
        return
    fi
    log_step "Detecting web technologies..."
    local content
    content=$(curl -s --max-time 10 "${url}" 2>/dev/null || true)
    {
        echo
        echo "# Technology Detection"
        echo
        if echo "${content}" | grep -qi "wordpress"; then echo "- WordPress detected"; fi
        if echo "${content}" | grep -qi "drupal";    then echo "- Drupal detected";    fi
        if echo "${content}" | grep -qi "joomla";    then echo "- Joomla detected";    fi
        grep -i "server:"        "${headers_file}" 2>/dev/null || true
        grep -i "x-powered-by:"  "${headers_file}" 2>/dev/null || true
    } >> "${out_file}"
}

_kraken_web_robots() {
    local url="$1"
    local out_file="$2"
    if ! command_exists curl; then
        return
    fi
    log_step "Checking robots.txt..."
    if curl -s --max-time 5 "${url}/robots.txt" > "${out_file}" 2>/dev/null && [[ -s "${out_file}" ]]; then
        log_success "robots.txt found"
    fi
}

# Entry point for the web enumeration module.
kraken_web_run() {
    kraken_clear_screen
    log_step "Launching web enumeration module..."
    echo

    local url
    url=$(prompt_value "Enter target URL (e.g., http://example.com)")
    if [[ -z "${url}" ]]; then
        log_error "No URL specified"
        press_enter_to_continue
        return
    fi

    if [[ ! "${url}" =~ ^https?:// ]]; then
        url="http://${url}"
        log_info "Assuming http:// protocol"
    fi

    local host
    host="${url#*://}"; host="${host%%/*}"
    if ! kraken_valid_target "${host}"; then
        log_error "Invalid URL host: ${host}"
        press_enter_to_continue
        return
    fi

    local slug
    slug=$(echo "${url}" | sed 's|https\?://||' | tr '/:' '_')
    local web_dir="${KRAKEN_OUTPUT_DIR}/web_${slug}"
    mkdir -p "${web_dir}"
    log_success "Output directory: ${web_dir}"

    _kraken_web_test_connectivity "${url}"
    _kraken_web_headers           "${url}" "${web_dir}/headers.txt"
    _kraken_web_directories       "${url}" "${web_dir}/directories.txt"
    _kraken_web_technologies      "${url}" "${web_dir}/headers.txt" "${web_dir}/technologies.txt"
    _kraken_web_robots            "${url}" "${web_dir}/robots.txt"

    echo
    kraken_print_separator "─"
    log_success "Web enumeration complete!"
    printf '%sResults saved in:%s %s\n\n' "${BRIGHT_BLUE}" "${RESET}" "${web_dir}"
    press_enter_to_continue
}
