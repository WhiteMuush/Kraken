# Kraken

[![CI](https://github.com/WhiteMuush/kraken/actions/workflows/ci.yml/badge.svg)](https://github.com/WhiteMuush/kraken/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Shell: bash](https://img.shields.io/badge/Shell-bash%20%E2%89%A5%204.0-1f425f.svg)](https://www.gnu.org/software/bash/)
[![Wiki](https://img.shields.io/badge/docs-wiki-blue.svg)](https://github.com/WhiteMuush/Kraken/wiki)

**Kraken** chains reconnaissance, port scanning, web enumeration, vulnerability
checks and reporting into one interactive Bash menu. Pure Bash, no Python
runtime, structured per-session output, and every module degrades gracefully
when a tool is missing so you install only what you need.

> 📖 Full docs (install, usage, per-module guides, configuration, output layout,
> extending) live in the **[Kraken Wiki](https://github.com/WhiteMuush/Kraken/wiki)**.
> This README is the quick overview.

<img width="989" height="684" alt="Kraken" src="https://github.com/user-attachments/assets/6363c6a6-8cf4-439e-8674-b516cf6876bc" />

## Quick start

```bash
git clone https://github.com/WhiteMuush/kraken.git
cd kraken && chmod +x kraken.sh
sudo ./kraken.sh          # sudo lets nmap run SYN scans natively
```

Runs natively on Debian/Kali. On any other distro it runs inside a shared
Debian box (podman/docker), reused across toolkits; there nmap falls back to an
unprivileged connect scan automatically, so a scan never dies on a missing raw
socket. See [docs/DISTRO_COMPAT.md](docs/DISTRO_COMPAT.md). `--help` and
`--version` are also available.

## Modules

| Key | Module | What it does |
|-----|--------|--------------|
| 1 | Reconnaissance | DNS records, subdomain enumeration, WHOIS, reverse DNS |
| 2 | Port scanning | nmap quick scan + service detection, `/dev/tcp` fallback when nmap is absent |
| 3 | Web enumeration | HTTP headers, common directories, technology detection, robots.txt |
| 4 | Vulnerability | SSL/TLS, allowed methods, missing security headers |
| 5 | Report | Aggregate the current session into a single text report |

Each run writes one folder per session, one subfolder per module/target, and a
final aggregated report.

## Project layout

```
kraken.sh          entry point (~100 lines)
lib/
  core.sh          version, globals, TTY-aware colors
  logger.sh        log_step / log_info / log_warn / log_error / log_success
  installer.sh     ensure_command, ensure_repo, prompts, raw-socket helpers
  ui.sh            banner, info panel, main menu, config view
  session.sh       session bootstrap, connectivity test
  modules/         recon, scan, web, vuln, report
docs/              ARCHITECTURE.md, ADDING_A_MODULE.md
```

## Requirements

Bash >= 4.0, plus only the tools you plan to use, Kraken degrades gracefully
when one is missing. Common external tools:
[Nmap](https://github.com/nmap/nmap),
[Masscan](https://github.com/robertdavidgraham/masscan),
[Amass](https://github.com/owasp-amass/amass),
[Subfinder](https://github.com/projectdiscovery/subfinder),
[dnsenum](https://github.com/fwaeytens/dnsenum),
[theHarvester](https://github.com/laramies/theHarvester),
[ffuf](https://github.com/ffuf/ffuf),
[Gobuster](https://github.com/OJ/gobuster),
[Wapiti](https://github.com/wapiti-scanner/wapiti),
[Nikto](https://github.com/sullo/nikto),
[Nuclei](https://github.com/projectdiscovery/nuclei),
[SSLyze](https://github.com/nabla-c0d3/sslyze),
[WPScan](https://github.com/wpscanteam/wpscan).
Full list in [requirements.txt](requirements.txt).

![Kraken demo](https://github.com/user-attachments/assets/3ce767ad-ea92-46a0-aee5-997fddabf5f1)

## Contributing

PRs, issues and module requests welcome. See [CONTRIBUTING.md](CONTRIBUTING.md)
for conventions and the checklist, and
[docs/ADDING_A_MODULE.md](docs/ADDING_A_MODULE.md) to add a new tentacle in a
few lines. Security issues go private via [SECURITY.md](SECURITY.md), not public
issues.

## License

[MIT](LICENSE). Use, modify and redistribute freely, keep the attribution to
Melvin PETIT / WhiteMuush.

## Disclaimer

For educational and authorized security testing only. Always get explicit
written permission before testing systems you do not own. The maintainers are
not responsible for misuse.

## Links

- Wiki: <https://github.com/WhiteMuush/Kraken/wiki>
- Linktree: <https://linktr.ee/melvinpetit>
