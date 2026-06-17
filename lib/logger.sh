#!/usr/bin/env bash
# Kraken logger: timestamped, level-tagged messages with consistent formatting.

if [[ -n "${KRAKEN_LOGGER_LOADED:-}" ]]; then
    return 0
fi
KRAKEN_LOGGER_LOADED=1

_kraken_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Plain tag (no color) used for the on-disk log mirror.
_kraken_plain_tag() {
    case "$1" in
        step)    printf '[*]' ;;
        info)    printf '[i]' ;;
        success) printf '[+]' ;;
        warn)    printf '[!]' ;;
        error)   printf '[x]' ;;
        *)       printf '[ ]' ;;
    esac
}

# Append a log line to the session log file, if a session is active.
# Color codes are stripped so the file stays grep-friendly.
_kraken_log_to_file() {
    local level="$1"
    local message="$2"
    [[ -n "${KRAKEN_OUTPUT_DIR:-}" && -d "${KRAKEN_OUTPUT_DIR}" ]] || return 0
    printf '%s %s - %s\n' \
        "$(_kraken_plain_tag "${level}")" "$(_kraken_timestamp)" "${message}" \
        >> "${KRAKEN_OUTPUT_DIR}/kraken.log" 2>/dev/null || true
}

_kraken_log() {
    local tag="$1"
    local message="$2"
    local level="${3:-}"
    printf '%b %s - %s\n' "${tag}" "$(_kraken_timestamp)" "${message}"
    _kraken_log_to_file "${level}" "${message}"
}

log_step() {
    _kraken_log "${BRIGHT_MAGENTA}[*]${RESET}" "$1" step
}

log_info() {
    _kraken_log "${BRIGHT_BLUE}[i]${RESET}" "$1" info
}

log_success() {
    _kraken_log "${BRIGHT_GREEN}[+]${RESET}" "$1" success
}

log_warn() {
    _kraken_log "${BRIGHT_YELLOW}[!]${RESET}" "$1" warn
}

log_error() {
    _kraken_log "${BRIGHT_RED}[x]${RESET}" "$1" error >&2
}
