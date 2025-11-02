#!/usr/bin/env bash


set -euo pipefail

# COLOR DEFINITIONS
readonly RESET="$(tput sgr0)"
readonly BOLD="$(tput bold)"
readonly DIM="$(tput dim)"

# Standard colors
readonly RED="$(tput setaf 1)"
readonly GREEN="$(tput setaf 2)"
readonly YELLOW="$(tput setaf 3)"
readonly BLUE="$(tput setaf 4)"
readonly MAGENTA="$(tput setaf 5)"
readonly CYAN="$(tput setaf 6)"

# Bright colors
readonly BRIGHT_RED="$(tput setaf 9)"
readonly BRIGHT_GREEN="$(tput setaf 10)"
readonly BRIGHT_YELLOW="$(tput setaf 11)"
readonly BRIGHT_BLUE="$(tput setaf 12)"
readonly BRIGHT_MAGENTA="$(tput setaf 13)"
readonly BRIGHT_CYAN="$(tput setaf 14)"

# GLOBAL VARIABLES
readonly SCRIPT_VERSION="1.0.0"
readonly SCRIPT_NAME="Kraken Pentest Framework"
readonly OUTPUT_DIR="kraken_output_$(date +%Y%m%d_%H%M%S)"

# ASCII ART BANNER
readonly ASCII_ART='⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣴⣶⣤⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀
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
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠿⠟⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀'

# INFORMATION PANEL
readonly INFO_PANEL=(
    ""
    "${BOLD}${BRIGHT_MAGENTA}╔═══════════════════════════════════════════════════╗${RESET}"
    "${BOLD}${BRIGHT_MAGENTA}║${RESET}  ${BOLD}${SCRIPT_NAME} v${SCRIPT_VERSION}${RESET}"
    "${BRIGHT_MAGENTA}║${RESET}  Architecture: ${BRIGHT_BLUE}Shell ${RESET}"
    "${BRIGHT_MAGENTA}║${RESET}  Creator: ${BRIGHT_CYAN}\e]8;;https://github.com/WhiteMuush\aMelvin PETIT\e]8;;\a${RESET}"
    "${BOLD}${BRIGHT_MAGENTA}╚═══════════════════════════════════════════════════╝${RESET}"
    ""
    "${BRIGHT_YELLOW}${BOLD}[!]${RESET} ${DIM}Modular Bash framework for automated pentesting${RESET}"
    "${BRIGHT_YELLOW}${BOLD}[!]${RESET} ${DIM}Orchestrates recon, scanning, enumeration & reporting${RESET}"
    ""
    "${BRIGHT_GREEN}${BOLD}[✓]${RESET} ${GREEN}Use only on authorized targets${RESET}"
    ""
)

# MENU OPTIONS
readonly MENU_OPTIONS=(
    ""
    "${BRIGHT_MAGENTA}╔══════════════ ${BOLD}MAIN MENU${RESET}${BRIGHT_MAGENTA} ══════════════╗${RESET}"
    "${BRIGHT_MAGENTA}║${RESET}"
    "${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_CYAN}[1]${RESET} Reconnaissance Module"
    "${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_CYAN}[2]${RESET} Port Scanning Module"
    "${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_CYAN}[3]${RESET} Web Enumeration Module"
    "${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_CYAN}[4]${RESET} Vulnerability Assessment"
    "${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_CYAN}[5]${RESET} Report Generation"
    "${BRIGHT_MAGENTA}║${RESET}"
    "${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_YELLOW}[C]${RESET} Configuration"
    "${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_RED}[Q]${RESET} Quit"
    "${BRIGHT_MAGENTA}║${RESET}"
    "${BRIGHT_MAGENTA}╚════════════════════════════════════════╝${RESET}"
    ""
)

# UTILITY FUNCTIONS

# Clear screen and reset cursor
clear_screen() {
    clear
    tput cup 0 0
}

# Print centered text
print_centered() {
    local text="$1"
    local width
    width=$(tput cols)
    local text_length=${#text}
    local padding=$(( (width - text_length) / 2 ))
    
    printf "%*s%s\n" $padding "" "$text"
}

# Print separator line
print_separator() {
    local char="${1:-─}"
    local width
    width=$(tput cols)
    printf "${BRIGHT_MAGENTA}%*s${RESET}\n" "$width" | tr ' ' "$char"
}

# Log message with timestamp
log_message() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        info)    echo "${BRIGHT_BLUE}[i]${RESET} ${timestamp} - ${message}" ;;
        success) echo "${BRIGHT_GREEN}[✓]${RESET} ${timestamp} - ${message}" ;;
        warning) echo "${BRIGHT_YELLOW}[!]${RESET} ${timestamp} - ${message}" ;;
        error)   echo "${BRIGHT_RED}[✗]${RESET} ${timestamp} - ${message}" ;;
        *)       echo "${DIM}[?]${RESET} ${timestamp} - ${message}" ;;
    esac
}

# DISPLAY FUNCTIONS


# Display ASCII art with info panel side-by-side
display_banner() {
    local -a ascii_lines info_lines
    
    # Convert to arrays
    IFS=$'\n' read -r -d '' -a ascii_lines <<< "$ASCII_ART" || true
    info_lines=("${INFO_PANEL[@]}")
    
    # Calculate dimensions
    local ascii_count=${#ascii_lines[@]}
    local info_count=${#info_lines[@]}
    local max_lines=$((ascii_count > info_count ? ascii_count : info_count))
    
    # Get max ASCII width for padding
    local max_ascii_width=0
    for line in "${ascii_lines[@]}"; do
        ((${#line} > max_ascii_width)) && max_ascii_width=${#line}
    done
    
    local spacing="    "
    
    # Render side-by-side
    for ((i=0; i<max_lines; i++)); do
        local ascii_line="${ascii_lines[i]:-}"
        local info_line="${info_lines[i]:-}"
        
        # Colorize ASCII
        local colored_ascii="${BRIGHT_MAGENTA}${ascii_line}${RESET}"
        
        # Calculate padding
        local pad=$((max_ascii_width - ${#ascii_line}))
        ((pad < 0)) && pad=0
        
        # Print line
        printf "   %b%*s%s%b\n" \
            "$colored_ascii" \
            "$pad" "" \
            "$spacing" \
            "$info_line"
    done
    
    echo ""
}

# Display main menu
display_menu() {
    for line in "${MENU_OPTIONS[@]}"; do
        echo "$line"
    done
}


# MODULE HANDLERS


module_recon() {
    log_message "info" "Launching reconnaissance module..."
    sleep 1
    log_message "warning" "Module not yet implemented"
    read -rp "${DIM}Press Enter to continue...${RESET}"
}

module_scan() {
    log_message "info" "Launching port scanning module..."
    sleep 1
    log_message "warning" "Module not yet implemented"
    read -rp "${DIM}Press Enter to continue...${RESET}"
}

module_web() {
    log_message "info" "Launching web enumeration module..."
    sleep 1
    log_message "warning" "Module not yet implemented"
    read -rp "${DIM}Press Enter to continue...${RESET}"
}

module_vuln() {
    log_message "info" "Launching vulnerability assessment..."
    sleep 1
    log_message "warning" "Module not yet implemented"
    read -rp "${DIM}Press Enter to continue...${RESET}"
}

module_report() {
    log_message "info" "Generating reports..."
    sleep 1
    log_message "warning" "Module not yet implemented"
    read -rp "${DIM}Press Enter to continue...${RESET}"
}

show_config() {
    clear_screen
    echo "${BRIGHT_MAGENTA}${BOLD}Configuration${RESET}"
    echo ""
    echo "${BRIGHT_BLUE}Output Directory:${RESET} $OUTPUT_DIR"
    echo "${BRIGHT_BLUE}Script Version:${RESET} $SCRIPT_VERSION"
    echo "${BRIGHT_BLUE}Current User:${RESET} $(whoami)"
    echo "${BRIGHT_BLUE}Working Directory:${RESET} $(pwd)"
    echo ""
    read -rp "${DIM}Press Enter to continue...${RESET}"
}


# INPUT HANDLER


handle_selection() {
    local choice="$1"
    
    case "${choice,,}" in
        1) module_recon ;;
        2) module_scan ;;
        3) module_web ;;
        4) module_vuln ;;
        5) module_report ;;
        c) show_config ;;
        q|quit|exit)
            log_message "info" "Exiting Kraken..."
            exit 0
            ;;
        "")
            return
            ;;
        *)
            log_message "error" "Invalid option: $choice"
            sleep 1
            ;;
    esac
}


# MAIN LOOP


main_loop() {
    while true; do
        clear_screen
        display_banner
        display_menu
        
        # Custom prompt
        read -rp " ${BRIGHT_MAGENTA}$(whoami)@Kraken${RESET}:${BRIGHT_BLUE}~\$${RESET} " choice
        echo ""
        
        handle_selection "$choice"
    done
}


# ENTRY POINT


# Check if running as root (optional warning)
if [[ $EUID -eq 0 ]]; then
    log_message "warning" "Running as root - be careful!"
    sleep 1
fi

# Start main loop
main_loop