#!/usr/bin/env bash
# Kraken core: version, globals, TTY-aware color palette.

if [[ -n "${KRAKEN_CORE_LOADED:-}" ]]; then
    return 0
fi
KRAKEN_CORE_LOADED=1

# Project metadata.
KRAKEN_VERSION="1.1.0"
KRAKEN_NAME="Kraken Pentest Framework"

# Runtime globals (populated by lib/session.sh).
KRAKEN_BASE_DIR="${KRAKEN_BASE_DIR:-kraken_output}"
KRAKEN_SESSION_NAME=""
KRAKEN_OUTPUT_DIR=""

# Color palette. Only emit escape codes on an interactive TTY so piping the
# output produces clean text.
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
    RESET="$(tput sgr0)"
    BOLD="$(tput bold)"
    DIM="$(tput dim)"
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    MAGENTA="$(tput setaf 5)"
    CYAN="$(tput setaf 6)"
    BRIGHT_RED="$(tput setaf 9 2>/dev/null || tput setaf 1)"
    BRIGHT_GREEN="$(tput setaf 10 2>/dev/null || tput setaf 2)"
    BRIGHT_YELLOW="$(tput setaf 11 2>/dev/null || tput setaf 3)"
    BRIGHT_BLUE="$(tput setaf 12 2>/dev/null || tput setaf 4)"
    BRIGHT_MAGENTA="$(tput setaf 13 2>/dev/null || tput setaf 5)"
    BRIGHT_CYAN="$(tput setaf 14 2>/dev/null || tput setaf 6)"
else
    RESET=""; BOLD=""; DIM=""
    RED=""; GREEN=""; YELLOW=""; BLUE=""; MAGENTA=""; CYAN=""
    BRIGHT_RED=""; BRIGHT_GREEN=""; BRIGHT_YELLOW=""
    BRIGHT_BLUE=""; BRIGHT_MAGENTA=""; BRIGHT_CYAN=""
fi

export RESET BOLD DIM
export RED GREEN YELLOW BLUE MAGENTA CYAN
export BRIGHT_RED BRIGHT_GREEN BRIGHT_YELLOW BRIGHT_BLUE BRIGHT_MAGENTA BRIGHT_CYAN

# Validate a target (domain, hostname or IP). Rejects empty input and
# anything containing whitespace or shell metacharacters before it is
# handed to an external tool. Returns 0 when the target looks safe.
kraken_valid_target() {
    local target="$1"
    [[ -n "${target}" ]] || return 1
    # Reject whitespace and shell-dangerous characters.
    [[ "${target}" =~ [[:space:]\;\|\&\$\`\(\)\<\>\"\'\\] ]] && return 1
    # Must contain only host-legal characters (alnum, dot, hyphen, colon
    # for IPv6, and slash so a URL host can be pre-trimmed by the caller).
    [[ "${target}" =~ ^[A-Za-z0-9._:/-]+$ ]] || return 1
    return 0
}

# Width of the terminal, defaulting to 80 when stdout is not a TTY.
kraken_term_width() {
    if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
        tput cols 2>/dev/null || echo 80
    else
        echo 80
    fi
}

# Clear the screen and reset the cursor. Safe when not on a TTY.
kraken_clear_screen() {
    if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
        clear
        tput cup 0 0
    fi
}

# Print a horizontal separator of repeated characters across the terminal.
kraken_print_separator() {
    local char="${1:-─}"
    local width
    width=$(kraken_term_width)
    printf "%s%*s%s\n" "${BRIGHT_MAGENTA}" "${width}" "" "${RESET}" | tr ' ' "${char}"
}
