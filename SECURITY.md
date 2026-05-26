# Security Policy

## Scope

Kraken is a Bash orchestrator that wraps third-party security tools
(nmap, subfinder, ffuf, nuclei, ...). The threat model considered here
is **the wrapper itself** - shell injection, unsafe variable expansion,
path traversal in session names, unsafe handling of user-supplied
targets in the Kraken code.

Vulnerabilities in the wrapped tools must be reported to their
respective upstream projects.

## Reporting a vulnerability

**Do not open public issues for security problems.**

Use one of the following private channels:

- GitHub Security Advisories:
  <https://github.com/WhiteMuush/kraken/security/advisories/new>
- Email the maintainer using the address on their GitHub profile.

When reporting, please include:

- Affected version (`./kraken.sh --version`)
- Operating system and Bash version
- A minimal reproducer (commands, inputs, expected vs. observed)
- Impact assessment if known

You can expect an acknowledgement within a few days. Coordinated
disclosure is preferred; we will agree on a timeline before any public
discussion.

## Supported versions

Only the latest tagged release receives security fixes.

## Responsible use

Kraken is intended for **authorized security testing only**. Running it
against systems you do not own or are not explicitly permitted to test
may be illegal. The authors decline all responsibility for misuse.
