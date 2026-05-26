#!/usr/bin/env bash
# Kraken session: create / resume named output sessions.

if [[ -n "${KRAKEN_SESSION_LOADED:-}" ]]; then
    return 0
fi
KRAKEN_SESSION_LOADED=1

# Test if a target is reachable via ICMP. Always returns - never aborts.
test_connectivity() {
    local target="$1"
    ping -c 1 -W 2 "${target}" >/dev/null 2>&1
}

# List existing session names (newest first).
_kraken_list_sessions() {
    if [[ ! -d "${KRAKEN_BASE_DIR}" ]]; then
        return 0
    fi
    find "${KRAKEN_BASE_DIR}" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null | sort -r
}

# Show a short preview of existing sessions (max 5).
_kraken_show_existing_sessions() {
    local sessions=()
    mapfile -t sessions < <(_kraken_list_sessions)
    if [[ ${#sessions[@]} -eq 0 ]]; then
        return 0
    fi

    printf '%sExisting sessions:%s\n' "${BRIGHT_CYAN}" "${RESET}"
    local i=1 session size files
    for session in "${sessions[@]}"; do
        size=$(du -sh "${KRAKEN_BASE_DIR}/${session}" 2>/dev/null | cut -f1)
        files=$(find "${KRAKEN_BASE_DIR}/${session}" -type f 2>/dev/null | wc -l)
        printf '  %s[%d]%s %s %s(%s, %s files)%s\n' \
            "${DIM}" "${i}" "${RESET}" "${session}" "${DIM}" "${size}" "${files}" "${RESET}"
        ((i++))
        if [[ ${i} -gt 5 ]]; then
            printf '  %s... and %d more%s\n' "${DIM}" "$((${#sessions[@]} - 5))" "${RESET}"
            break
        fi
    done
    printf '\n'
}

_kraken_session_new() {
    local custom_name
    printf '\n%sTips: Use descriptive names like:%s\n' "${DIM}" "${RESET}"
    printf '%s  - client_acme_initial_scan%s\n' "${DIM}" "${RESET}"
    printf '%s  - webapp_pentest_2025%s\n' "${DIM}" "${RESET}"
    printf '%s  - internal_network_audit%s\n\n' "${DIM}" "${RESET}"

    while true; do
        custom_name=$(prompt_value "Enter session name")
        custom_name=$(printf '%s' "${custom_name}" | tr ' ' '_' | sed 's/[^a-zA-Z0-9_-]//g')

        if [[ -z "${custom_name}" ]]; then
            log_error "Session name cannot be empty"
            continue
        fi

        if [[ -d "${KRAKEN_BASE_DIR}/${custom_name}" ]]; then
            log_warn "Session '${custom_name}' already exists"
            if prompt_yesno "Continue with existing session?" "yes"; then
                KRAKEN_SESSION_NAME="${custom_name}"
                KRAKEN_OUTPUT_DIR="${KRAKEN_BASE_DIR}/${KRAKEN_SESSION_NAME}"
                log_success "Continuing session: ${KRAKEN_SESSION_NAME}"
                return 0
            fi
            continue
        fi

        KRAKEN_SESSION_NAME="${custom_name}"
        KRAKEN_OUTPUT_DIR="${KRAKEN_BASE_DIR}/${KRAKEN_SESSION_NAME}"
        log_success "Created new session: ${KRAKEN_SESSION_NAME}"
        return 0
    done
}

_kraken_session_resume() {
    if [[ ! -d "${KRAKEN_BASE_DIR}" ]]; then
        log_error "No existing sessions found"
        return 1
    fi

    local sessions=()
    mapfile -t sessions < <(_kraken_list_sessions)
    if [[ ${#sessions[@]} -eq 0 ]]; then
        log_error "No existing sessions found"
        return 1
    fi

    printf '\n%sSelect session:%s\n\n' "${BRIGHT_CYAN}" "${RESET}"
    local i=1 session size files date_mod
    for session in "${sessions[@]}"; do
        size=$(du -sh "${KRAKEN_BASE_DIR}/${session}" 2>/dev/null | cut -f1)
        files=$(find "${KRAKEN_BASE_DIR}/${session}" -type f 2>/dev/null | wc -l)
        date_mod=$(stat -c %y "${KRAKEN_BASE_DIR}/${session}" 2>/dev/null | cut -d' ' -f1)
        printf '  %s[%d]%s %s\n' "${BRIGHT_CYAN}" "${i}" "${RESET}" "${session}"
        printf '      %sSize: %s | Files: %s | Modified: %s%s\n\n' \
            "${DIM}" "${size}" "${files}" "${date_mod}" "${RESET}"
        ((i++))
    done

    local session_num
    session_num=$(prompt_value "Choose session number" "1")
    if [[ "${session_num}" =~ ^[0-9]+$ ]] && \
       [[ ${session_num} -ge 1 ]] && \
       [[ ${session_num} -le ${#sessions[@]} ]]; then
        local idx=$((session_num - 1))
        KRAKEN_SESSION_NAME="${sessions[idx]}"
        KRAKEN_OUTPUT_DIR="${KRAKEN_BASE_DIR}/${KRAKEN_SESSION_NAME}"
        log_success "Continuing session: ${KRAKEN_SESSION_NAME}"
        return 0
    fi

    log_error "Invalid selection"
    return 1
}

_kraken_session_auto() {
    KRAKEN_SESSION_NAME="session_$(date +%Y%m%d_%H%M%S)"
    KRAKEN_OUTPUT_DIR="${KRAKEN_BASE_DIR}/${KRAKEN_SESSION_NAME}"
    log_success "Auto-generated session: ${KRAKEN_SESSION_NAME}"
}

# Interactive session bootstrap. Sets KRAKEN_SESSION_NAME and
# KRAKEN_OUTPUT_DIR, then creates the output directory.
kraken_initialize_session() {
    kraken_clear_screen
    kraken_display_banner

    printf '%s%s╔═══════════════════════════════════════╗%s\n' "${BRIGHT_MAGENTA}" "${BOLD}" "${RESET}"
    printf '%s%s║       Session Initialization          ║%s\n' "${BRIGHT_MAGENTA}" "${BOLD}" "${RESET}"
    printf '%s%s╚═══════════════════════════════════════╝%s\n\n' "${BRIGHT_MAGENTA}" "${BOLD}" "${RESET}"

    _kraken_show_existing_sessions

    printf '%sChoose session mode:%s\n\n' "${BRIGHT_YELLOW}" "${RESET}"
    printf '  %s[1]%s Create new named session\n' "${BRIGHT_CYAN}" "${RESET}"
    printf '  %s[2]%s Continue existing session\n' "${BRIGHT_CYAN}" "${RESET}"
    printf '  %s[3]%s Auto-generate session name\n\n' "${BRIGHT_CYAN}" "${RESET}"

    local mode
    mode=$(prompt_value "Choose option" "1")

    case "${mode}" in
        1) _kraken_session_new ;;
        2) if ! _kraken_session_resume; then
               sleep 1
               kraken_initialize_session
               return
           fi ;;
        3|*) _kraken_session_auto ;;
    esac

    mkdir -p "${KRAKEN_OUTPUT_DIR}"
    sleep 1
}
