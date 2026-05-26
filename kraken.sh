#!/usr/bin/env bash
# Kraken: modular Bash penetration testing orchestrator.
# Entry point. The interactive menu must NOT use `set -e` because a single
# non-zero exit code from a child tool (nmap, curl...) would kill the loop.

set -uo pipefail

KRAKEN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly KRAKEN_ROOT

# shellcheck source=lib/core.sh
source "${KRAKEN_ROOT}/lib/core.sh"
# shellcheck source=lib/logger.sh
source "${KRAKEN_ROOT}/lib/logger.sh"
# shellcheck source=lib/installer.sh
source "${KRAKEN_ROOT}/lib/installer.sh"
# shellcheck source=lib/ui.sh
source "${KRAKEN_ROOT}/lib/ui.sh"
# shellcheck source=lib/session.sh
source "${KRAKEN_ROOT}/lib/session.sh"
# shellcheck source=lib/modules/recon.sh
source "${KRAKEN_ROOT}/lib/modules/recon.sh"
# shellcheck source=lib/modules/scan.sh
source "${KRAKEN_ROOT}/lib/modules/scan.sh"
# shellcheck source=lib/modules/web.sh
source "${KRAKEN_ROOT}/lib/modules/web.sh"
# shellcheck source=lib/modules/vuln.sh
source "${KRAKEN_ROOT}/lib/modules/vuln.sh"
# shellcheck source=lib/modules/report.sh
source "${KRAKEN_ROOT}/lib/modules/report.sh"

print_usage() {
    cat <<EOF
${KRAKEN_NAME} v${KRAKEN_VERSION}

Usage:
  $(basename "$0") [--help] [--version]

Run with no arguments to launch the interactive menu.
Some modules require sudo for raw socket access (nmap SYN scans, etc).

Options:
  -h, --help       Show this help and exit
  -v, --version    Show version and exit

See docs/ARCHITECTURE.md for the module layout, and
docs/ADDING_A_MODULE.md to extend Kraken with new tentacles.
EOF
}

handle_selection() {
    local choice="$1"
    case "${choice,,}" in
        1) kraken_recon_run ;;
        2) kraken_scan_run ;;
        3) kraken_web_run ;;
        4) kraken_vuln_run ;;
        5) kraken_report_run ;;
        c|config) kraken_display_config ;;
        q|quit|exit)
            echo
            log_step "Shutting down Kraken..."
            printf '%s%sThanks for using Kraken!%s\n\n' "${BRIGHT_MAGENTA}" "${BOLD}" "${RESET}"
            exit 0
            ;;
        "")
            return
            ;;
        *)
            log_error "Invalid option: ${choice}"
            sleep 1
            ;;
    esac
}

main_loop() {
    local choice
    while true; do
        kraken_clear_screen
        kraken_display_banner
        kraken_display_menu

        printf '%sCurrent session: %s%s%s\n\n' \
            "${DIM}" "${BRIGHT_GREEN}" "${KRAKEN_SESSION_NAME}" "${RESET}"
        read -rp " ${BRIGHT_BLUE}$(whoami)${BRIGHT_MAGENTA}@Kraken${RESET}:~${BRIGHT_BLUE}\$ ${RESET}" choice
        echo

        handle_selection "${choice}"
    done
}

check_dependencies() {
    local missing=()
    local tool
    for tool in nmap curl host; do
        command_exists "${tool}" || missing+=("${tool}")
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        kraken_clear_screen
        log_warn "Some recommended tools are missing:"
        for tool in "${missing[@]}"; do
            printf '  %s[!]%s %s\n' "${BRIGHT_YELLOW}" "${RESET}" "${tool}"
        done
        echo
        printf '%sKraken will work with reduced functionality.%s\n' "${DIM}" "${RESET}"
        printf '%sInstall missing tools for full features.%s\n\n' "${DIM}" "${RESET}"
        press_enter_to_continue
    fi
}

main() {
    case "${1:-}" in
        -h|--help) print_usage; exit 0 ;;
        -v|--version) printf '%s v%s\n' "${KRAKEN_NAME}" "${KRAKEN_VERSION}"; exit 0 ;;
        "") ;;
        *) print_usage; exit 1 ;;
    esac

    if [[ ${EUID} -eq 0 ]]; then
        kraken_clear_screen
        log_warn "Running as root - proceed with caution!"
        sleep 2
    fi

    check_dependencies
    kraken_initialize_session
    main_loop
}

main "$@"
