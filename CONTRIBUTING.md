# Contributing to Kraken

Thanks for your interest in extending Kraken. This document explains how
to set up a local environment, the conventions the code follows, and the
checklist a pull request is expected to satisfy.

## Local setup

```bash
git clone https://github.com/WhiteMuush/kraken.git
cd kraken
chmod +x kraken.sh
./kraken.sh --help
```

Optional but recommended for local checks:

```bash
sudo apt install shellcheck
```

## Repository layout

```
kraken.sh                # thin entry point
lib/
  core.sh                # version, globals, TTY-aware color palette
  logger.sh              # log_step / log_info / log_warn / log_error / log_success
  installer.sh           # ensure_command, ensure_repo, prompt_value, prompt_yesno
  ui.sh                  # banner, info panel, main menu, config view
  session.sh             # session bootstrap, connectivity test
  modules/
    recon.sh             # reconnaissance tentacle
    scan.sh              # port scanning tentacle
    web.sh               # web enumeration tentacle
    vuln.sh              # vulnerability assessment tentacle
    report.sh            # report aggregation tentacle
docs/
  ARCHITECTURE.md
  ADDING_A_MODULE.md
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the boot sequence
and how modules cooperate. To add a new tool or module, follow
[docs/ADDING_A_MODULE.md](docs/ADDING_A_MODULE.md).

## Coding conventions

- Shebang: `#!/usr/bin/env bash`
- Strict mode: **`set -uo pipefail`** at the entry point. Library files
  do not set strict mode themselves. **Do not** add `set -e` to the
  interactive code path - a single non-zero exit code from a wrapped
  tool would tear down the menu loop.
- Always double-quote variable expansions: `"${target}"`, never `$target`.
- Indent with 4 spaces, LF line endings, UTF-8 (enforced by
  `.editorconfig`).
- Function names: `snake_case`, prefixed by the module
  (`kraken_recon_run`, `_kraken_recon_dns_records` for helpers).
- Global variables: `KRAKEN_*` prefix (`KRAKEN_OUTPUT_DIR`,
  `KRAKEN_SESSION_NAME`).
- Library files guard against double-sourcing:

  ```bash
  if [[ -n "${KRAKEN_MODULE_FOO_LOADED:-}" ]]; then
      return 0
  fi
  KRAKEN_MODULE_FOO_LOADED=1
  ```

- Log via `log_step / log_info / log_warn / log_error / log_success` -
  never `echo -e "${RED}..."` in module code.
- Prompt via `prompt_value` / `prompt_yesno` - never raw `read -rp`.
- External binaries: guard with `ensure_command` (returns non-zero if
  missing). Git-cloned tools: guard with `ensure_repo`.

## ShellCheck

CI runs `shellcheck` with `--severity=warning` and excludes only:

- `SC1091` - sourcing dynamic paths via `${KRAKEN_ROOT}/lib/...`
- `SC2034` - color variables exported for cross-module use

**Do not** silence other warnings. In particular, the common ones to
avoid are:

| Code   | Avoid                              | Prefer                                      |
|--------|------------------------------------|---------------------------------------------|
| SC2155 | `local var="$(cmd)"`               | `local var; var="$(cmd)"`                   |
| SC2086 | `$var` unquoted                    | `"${var}"`                                  |
| SC2164 | `cd "$dir"; ...`                   | `cd "$dir" \|\| return 1`                   |
| SC2207 | `arr=($(cmd))`                     | `mapfile -t arr < <(cmd)`                   |

## Pull request checklist

Before opening a PR:

1. `bash -n` passes on every changed `*.sh` file.
2. `shellcheck` passes locally (or only flags allowed exclusions).
3. New external tools are guarded by `ensure_command` / `ensure_repo`.
4. New globals follow the `KRAKEN_*` naming convention.
5. New functions follow `kraken_<module>_<action>` for public entries
   and `_kraken_<module>_<helper>` for private helpers.
6. README / docs updated if user-visible behavior changed.
7. The PR description references the related issue (if any) and
   includes a short test plan.

## Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):
`feat:`, `fix:`, `refactor:`, `docs:`, `ci:`, `chore:`.

Examples:

```
feat: add naabu integration to scan module
fix: prevent set -e from killing the menu loop
docs: clarify ensure_repo usage in ADDING_A_MODULE.md
```

## License

By contributing, you agree that your contributions will be licensed
under the [MIT License](LICENSE).
