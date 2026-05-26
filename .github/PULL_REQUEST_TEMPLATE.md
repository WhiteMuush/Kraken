<!--
Thanks for contributing to Kraken!
Read CONTRIBUTING.md and docs/ADDING_A_MODULE.md before opening a PR.
-->

## Summary

<!-- One or two sentences: what does this PR change, and why? -->

## Type of change

- [ ] Bug fix
- [ ] New module / tool integration
- [ ] Refactor / cleanup
- [ ] Documentation
- [ ] CI / tooling

## Checklist

- [ ] `bash -n` passes on every changed `*.sh` file
- [ ] `shellcheck` passes (or only emits the warnings allowed by `.github/workflows/ci.yml`)
- [ ] Functions and globals follow the `kraken_<module>_` / `KRAKEN_*` naming convention
- [ ] No `set -e` in interactive code paths (use `set -uo pipefail`)
- [ ] Output goes through `log_step / log_info / log_warn / log_error / log_success`
- [ ] User input goes through `prompt_value` / `prompt_yesno`
- [ ] New external tools are guarded with `ensure_command` / `ensure_repo`
- [ ] README / docs updated if user-facing behavior changed

## Test plan

<!-- How did you verify the change? Sample command, target used, expected output... -->

## Related issues

<!-- Closes #... -->
