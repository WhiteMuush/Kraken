#!/usr/bin/env bash
# Kraken module: aggregate session output into a text report.

if [[ -n "${KRAKEN_MODULE_REPORT_LOADED:-}" ]]; then
    return 0
fi
KRAKEN_MODULE_REPORT_LOADED=1

_kraken_report_header() {
    cat <<EOF
==========================================
    KRAKEN PENTEST REPORT
==========================================

Generated: $(date '+%Y-%m-%d %H:%M:%S')
Operator: $(whoami)@$(hostname)
Session: ${KRAKEN_SESSION_NAME}

EOF
}

_kraken_report_summary() {
    local total_findings=0 hosts_scanned=0 ports_found=0 targets=""

    if find "${KRAKEN_OUTPUT_DIR}" -name "findings.txt" -print -quit 2>/dev/null | grep -q .; then
        total_findings=$(find "${KRAKEN_OUTPUT_DIR}" -name "findings.txt" \
            -exec cat {} + 2>/dev/null | grep -cE '^(MISSING_HEADER|HTTP_METHODS|INFO_DISCLOSURE):' || echo 0)
    fi
    hosts_scanned=$(find "${KRAKEN_OUTPUT_DIR}" -type d \
        \( -name "recon_*" -o -name "scan_*" \) 2>/dev/null | wc -l)
    if find "${KRAKEN_OUTPUT_DIR}" -name "nmap_services.txt" -print -quit 2>/dev/null | grep -q .; then
        ports_found=$(find "${KRAKEN_OUTPUT_DIR}" -name "nmap_services.txt" \
            -exec grep -hc "open" {} + 2>/dev/null | awk '{s+=$1} END {print s+0}')
    fi
    targets=$(find "${KRAKEN_OUTPUT_DIR}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null \
        | sed -E 's|.*/(recon|scan|web|vuln)_||' | sort -u | tr '\n' ',' | sed 's/,$//')

    cat <<EOF
==========================================
    EXECUTIVE SUMMARY
==========================================

Total Findings    : ${total_findings}
Hosts Scanned     : ${hosts_scanned}
Open Ports Found  : ${ports_found}
Vulnerabilities   : ${total_findings}

==========================================
    SCOPE
==========================================

Target(s): ${targets:-None}
Output Directory: ${KRAKEN_OUTPUT_DIR}

EOF
}

_kraken_report_recon() {
    echo "=========================================="
    echo "    RECONNAISSANCE RESULTS"
    echo "=========================================="
    echo

    if ! find "${KRAKEN_OUTPUT_DIR}" -maxdepth 1 -type d -name "recon_*" -print -quit 2>/dev/null \
        | grep -q .; then
        echo "No reconnaissance data found."
        echo
        return
    fi

    local dir target sub_count
    for dir in "${KRAKEN_OUTPUT_DIR}"/recon_*; do
        [[ -d "${dir}" ]] || continue
        target=$(basename "${dir}" | sed 's/recon_//')
        echo "Target: ${target}"
        echo "----------------------------------------"
        if [[ -f "${dir}/subdomains.txt" ]]; then
            sub_count=$(wc -l < "${dir}/subdomains.txt")
            echo "  Subdomains found: ${sub_count}"
            if [[ ${sub_count} -gt 0 ]]; then
                echo "  Top 10 subdomains:"
                head -10 "${dir}/subdomains.txt" | sed 's/^/    - /'
            fi
        fi
        if [[ -f "${dir}/dns_records.txt" ]]; then
            echo "  DNS Records:"
            grep -A2 "===" "${dir}/dns_records.txt" | sed 's/^/    /'
        fi
        echo
    done
}

_kraken_report_scan() {
    echo "=========================================="
    echo "    PORT SCANNING RESULTS"
    echo "=========================================="
    echo

    if ! find "${KRAKEN_OUTPUT_DIR}" -maxdepth 1 -type d -name "scan_*" -print -quit 2>/dev/null \
        | grep -q .; then
        echo "No port scan data found."
        echo
        return
    fi

    local dir target port_count
    for dir in "${KRAKEN_OUTPUT_DIR}"/scan_*; do
        [[ -d "${dir}" ]] || continue
        target=$(basename "${dir}" | sed 's/scan_//')
        echo "Target: ${target}"
        echo "----------------------------------------"
        if [[ -f "${dir}/nmap_services.txt" ]]; then
            port_count=$(grep -c "open" "${dir}/nmap_services.txt" 2>/dev/null || echo 0)
            echo "  Open ports: ${port_count}"
            echo
            echo "  Services detected:"
            grep "open" "${dir}/nmap_services.txt" | sed 's/^/    /'
        elif [[ -f "${dir}/bash_scan.txt" ]]; then
            port_count=$(wc -l < "${dir}/bash_scan.txt")
            echo "  Open ports: ${port_count}"
            echo
            sed 's/^/    /' "${dir}/bash_scan.txt"
        else
            echo "  No scan data available"
        fi
        echo
    done
}

_kraken_report_web() {
    echo "=========================================="
    echo "    WEB ENUMERATION RESULTS"
    echo "=========================================="
    echo

    if ! find "${KRAKEN_OUTPUT_DIR}" -maxdepth 1 -type d -name "web_*" -print -quit 2>/dev/null \
        | grep -q .; then
        echo "No web enumeration data found."
        echo
        return
    fi

    local dir target status dir_count
    for dir in "${KRAKEN_OUTPUT_DIR}"/web_*; do
        [[ -d "${dir}" ]] || continue
        target=$(basename "${dir}" | sed 's/web_//' | tr '_' '/')
        echo "Target: ${target}"
        echo "----------------------------------------"
        if [[ -f "${dir}/headers.txt" ]]; then
            status=$(head -1 "${dir}/headers.txt" | awk '{print $2}')
            echo "  HTTP Status: ${status}"
        fi
        if [[ -f "${dir}/directories.txt" ]]; then
            dir_count=$(grep -c "FOUND:" "${dir}/directories.txt" 2>/dev/null || echo 0)
            echo "  Directories found: ${dir_count}"
            if [[ ${dir_count} -gt 0 ]]; then
                echo
                echo "  Discovered paths:"
                grep -E "FOUND:|FORBIDDEN:|AUTH:" "${dir}/directories.txt" | sed 's/^/    /'
            fi
        fi
        if [[ -f "${dir}/technologies.txt" ]]; then
            echo
            echo "  Technologies:"
            grep -vE '^#|^$' "${dir}/technologies.txt" | sed 's/^/    /'
        fi
        echo
    done
}

_kraken_report_vuln() {
    echo "=========================================="
    echo "    VULNERABILITY ASSESSMENT"
    echo "=========================================="
    echo

    if ! find "${KRAKEN_OUTPUT_DIR}" -maxdepth 1 -type d -name "vuln_*" -print -quit 2>/dev/null \
        | grep -q .; then
        echo "No vulnerability assessment data found."
        echo
        return
    fi

    local dir target
    for dir in "${KRAKEN_OUTPUT_DIR}"/vuln_*; do
        [[ -d "${dir}" ]] || continue
        target=$(basename "${dir}" | sed 's/vuln_//')
        echo "Target: ${target}"
        echo "----------------------------------------"
        if [[ -f "${dir}/findings.txt" ]]; then
            grep -v '^#' "${dir}/findings.txt" | sed 's/^/  /'
        else
            echo "  No findings recorded"
        fi
        echo
    done
}

_kraken_report_recommendations() {
    cat <<EOF
==========================================
    RECOMMENDATIONS
==========================================

1. Review and patch all identified vulnerabilities
   - Prioritize critical and high-severity findings
   - Apply security patches promptly

2. Implement missing security headers
   - X-Frame-Options
   - Content-Security-Policy
   - Strict-Transport-Security

3. Disable unnecessary services and ports
   - Close unused ports
   - Remove or disable unnecessary services

4. Regular security audits
   - Conduct periodic penetration testing
   - Implement continuous security monitoring

5. Keep systems updated
   - Apply security patches regularly
   - Update all software and dependencies

==========================================
    END OF REPORT
==========================================

Report generated by: ${KRAKEN_NAME} v${KRAKEN_VERSION}
For authorized security testing only

EOF
}

# Entry point for the report generation module.
kraken_report_run() {
    kraken_clear_screen
    log_step "Generating session report..."
    echo

    if [[ ! -d "${KRAKEN_OUTPUT_DIR}" ]]; then
        log_error "No output directory found. Run scans first."
        press_enter_to_continue
        return
    fi

    local report_file
    report_file="${KRAKEN_OUTPUT_DIR}/REPORT_$(date +%Y%m%d_%H%M%S).txt"

    log_step "Collecting scan data..."
    {
        _kraken_report_header
        _kraken_report_summary
        _kraken_report_recon
        _kraken_report_scan
        _kraken_report_web
        _kraken_report_vuln
        _kraken_report_recommendations
    } > "${report_file}"

    log_success "Report generated!"
    echo
    printf '%sReport saved to:%s\n  %s%s%s\n\n' \
        "${BRIGHT_GREEN}" "${RESET}" "${BRIGHT_BLUE}" "${report_file}" "${RESET}"

    if prompt_yesno "View report now?" "no"; then
        echo
        kraken_print_separator "="
        if command_exists less; then
            less "${report_file}"
        else
            cat "${report_file}"
        fi
    fi

    echo
    printf '%sView report with:%s\n' "${DIM}" "${RESET}"
    printf '  %scat %s%s\n' "${BRIGHT_CYAN}" "${report_file}" "${RESET}"
    printf '  %sless %s%s\n\n' "${BRIGHT_CYAN}" "${report_file}" "${RESET}"
    press_enter_to_continue
}
