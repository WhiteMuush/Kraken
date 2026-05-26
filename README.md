# Kraken

[![CI](https://github.com/WhiteMuush/kraken/actions/workflows/ci.yml/badge.svg)](https://github.com/WhiteMuush/kraken/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Shell: bash](https://img.shields.io/badge/Shell-bash%20%E2%89%A5%204.0-1f425f.svg)](https://www.gnu.org/software/bash/)

> Modular Bash penetration testing orchestrator.
> Reconnaissance, scanning, enumeration, vulnerability checks and
> reporting - all wired into one interactive menu, with structured
> output and per-tool guards.

<img width="989" height="684" alt="SCRIPT" src="https://github.com/user-attachments/assets/6363c6a6-8cf4-439e-8674-b516cf6876bc" />

## Overview

- **Modular tentacles** - each module under `lib/modules/` is
  independent and replaceable.
- **Automation-first** - the menu walks you through DNS, ports, web,
  vulns and report generation in a few keystrokes.
- **Lightweight** - pure Bash, no Python runtime, no daemons.
- **Structured output** - one folder per session, one subfolder per
  module/target, one aggregated text report at the end.
- **Graceful degradation** - missing tools trigger a warning, never an
  abort. Install only what you need.

## Quick start

Prerequisites:

- Bash >= 4.0
- `sudo` for some modules (raw socket scans)
- Recommended: `git`, `curl`, `host`, plus the tools you plan to use

```bash
git clone https://github.com/WhiteMuush/kraken.git
cd kraken
chmod +x kraken.sh
sudo ./kraken.sh
```

Help and version:

```bash
./kraken.sh --help
./kraken.sh --version
```

## Project layout

```
kraken.sh                # entry point (~100 lines)
lib/
  core.sh                # version, globals, TTY-aware colors
  logger.sh              # log_step / log_info / log_warn / log_error / log_success
  installer.sh           # ensure_command, ensure_repo, prompt_value, prompt_yesno
  ui.sh                  # banner, info panel, main menu, config view
  session.sh             # session bootstrap, connectivity test
  modules/
    recon.sh             # DNS, subdomains, WHOIS, reverse DNS
    scan.sh              # nmap + /dev/tcp fallback
    web.sh               # headers, directories, tech, robots.txt
    vuln.sh              # SSL, methods, security headers
    report.sh            # aggregate session into one text report
docs/
  ARCHITECTURE.md        # boot sequence, module contract, color model
  ADDING_A_MODULE.md     # how to extend Kraken in 5 lines
.github/                 # CI workflow + issue / PR templates
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the boot sequence
and module contract.

## Modules

| Key | Module          | What it does                                                   |
|-----|-----------------|----------------------------------------------------------------|
| 1   | Reconnaissance  | DNS records, subdomain enumeration, WHOIS, reverse DNS         |
| 2   | Port scanning   | nmap quick + service detection, `/dev/tcp` fallback            |
| 3   | Web enumeration | HTTP headers, common directories, technology detection, robots |
| 4   | Vulnerability   | SSL/TLS, allowed methods, missing security headers             |
| 5   | Report          | Aggregate the current session into a single text report        |

## Requirements

See [requirements.txt](requirements.txt) for the full list. Install
only the tools you plan to use - Kraken degrades gracefully when a
tool is missing.

Common external dependencies (with upstream repos):

- [Amass](https://github.com/owasp-amass/amass)
- [Subfinder](https://github.com/projectdiscovery/subfinder)
- [dnsenum](https://github.com/fwaeytens/dnsenum)
- [theHarvester](https://github.com/laramies/theHarvester)
- [Nmap](https://github.com/nmap/nmap)
- [Masscan](https://github.com/robertdavidgraham/masscan)
- [ffuf](https://github.com/ffuf/ffuf)
- [Gobuster](https://github.com/OJ/gobuster)
- [Wapiti](https://github.com/wapiti-scanner/wapiti)
- [Nikto](https://github.com/sullo/nikto)
- [Nuclei](https://github.com/projectdiscovery/nuclei)
- [SSLyze](https://github.com/nabla-c0d3/sslyze)
- [WPScan](https://github.com/wpscanteam/wpscan)

![uploads_image_UpYqysOocl0kfb3eg874MhJNanIWPi_Krakengif](https://github.com/user-attachments/assets/3ce767ad-ea92-46a0-aee5-997fddabf5f1)

## Contributing

Contributions, issues and module requests are welcome. Read
[CONTRIBUTING.md](CONTRIBUTING.md) for the coding conventions and the
PR checklist, and [docs/ADDING_A_MODULE.md](docs/ADDING_A_MODULE.md)
for the step-by-step recipe to add a new tentacle.

Security issues: see [SECURITY.md](SECURITY.md). Do not file public
issues for vulnerabilities in the wrapper.

## License

[MIT](LICENSE) - feel free to use, modify and redistribute. Please
keep the attribution to Melvin PETIT / WhiteMuush.

## Disclaimer

For educational and authorized security testing only. The author and
maintainers are not responsible for misuse. Always obtain explicit
written permission before testing systems you do not own.

## Links

- Linktree: <https://linktr.ee/melvinpetit>
- Repository: <https://github.com/WhiteMuush/kraken>
