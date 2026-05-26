# Adding a Module to Kraken

Kraken is built so that new tentacles can be added in a handful of
lines. This guide walks through the three ways to extend it: adding a
single tool to an existing module, integrating a git-based tool, and
creating a whole new module.

## 1. Add a tool to an existing module (5 lines)

Open the relevant file under `lib/modules/`, write a helper, and call
it from the module entry point.

```bash
# In lib/modules/recon.sh
_kraken_recon_amass() {
    local target="$1"
    local out_file="$2"
    ensure_command "amass" "install: snap install amass" || return 0
    log_step "Running amass passive enumeration..."
    amass enum -passive -d "${target}" -o "${out_file}" 2>/dev/null
    log_success "Amass results saved"
}
```

Then call it from `kraken_recon_run`:

```bash
_kraken_recon_amass "${target}" "${recon_dir}/amass.txt"
```

That's it. `ensure_command` returns non-zero and the helper exits if
`amass` is not installed - the rest of the module keeps running.

## 2. Integrate a git-based tool

When the tool isn't packaged but lives in a GitHub repository, use
`ensure_repo`. It clones on first use and runs an optional post-install
command (such as `pip install -r requirements.txt`).

```bash
_kraken_postexploit_run_linpeas() {
    local dest="${KRAKEN_OUTPUT_DIR}/tools/linpeas"
    ensure_repo \
        "https://github.com/carlospolop/PEASS-ng.git" \
        "${dest}" \
        "" || return 0
    bash "${dest}/linPEAS/linpeas.sh"
}
```

If the tool needs Python dependencies:

```bash
ensure_repo \
    "https://github.com/example/tool.git" \
    "/opt/tool" \
    "pip3 install -r /opt/tool/requirements.txt" || return 0
```

## 3. Create a whole new module

Suppose you want a `postexploit` tentacle.

### 3.1. Create the file

`lib/modules/postexploit.sh`:

```bash
#!/usr/bin/env bash
# Kraken module: post-exploitation tooling.

if [[ -n "${KRAKEN_MODULE_POSTEXPLOIT_LOADED:-}" ]]; then
    return 0
fi
KRAKEN_MODULE_POSTEXPLOIT_LOADED=1

_kraken_postexploit_linpeas() {
    local out_dir="$1"
    local dest="${out_dir}/linpeas"
    ensure_repo \
        "https://github.com/carlospolop/PEASS-ng.git" \
        "${dest}" "" || return 0
    log_step "Running linpeas (read-only)..."
    bash "${dest}/linPEAS/linpeas.sh" -a > "${out_dir}/linpeas.txt" 2>&1
    log_success "linpeas output saved"
}

kraken_postexploit_run() {
    kraken_clear_screen
    log_step "Launching post-exploitation module..."
    echo

    local label
    label=$(prompt_value "Tag for this run (e.g., host_alpha)")
    [[ -z "${label}" ]] && { log_error "Tag required"; press_enter_to_continue; return; }

    local out_dir="${KRAKEN_OUTPUT_DIR}/postexploit_${label}"
    mkdir -p "${out_dir}"

    _kraken_postexploit_linpeas "${out_dir}"

    echo
    kraken_print_separator "─"
    log_success "Post-exploitation complete!"
    printf '%sResults saved in:%s %s\n\n' "${BRIGHT_BLUE}" "${RESET}" "${out_dir}"
    press_enter_to_continue
}
```

### 3.2. Wire it into the entry point

In `kraken.sh`:

```bash
# shellcheck source=lib/modules/postexploit.sh
source "${KRAKEN_ROOT}/lib/modules/postexploit.sh"
```

And update `handle_selection`:

```bash
case "${choice,,}" in
    1) kraken_recon_run ;;
    2) kraken_scan_run ;;
    3) kraken_web_run ;;
    4) kraken_vuln_run ;;
    5) kraken_report_run ;;
    6) kraken_postexploit_run ;;
    ...
```

### 3.3. Add it to the menu

In `lib/ui.sh`, inside `kraken_display_menu`, add a line:

```
${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_CYAN}[6]${RESET} Post-Exploitation Module
```

### 3.4. Update the CI smoke test

In `.github/workflows/ci.yml`, add `kraken_postexploit_run` to the
`expected` array.

## Don't / Do

| Don't                                                | Do                                                       |
|------------------------------------------------------|----------------------------------------------------------|
| `echo -e "${RED}error${RESET}"`                      | `log_error "error"`                                      |
| `read -rp "target: " target`                         | `target=$(prompt_value "Enter target")`                  |
| `if ! command -v nmap; then echo missing; fi`        | `ensure_command "nmap" "install via apt" \|\| return 0`  |
| `local count=$(wc -l < file)`                        | `local count; count=$(wc -l < file)`                     |
| Run `git clone` directly inside a module             | Use `ensure_repo "$url" "$dest"`                         |
| Add `set -e` to a module                             | Let the entry point keep `set -uo pipefail` only         |
| Use bare globals like `OUTPUT_DIR`                   | Use `KRAKEN_OUTPUT_DIR`                                  |
| Forget the `KRAKEN_MODULE_*_LOADED` guard            | Always include it at the top of the file                 |

## Testing

Before opening a PR:

```bash
bash -n lib/modules/your_module.sh
shellcheck lib/modules/your_module.sh
bash kraken.sh --help        # source chain must still load cleanly
```

The CI workflow re-runs all three checks plus the smoke test on every
push.
