#!/usr/bin/env bash
# Kraken logger: timestamped, level-tagged messages with consistent formatting.

if [[ -n "${KRAKEN_LOGGER_LOADED:-}" ]]; then
    return 0
fi
KRAKEN_LOGGER_LOADED=1

_kraken_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

_kraken_log() {
    local tag="$1"
    local message="$2"
    printf '%b %s - %s\n' "${tag}" "$(_kraken_timestamp)" "${message}"
}

log_step() {
    _kraken_log "${BRIGHT_MAGENTA}[*]${RESET}" "$1"
}

log_info() {
    _kraken_log "${BRIGHT_BLUE}[i]${RESET}" "$1"
}

log_success() {
    _kraken_log "${BRIGHT_GREEN}[+]${RESET}" "$1"
}

log_warn() {
    _kraken_log "${BRIGHT_YELLOW}[!]${RESET}" "$1"
}

log_error() {
    _kraken_log "${BRIGHT_RED}[x]${RESET}" "$1" >&2
}
