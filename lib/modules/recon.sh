#!/usr/bin/env bash
# Kraken module: reconnaissance (DNS, subdomains, WHOIS, reverse DNS).

if [[ -n "${KRAKEN_MODULE_RECON_LOADED:-}" ]]; then
    return 0
fi
KRAKEN_MODULE_RECON_LOADED=1

# Query a single record type with dig, printing a header and a fallback
# line when nothing is returned.
_kraken_recon_dig_record() {
    local target="$1" rtype="$2"
    echo "=== ${rtype} Records ==="
    local answer
    answer=$(dig +short "${rtype}" "${target}" 2>/dev/null)
    if [[ -n "${answer}" ]]; then
        printf '%s\n' "${answer}"
    else
        echo "No ${rtype} records found"
    fi
    echo
}

_kraken_recon_dns_records() {
    local target="$1"
    local out_file="$2"
    {
        echo "# DNS Records for ${target} - $(date)"
        echo
        if command_exists dig; then
            local rtype
            for rtype in A AAAA MX NS TXT CNAME; do
                _kraken_recon_dig_record "${target}" "${rtype}"
            done
        elif command_exists host; then
            echo "=== A Records ==="
            host -t A "${target}" 2>/dev/null | grep "has address" || echo "No A records found"
            echo
            echo "=== AAAA Records ==="
            host -t AAAA "${target}" 2>/dev/null | grep "IPv6 address" || echo "No AAAA records"
            echo
            echo "=== MX Records ==="
            host -t MX "${target}" 2>/dev/null | grep "mail is handled" || echo "No MX records"
            echo
            echo "=== NS Records ==="
            host -t NS "${target}" 2>/dev/null | grep "name server" || echo "No NS records"
            echo
            echo "=== TXT Records ==="
            host -t TXT "${target}" 2>/dev/null | grep "descriptive text" || echo "No TXT records"
            echo
            echo "=== CNAME Records ==="
            host -t CNAME "${target}" 2>/dev/null | grep "alias" || echo "No CNAME records"
        elif command_exists nslookup; then
            echo "=== DNS Info (nslookup) ==="
            nslookup "${target}" 2>/dev/null || echo "nslookup failed"
        else
            echo "=== Basic Resolution ==="
            getent hosts "${target}" 2>/dev/null || echo "Could not resolve ${target}"
        fi
    } > "${out_file}"
}

_kraken_recon_subdomains() {
    local target="$1"
    local out_file="$2"
    if ! ensure_command "subfinder" \
        "install: go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"; then
        return 0
    fi
    log_step "Searching subdomains with subfinder..."
    subfinder -d "${target}" -o "${out_file}" -silent 2>/dev/null || true
    local sub_count=0
    if [[ -f "${out_file}" ]]; then
        sub_count=$(wc -l < "${out_file}" 2>/dev/null || echo 0)
    fi
    log_success "Found ${sub_count} subdomains"
}

_kraken_recon_whois() {
    local target="$1"
    local out_file="$2"
    if ! command_exists whois; then
        return 0
    fi
    log_step "Gathering WHOIS information..."
    if whois "${target}" > "${out_file}" 2>/dev/null; then
        log_success "WHOIS data saved"
    else
        log_warn "WHOIS lookup failed"
    fi
}

_kraken_recon_reverse_dns() {
    local target="$1"
    local out_file="$2"
    log_step "Attempting reverse DNS..."
    local ip
    if command_exists dig; then
        ip=$(dig +short A "${target}" 2>/dev/null | head -1)
        [[ -n "${ip}" ]] && dig +short -x "${ip}" > "${out_file}" 2>/dev/null || true
    elif command_exists host; then
        ip=$(host "${target}" 2>/dev/null | grep "has address" | head -1 | awk '{print $NF}')
        [[ -n "${ip}" ]] && host "${ip}" > "${out_file}" 2>/dev/null || true
    else
        return 0
    fi
    if [[ -n "${ip:-}" ]]; then
        log_success "Reverse DNS completed"
    fi
}

# Entry point for the reconnaissance module.
kraken_recon_run() {
    kraken_clear_screen
    log_step "Launching reconnaissance module..."
    echo

    local target
    target=$(prompt_value "Enter target (domain or IP)")
    if ! kraken_valid_target "${target}"; then
        log_error "Invalid or empty target"
        press_enter_to_continue
        return
    fi

    local recon_dir="${KRAKEN_OUTPUT_DIR}/recon_${target}"
    mkdir -p "${recon_dir}"
    log_success "Output directory: ${recon_dir}"

    log_step "Testing connectivity..."
    if test_connectivity "${target}"; then
        log_success "Target is reachable"
    else
        log_warn "Target may be unreachable or blocking ICMP"
    fi

    log_step "Performing DNS lookups..."
    _kraken_recon_dns_records "${target}" "${recon_dir}/dns_records.txt"
    log_success "DNS records saved"

    _kraken_recon_subdomains "${target}" "${recon_dir}/subdomains.txt"
    _kraken_recon_whois      "${target}" "${recon_dir}/whois.txt"
    _kraken_recon_reverse_dns "${target}" "${recon_dir}/reverse_dns.txt"

    echo
    kraken_print_separator "─"
    log_success "Reconnaissance complete!"
    printf '%sResults saved in:%s %s\n' "${BRIGHT_BLUE}" "${RESET}" "${recon_dir}"
    if [[ -d "${recon_dir}" ]]; then
        echo
        printf '%sFiles created:%s\n' "${DIM}" "${RESET}"
        local f size
        for f in "${recon_dir}"/*; do
            [[ -e "${f}" ]] || continue
            size=$(du -h "${f}" 2>/dev/null | cut -f1)
            printf '  - %s (%s)\n' "$(basename "${f}")" "${size}"
        done
    fi
    echo
    press_enter_to_continue
}
