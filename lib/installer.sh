#!/usr/bin/env bash
# Kraken installer/helpers: command checks, prompts, repo helpers.

if [[ -n "${KRAKEN_INSTALLER_LOADED:-}" ]]; then
    return 0
fi
KRAKEN_INSTALLER_LOADED=1

# Return 0 if the given binary is on PATH.
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure a command exists on PATH; warn and return non-zero if missing.
# Usage:
#   ensure_command "nmap" "install via apt: sudo apt install nmap"
ensure_command() {
    local cmd="$1"
    local hint="${2:-}"
    if command_exists "${cmd}"; then
        return 0
    fi
    if [[ -n "${hint}" ]]; then
        log_warn "${cmd} is not installed (${hint})"
    else
        log_warn "${cmd} is not installed"
    fi
    return 1
}

# has_raw_socket
# Returns 0 only when a raw socket can actually be opened, so nmap SYN scans,
# OS detection, etc. work. Returns non-zero for an unprivileged user or a
# rootless podman box, where CAP_NET_RAW can appear set in CapEff yet stay
# ineffective over the host network namespace. Because that bit lies in the
# rootless case, the only reliable test is to open a socket for real; the
# verdict is cached for the session. With no interpreter to try, it assumes no
# raw socket (safe: a connect scan works everywhere).
has_raw_socket() {
    case "${_KRAKEN_RAW_SOCKET:-}" in
        yes) return 0 ;;
        no)  return 1 ;;
    esac
    local rc=1
    if command_exists python3; then
        python3 - <<'PY' 2>/dev/null
import socket, sys
try:
    socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_TCP).close()
except OSError:
    sys.exit(1)
PY
        rc=$?
    elif command_exists perl; then
        perl -e 'use Socket; socket(my $s, AF_INET, SOCK_RAW, getprotobyname("tcp")) or exit 1;' 2>/dev/null
        rc=$?
    fi
    if [[ $rc -eq 0 ]]; then _KRAKEN_RAW_SOCKET=yes; else _KRAKEN_RAW_SOCKET=no; fi
    return "$rc"
}

# safe_nmap [args...]
# Runs nmap so it never dies on "Couldn't open a raw socket": with no raw
# socket available it prepends --unprivileged, forcing a TCP connect scan.
# Pass ordinary nmap arguments; do not add -sS/-sU/-O, which cannot run
# unprivileged and would conflict with the fallback.
safe_nmap() {
    local -a priv=()
    if ! has_raw_socket; then
        priv+=(--unprivileged)
        if [[ -z "${_KRAKEN_NMAP_NOTICE:-}" ]]; then
            log_warn "No raw socket available; nmap will run an unprivileged TCP connect scan."
            _KRAKEN_NMAP_NOTICE=1
        fi
    fi
    nmap "${priv[@]}" "$@"
}

# Ensure a git repository is cloned at the destination, optionally running a
# follow-up command after cloning. Returns non-zero if git is missing.
# Usage:
#   ensure_repo "https://github.com/x/y.git" "/opt/y" "pip install -r /opt/y/requirements.txt"
ensure_repo() {
    local url="$1"
    local dest="$2"
    local post_install="${3:-}"

    if ! ensure_command "git" "install via your package manager"; then
        return 1
    fi

    if [[ -d "${dest}/.git" ]]; then
        return 0
    fi

    log_step "Cloning ${url} into ${dest}"
    if ! git clone --depth 1 "${url}" "${dest}"; then
        log_error "Failed to clone ${url}"
        return 1
    fi

    if [[ -n "${post_install}" ]]; then
        log_step "Running post-install: ${post_install}"
        if ! bash -c "${post_install}"; then
            log_warn "Post-install command failed"
            return 1
        fi
    fi
    return 0
}

# Prompt for a single value. Returns the trimmed reply on stdout.
# Usage:
#   target=$(prompt_value "Enter target (domain or IP)")
prompt_value() {
    local prompt_text="$1"
    local default_value="${2:-}"
    local reply
    if [[ -n "${default_value}" ]]; then
        read -rp "${BRIGHT_CYAN}[?]${RESET} ${prompt_text} [${default_value}]: " reply
        reply="${reply:-${default_value}}"
    else
        read -rp "${BRIGHT_CYAN}[?]${RESET} ${prompt_text}: " reply
    fi
    printf '%s\n' "${reply}"
}

# Yes/no prompt. Default is "no" unless second arg is "yes".
# Usage:
#   if prompt_yesno "Continue?" "yes"; then ...
prompt_yesno() {
    local prompt_text="$1"
    local default="${2:-no}"
    local hint reply
    if [[ "${default}" == "yes" ]]; then
        hint="Y/n"
    else
        hint="y/N"
    fi
    read -rp "${BRIGHT_CYAN}[?]${RESET} ${prompt_text} (${hint}): " reply
    reply="${reply,,}"
    if [[ -z "${reply}" ]]; then
        [[ "${default}" == "yes" ]]
        return $?
    fi
    [[ "${reply}" == "y" || "${reply}" == "yes" ]]
}

# Pause until the user presses Enter.
press_enter_to_continue() {
    read -rp "${DIM}Press Enter to continue...${RESET}"
}
