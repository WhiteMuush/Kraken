# Kraken Architecture

Kraken is a single-process, interactive Bash orchestrator. The entry
point sources a small set of helper libraries, then loops on a menu
that dispatches to independent **tentacle modules**.

## Layout

```
kraken.sh                   # entry point, ~100 lines
lib/
  core.sh                   # KRAKEN_VERSION, KRAKEN_NAME, globals, color palette
  logger.sh                 # log_step / log_info / log_warn / log_error / log_success
  installer.sh              # command/repo checks, prompts
  ui.sh                     # banner, menu, config view
  session.sh                # interactive session bootstrap
  modules/
    recon.sh
    scan.sh
    web.sh
    vuln.sh
    report.sh
docs/
  ARCHITECTURE.md
  ADDING_A_MODULE.md
```

## Boot sequence

1. `kraken.sh` runs with `set -uo pipefail` (no `-e`, see below).
2. It computes `KRAKEN_ROOT` from `BASH_SOURCE[0]` and sources every
   library file. Each library guards itself against double-sourcing
   with a `KRAKEN_*_LOADED` sentinel:

   ```bash
   if [[ -n "${KRAKEN_CORE_LOADED:-}" ]]; then
       return 0
   fi
   KRAKEN_CORE_LOADED=1
   ```

3. CLI parsing handles `--help` / `--version`, then:
   - root warning (`$EUID -eq 0`),
   - dependency check (`nmap`, `curl`, `host`),
   - interactive session bootstrap (new / resume / auto),
   - `main_loop` until the user types `Q`.

## Why no `set -e`

The main loop is interactive. A non-zero exit code from any wrapped
tool (a failed `nmap` scan, a 5xx response from `curl`) would normally
be tolerable - the operator wants to read the message and try again.
With `set -e`, those exit codes would tear down the whole shell. The
entry point therefore uses `set -uo pipefail` only:

- `-u` catches typos in variable names.
- `pipefail` propagates failures inside pipelines.

Module functions handle their own error paths through `log_warn` /
`log_error` and `return` (not `exit`).

## Color palette

`lib/core.sh` detects an interactive TTY (`[[ -t 1 ]]` plus a `tput
colors` check) and only emits escape codes in that case. When stdout
is a pipe or a non-color terminal, color variables expand to empty
strings - logs remain readable when piped to `tee` or files.

## Logging

`lib/logger.sh` exposes five level helpers backed by a single private
formatter:

| Function       | Tag            | Stream  |
|----------------|----------------|---------|
| `log_step`     | `[*]` magenta  | stdout  |
| `log_info`     | `[i]` blue     | stdout  |
| `log_success`  | `[+]` green    | stdout  |
| `log_warn`     | `[!]` yellow   | stdout  |
| `log_error`    | `[x]` red      | stderr  |

All messages are timestamped (`%Y-%m-%d %H:%M:%S`).

## Module contract

Every module file must:

1. Live under `lib/modules/<name>.sh`.
2. Start with a `KRAKEN_MODULE_<NAME>_LOADED` guard.
3. Expose **exactly one** public entry point named
   `kraken_<name>_run`. The entry point is wired into the main menu
   via `handle_selection` in `kraken.sh`.
4. Write output under `${KRAKEN_OUTPUT_DIR}/<name>_<target>/`.
5. Use the shared helpers (`prompt_value`, `ensure_command`, `log_*`).

Private helpers should be prefixed with `_kraken_<name>_` to avoid
collisions across modules.

## Session model

A session is a directory under `kraken_output/` (or the path set in
`KRAKEN_BASE_DIR`). Each module writes one subdirectory per target:

```
kraken_output/
  client_acme_audit/
    recon_example.com/
      dns_records.txt
      subdomains.txt
      whois.txt
    scan_example.com/
      nmap_quick.txt
      nmap_services.txt
    web_example_com/
      headers.txt
      directories.txt
    vuln_example.com/
      findings.txt
    REPORT_20251104_180000.txt
```

`kraken_report_run` walks this tree and aggregates everything into a
single text report.

## External dependencies

| Layer       | Dependency               | Used by                    |
|-------------|--------------------------|----------------------------|
| Shell       | bash >= 4.0              | everywhere                 |
| Core utils  | coreutils, findutils     | session, reporting         |
| Reachability| `ping`                   | `test_connectivity`        |
| DNS / WHOIS | `host`, `whois`          | recon module               |
| Recon       | `subfinder`              | recon module               |
| Scanning    | `nmap`, `/dev/tcp`       | scan module                |
| Web         | `curl`                   | web, vuln modules          |
| TLS         | `openssl`                | vuln module                |

All external commands are guarded by `ensure_command` - missing tools
trigger a warning instead of aborting the session.
