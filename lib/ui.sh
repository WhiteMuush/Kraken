#!/usr/bin/env bash
# Kraken UI: ASCII banner, info panel, main menu rendering.

if [[ -n "${KRAKEN_UI_LOADED:-}" ]]; then
    return 0
fi
KRAKEN_UI_LOADED=1

# ASCII squid art.
read -r -d '' KRAKEN_ASCII_ART <<'EOF' || true
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣴⣶⣤⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣠⡤⣤⣄⣾⣿⣿⣿⣿⣿⣿⣷⣠⣀⣄⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠙⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣬⡿⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⣼⠟⢿⣿⣿⣿⣿⣿⣿⡿⠘⣷⣄⠀⠀⠀⠀⠀
⣰⠛⠛⣿⢠⣿⠋⠀⠀⢹⠻⣿⣿⡿⢻⠁⠀⠈⢿⣦⠀⠀⠀⠀
⢈⣵⡾⠋⣿⣯⠀⠀⢀⣼⣷⣿⣿⣶⣷⡀⠀⠀⢸⣿⣀⣀⠀⠀
⢾⣿⣀⠀⠘⠻⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⠿⣿⡁⠀⠀⠀
⠈⠙⠛⠿⠿⠿⢿⣿⡿⣿⣿⡿⢿⣿⣿⣿⣷⣄⠀⠘⢷⣆⠀⠀
⠀⠀⠀⠀⠀⢠⣿⠏⠀⣿⡏⠀⣼⣿⠛⢿⣿⣿⣆⠀⠀⣿⡇⡀
⠀⠀⠀⠀⢀⣾⡟⠀⠀⣿⣇⠀⢿⣿⡀⠈⣿⡌⠻⠷⠾⠿⣻⠁
⠀⠀⣠⣶⠟⠫⣤⠀⠀⢸⣿⠀⣸⣿⢇⡤⢼⣧⠀⠀⠀⢀⣿⠀
⠀⣾⡏⠀⡀⣠⡟⠀⠀⢀⣿⣾⠟⠁⣿⡄⠀⠻⣷⣤⣤⡾⠋⠀
⠀⠙⠷⠾⠁⠻⣧⣀⣤⣾⣿⠋⠀⠀⢸⣧⠀⠀⠀⠉⠁⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠈⠉⠉⠹⣿⣄⠀⠀⣸⡿⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠿⠟⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀
EOF

_kraken_info_panel_lines() {
    cat <<EOF
${BOLD}${BRIGHT_MAGENTA}▄ •▄ ▄▄▄   ▄▄▄· ▄ •▄ ▄▄▄ . ▐ ▄
${BOLD}${BRIGHT_MAGENTA}█▌▄▌▪▀▄ █·▐█ ▀█ █▌▄▌▪▀▄.▀·•█▌▐█
${BOLD}${BRIGHT_MAGENTA}▐▀▀▄·▐▀▀▄ ▄█▀▀█ ▐▀▀▄·▐▀▀▪▄▐█▐▐▌
${BOLD}${BRIGHT_MAGENTA}▐█.█▌▐█•█▌▐█ ▪▐▌▐█.█▌▐█▄▄▌██▐█▌
${BOLD}${BRIGHT_MAGENTA}·▀  ▀.▀  ▀ ▀  ▀ ·▀  ▀ ▀▀▀ ▀▀ █▪

${BOLD}${BRIGHT_MAGENTA}╔═══════════════════════════════════════════════════╗${RESET}
${BOLD}${BRIGHT_MAGENTA}║${RESET}  ${BOLD}${KRAKEN_NAME} v${KRAKEN_VERSION}${RESET}            ${BRIGHT_MAGENTA}║
${BRIGHT_MAGENTA}║${RESET}  Creator: ${BRIGHT_CYAN}Melvin PETIT${RESET}                          ${BRIGHT_MAGENTA}║
${BOLD}${BRIGHT_MAGENTA}╚═══════════════════════════════════════════════════╝${RESET}
${BRIGHT_YELLOW}${BOLD}[!]${RESET} ${DIM}Modular Bash framework for automated pentesting${RESET}
${BRIGHT_YELLOW}${BOLD}[!]${RESET} ${DIM}Orchestrates recon, scanning, enumeration & reporting${RESET}

${BRIGHT_GREEN}${BOLD}[+]${RESET} ${GREEN}Use only on authorized targets${RESET}
EOF
}

# Display the ASCII art with the info panel rendered side-by-side.
kraken_display_banner() {
    local ascii_lines info_lines
    mapfile -t ascii_lines <<<"${KRAKEN_ASCII_ART}"
    mapfile -t info_lines < <(_kraken_info_panel_lines)

    local ascii_count=${#ascii_lines[@]}
    local info_count=${#info_lines[@]}
    local max_lines=$((ascii_count > info_count ? ascii_count : info_count))

    local max_ascii_width=0 line
    for line in "${ascii_lines[@]}"; do
        ((${#line} > max_ascii_width)) && max_ascii_width=${#line}
    done

    local spacing="    "
    local i ascii_line info_line pad
    for ((i=0; i<max_lines; i++)); do
        ascii_line="${ascii_lines[i]:-}"
        info_line="${info_lines[i]:-}"
        pad=$((max_ascii_width - ${#ascii_line}))
        ((pad < 0)) && pad=0
        printf "   %b%s%*s%s%s\n" \
            "${BRIGHT_MAGENTA}" "${ascii_line}" \
            "${pad}" "" \
            "${spacing}" "${info_line}"
    done
    printf '%s\n' "${RESET}"
}

# Display the main menu.
kraken_display_menu() {
    cat <<EOF
${BRIGHT_MAGENTA}╔══════════════ ${BOLD}MAIN MENU${RESET}${BRIGHT_MAGENTA} ══════════════╗${RESET}
${BRIGHT_MAGENTA}║${RESET}
${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_CYAN}[1]${RESET} Reconnaissance Module
${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_CYAN}[2]${RESET} Port Scanning Module
${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_CYAN}[3]${RESET} Web Enumeration Module
${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_CYAN}[4]${RESET} Vulnerability Assessment
${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_CYAN}[5]${RESET} Generate Report
${BRIGHT_MAGENTA}║${RESET}
${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_YELLOW}[C]${RESET} Configuration
${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_RED}[Q]${RESET} Quit
${BRIGHT_MAGENTA}║${RESET}
${BRIGHT_MAGENTA}╚════════════════════════════════════════╝${RESET}

EOF
}

# Render the configuration / status panel.
kraken_display_config() {
    kraken_clear_screen
    printf '%s%s╔═══════════════════════════════════════╗%s\n' "${BRIGHT_MAGENTA}" "${BOLD}" "${RESET}"
    printf '%s%s║         Configuration Info           ║%s\n' "${BRIGHT_MAGENTA}" "${BOLD}" "${RESET}"
    printf '%s%s╚═══════════════════════════════════════╝%s\n\n' "${BRIGHT_MAGENTA}" "${BOLD}" "${RESET}"

    printf '%sGeneral:%s\n' "${BRIGHT_CYAN}" "${RESET}"
    printf '  Script Version    : %s%s%s\n' "${BRIGHT_BLUE}" "${KRAKEN_VERSION}" "${RESET}"
    local who pwd_path
    who=$(whoami)
    pwd_path=$(pwd)
    printf '  Current User      : %s%s%s\n' "${BRIGHT_BLUE}" "${who}" "${RESET}"
    printf '  Working Directory : %s%s%s\n\n' "${BRIGHT_BLUE}" "${pwd_path}" "${RESET}"

    printf '%sCurrent Session:%s\n' "${BRIGHT_CYAN}" "${RESET}"
    printf '  Session Name      : %s%s%s%s\n' "${BRIGHT_GREEN}" "${BOLD}" "${KRAKEN_SESSION_NAME}" "${RESET}"
    printf '  Output Directory  : %s%s%s\n' "${BRIGHT_BLUE}" "${KRAKEN_OUTPUT_DIR}" "${RESET}"

    if [[ -d "${KRAKEN_OUTPUT_DIR}" ]]; then
        local file_count scan_count session_size
        file_count=$(find "${KRAKEN_OUTPUT_DIR}" -type f 2>/dev/null | wc -l)
        scan_count=$(find "${KRAKEN_OUTPUT_DIR}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
        session_size=$(du -sh "${KRAKEN_OUTPUT_DIR}" 2>/dev/null | cut -f1)
        printf '  Scans Performed   : %s%s%s\n' "${BRIGHT_BLUE}" "${scan_count}" "${RESET}"
        printf '  Files Created     : %s%s%s\n' "${BRIGHT_BLUE}" "${file_count}" "${RESET}"
        printf '  Session Size      : %s%s%s\n' "${BRIGHT_BLUE}" "${session_size}" "${RESET}"
    fi
    printf '\n%sAvailable Tools:%s\n' "${BRIGHT_CYAN}" "${RESET}"
    local tool
    for tool in nmap curl host whois subfinder ping openssl; do
        if command_exists "${tool}"; then
            printf '  %s[+]%s %s\n' "${BRIGHT_GREEN}" "${RESET}" "${tool}"
        else
            printf '  %s[x]%s %s %s(not installed)%s\n' "${BRIGHT_RED}" "${RESET}" "${tool}" "${DIM}" "${RESET}"
        fi
    done

    printf '\n%sSystem Info:%s\n' "${BRIGHT_CYAN}" "${RESET}"
    printf '  Hostname          : %s%s%s\n' "${BRIGHT_BLUE}" "$(hostname)" "${RESET}"
    printf '  Kernel            : %s%s%s\n' "${BRIGHT_BLUE}" "$(uname -r)" "${RESET}"
    printf '  Shell             : %s%s%s\n\n' "${BRIGHT_BLUE}" "${SHELL:-unknown}" "${RESET}"

    if [[ -d "${KRAKEN_BASE_DIR}" ]]; then
        local session_count total_size
        session_count=$(find "${KRAKEN_BASE_DIR}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
        total_size=$(du -sh "${KRAKEN_BASE_DIR}" 2>/dev/null | cut -f1)
        printf '%sStorage:%s\n' "${BRIGHT_CYAN}" "${RESET}"
        printf '  Total Sessions    : %s%s%s\n' "${BRIGHT_BLUE}" "${session_count}" "${RESET}"
        printf '  Total Size        : %s%s%s\n' "${BRIGHT_BLUE}" "${total_size}" "${RESET}"
    fi

    printf '\n'
    kraken_print_separator "─"
    printf '\n'
    press_enter_to_continue
}
