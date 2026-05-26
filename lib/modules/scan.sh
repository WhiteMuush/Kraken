#!/usr/bin/env bash
# Kraken module: port scanning (nmap, with bash /dev/tcp fallback).

if [[ -n "${KRAKEN_MODULE_SCAN_LOADED:-}" ]]; then
    return 0
fi
KRAKEN_MODULE_SCAN_LOADED=1

_kraken_scan_with_nmap() {
    local target="$1"
    local scan_dir="$2"

    log_step "Phase 1: Quick scan (top 100 ports)..."
    nmap -Pn -T4 --top-ports 100 "${target}" \
        -oN "${scan_dir}/nmap_quick.txt" 2>/dev/null || true

    log_step "Phase 2: Service version detection..."
    nmap -Pn -sV --open "${target}" \
        -oN "${scan_dir}/nmap_services.txt" 2>/dev/null || true

    log_success "Nmap scan complete"

    if [[ -f "${scan_dir}/nmap_services.txt" ]]; then
        echo
        printf '%s═══ Open Ports ═══%s\n' "${BRIGHT_MAGENTA}" "${RESET}"
        grep "open" "${scan_dir}/nmap_services.txt" | grep -v "filtered" | \
            while IFS= read -r line; do
                printf '  %s[+]%s %s\n' "${BRIGHT_GREEN}" "${RESET}" "${line}"
            done
    fi
}

_kraken_scan_with_bash() {
    local target="$1"
    local scan_dir="$2"
    local common_ports=(21 22 23 25 53 80 110 143 443 445 3306 3389 5432 8080 8443)
    local open_count=0 port

    echo
    printf '%s═══ Scanning Common Ports (bash fallback) ═══%s\n' "${BRIGHT_MAGENTA}" "${RESET}"
    for port in "${common_ports[@]}"; do
        if timeout 2 bash -c "echo >/dev/tcp/${target}/${port}" 2>/dev/null; then
            printf '  %s[+] Port %s: OPEN%s\n' "${BRIGHT_GREEN}" "${port}" "${RESET}"
            echo "Port ${port}: OPEN" >> "${scan_dir}/bash_scan.txt"
            ((open_count++))
        fi
    done
    log_success "Found ${open_count} open ports"
}

# Entry point for the port scanning module.
kraken_scan_run() {
    kraken_clear_screen
    log_step "Launching port scanning module..."
    echo

    local target
    target=$(prompt_value "Enter target IP/domain")
    if [[ -z "${target}" ]]; then
        log_error "No target specified"
        press_enter_to_continue
        return
    fi

    local scan_dir="${KRAKEN_OUTPUT_DIR}/scan_${target}"
    mkdir -p "${scan_dir}"
    log_success "Output directory: ${scan_dir}"

    log_step "Testing connectivity..."
    if test_connectivity "${target}"; then
        log_success "Target is reachable"
    else
        log_warn "Target may be blocking ICMP"
    fi

    if command_exists nmap; then
        log_step "Scanning with nmap (this may take a while)..."
        _kraken_scan_with_nmap "${target}" "${scan_dir}"
    else
        log_warn "nmap not installed, using native bash scan..."
        _kraken_scan_with_bash "${target}" "${scan_dir}"
    fi

    echo
    kraken_print_separator "─"
    log_success "Port scanning complete!"
    printf '%sResults saved in:%s %s\n\n' "${BRIGHT_BLUE}" "${RESET}" "${scan_dir}"
    press_enter_to_continue
}
