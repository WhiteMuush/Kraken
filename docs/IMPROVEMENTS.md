# Kraken Improvements (v1.2)

This document tracks the improvements applied to Kraken on top of the
v1.1 modular refactor. Each item maps to a single, self-contained
commit so the history stays bisectable.

## Summary

| # | Area     | Improvement                                            | Type   |
|---|----------|--------------------------------------------------------|--------|
| 1 | logger   | Persistent per-session log file (`kraken.log`)         | feat   |
| 2 | recon    | AAAA / TXT / CNAME records, prefer `dig` over `host`   | feat   |
| 3 | web      | Parallel directory enumeration with bounded jobs       | perf   |
| 4 | report   | Markdown report alongside the plaintext report         | feat   |
| 5 | core     | Target validation helper, reused across modules        | feat   |
| 6 | tooling  | `.shellcheckrc` so local lint matches CI               | chore  |

## Details

### 1. Persistent session log

Before, every `log_step` / `log_info` / `log_warn` / `log_error` /
`log_success` call wrote only to the terminal. A pentest leaves no
trace of what was run and when. `lib/logger.sh` now mirrors every log
line (timestamped, without color codes) into
`${KRAKEN_OUTPUT_DIR}/kraken.log` once a session is initialised. The
file is append-only across resumes of the same session, giving a clean
audit trail.

### 2. Richer reconnaissance

`lib/modules/recon.sh` previously queried only A / MX / NS records via
`host`. It now also collects AAAA (IPv6), TXT (SPF/DKIM/verification)
and CNAME records, and prefers `dig` when present because its output is
easier to parse and more reliable than `host`. `host` remains the
fallback, then `nslookup`, then `getent` - graceful degradation is
preserved.

### 3. Parallel web directory enumeration

`lib/modules/web.sh` probed each candidate path sequentially with a
blocking `curl`. With ~14 paths and a 5s timeout, a dead host could
stall the module for over a minute. Probes now run as bounded
background jobs (default 8 concurrent, override with
`KRAKEN_WEB_JOBS`), results are collected and sorted, then printed and
written deterministically. This matches the project's
parallel-execution convention.

### 4. Markdown report

`lib/modules/report.sh` produced a single plaintext report. It now also
writes a Markdown version (`REPORT_*.md`) with proper headings and
tables, suitable for pasting into tickets, wikis or client
deliverables. The plaintext report is unchanged so existing tooling
keeps working.

### 5. Target validation

A new `kraken_valid_target` helper in `lib/core.sh` rejects empty or
obviously malformed targets (shell metacharacters, whitespace) before
any external tool is invoked. Recon, scan and vuln modules call it
right after prompting, failing fast with a clear message instead of
feeding junk to `nmap` / `curl` / `host`.

### 6. `.shellcheckrc`

The CI workflow disabled SC1091 and SC2034 via `SHELLCHECK_OPTS`, but a
contributor running `shellcheck` locally got different results. A
repo-level `.shellcheckrc` now encodes the same exclusions so local and
CI linting agree.
