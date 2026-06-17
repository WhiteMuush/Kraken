#!/usr/bin/env bash
# Kraken module: lightweight vulnerability assessment (SSL, headers, methods).

if [[ -n "${KRAKEN_MODULE_VULN_LOADED:-}" ]]; then
    return 0
fi
KRAKEN_MODULE_VULN_LOADED=1

_kraken_vuln_ssl() {
    local target="$1"
    local out_file="$2"
    if ! command_exists openssl; then
        return
    fi
    log_step "Testing SSL/TLS configuration..."
    if echo | openssl s_client -connect "${target}:443" -servername "${target}" 2>/dev/null \
        | openssl x509 -noout -text > "${out_file}" 2>/dev/null; then
        log_success "SSL certificate analyzed"
    else
        log_warn "Could not retrieve SSL certificate"
    fi
}

_kraken_vuln_http_methods() {
    local target="$1"
    local findings_file="$2"
    if ! command_exists curl; then
        return
    fi
    log_step "Testing HTTP methods..."
    local methods
    methods=$(curl -s -X OPTIONS -I "http://${target}" 2>/dev/null | grep -i "allow:")
    if [[ -n "${methods}" ]]; then
        printf '  %s[!]%s Allowed HTTP methods: %s\n' "${BRIGHT_YELLOW}" "${RESET}" "${methods}"
        echo "HTTP_METHODS: ${methods}" >> "${findings_file}"
    fi
}

_kraken_vuln_security_headers() {
    local target="$1"
    local findings_file="$2"
    if ! command_exists curl; then
        return
    fi
    log_step "Checking security headers..."
    local headers
    headers=$(curl -s -I "http://${target}" 2>/dev/null || true)

    local h
    for h in "x-frame-options" "content-security-policy" "strict-transport-security"; do
        if ! echo "${headers}" | grep -qi "${h}"; then
            printf '  %s[x]%s Missing: %s\n' "${BRIGHT_RED}" "${RESET}" "${h}"
            echo "MISSING_HEADER: ${h}" >> "${findings_file}"
        fi
    done

    if echo "${headers}" | grep -qi "server:"; then
        local server
        server=$(echo "${headers}" | grep -i "server:" | head -1)
        printf '  %s[!]%s Server banner exposed: %s\n' "${BRIGHT_YELLOW}" "${RESET}" "${server}"
        echo "INFO_DISCLOSURE: ${server}" >> "${findings_file}"
    fi
}

# Entry point for the vulnerability assessment module.
kraken_vuln_run() {
    kraken_clear_screen
    log_step "Launching vulnerability assessment..."
    echo

    local target
    target=$(prompt_value "Enter target (IP/domain)")
    if ! kraken_valid_target "${target}"; then
        log_error "Invalid or empty target"
        press_enter_to_continue
        return
    fi

    local vuln_dir="${KRAKEN_OUTPUT_DIR}/vuln_${target}"
    mkdir -p "${vuln_dir}"
    log_success "Output directory: ${vuln_dir}"

    local findings_file="${vuln_dir}/findings.txt"
    {
        echo "# Vulnerability Assessment - $(date)"
        echo "# Target: ${target}"
        echo
    } > "${findings_file}"

    _kraken_vuln_ssl              "${target}" "${vuln_dir}/ssl_cert.txt"
    log_step "Checking common misconfigurations..."
    printf '%s═══ Basic Security Checks ═══%s\n' "${BRIGHT_MAGENTA}" "${RESET}"
    _kraken_vuln_http_methods     "${target}" "${findings_file}"
    _kraken_vuln_security_headers "${target}" "${findings_file}"

    echo
    kraken_print_separator "─"
    log_success "Vulnerability assessment complete!"
    printf '%sResults saved in:%s %s\n\n' "${BRIGHT_BLUE}" "${RESET}" "${vuln_dir}"
    printf '%sNote: This is a basic assessment. Use specialized tools for in-depth testing.%s\n\n' \
        "${DIM}" "${RESET}"
    press_enter_to_continue
}
