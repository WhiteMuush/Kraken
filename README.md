# 🐙 Kraken — Modular Bash Penetration Testing Orchestrator

Kraken is a lightweight, modular, Bash-based framework to orchestrate reconnaissance, scanning, enumeration, and reporting. It focuses on automation, parallel execution, and structured output to speed up assessments while remaining easy to extend.

---

## Overview
- Modular "tentacles": each module is independent and replaceable.
- Automation-first: chain tools and tasks into reproducible workflows.
- Lightweight: pure Bash, minimal dependencies.
- Parallel execution and structured output for faster, clearer results.

---

## Quick start

Prerequisites:
- Bash (>= 4.0)
- sudo access for some modules
- Recommended: git, curl/wget, and the tools you plan to use (see Requirements)

Clone, install and run:
```bash
git clone https://github.com/WhiteMuush/kraken.git
cd kraken
chmod +x kraken.sh
sudo bash kraken.sh
```

Tip: Run with --help to see available flags and module options:
```bash
./kraken.sh --help
```

---

## Requirements
Install only the tools you need for your workflow. Common examples:
- amass, subfinder, dnsenum, theHarvester
- nmap, masscan
- ffuf, gobuster, wapiti, nikto
- nuclei, sslyze, wpscan

(Install via your distro package manager or their official installers.)

---

## Usage
- Start an interactive session: sudo bash kraken.sh
- Run a single module or chain modules via CLI options (see --help)
- Output, logs, and state files are saved under the project's output/ directory for easy reporting and review

Example: run reconnaissance then port-scan (pseudo):
```bash
./kraken.sh --modules recon,ports --target example.com
```

---

## Core modules
1. Reconnaissance — subdomains, hosts, DNS discovery (Amass, Subfinder, DNSenum, theHarvester)
2. Port Scanning — fast & detailed scans (Nmap, Masscan)
3. Web Enumeration — directories, tech discovery (ffuf, Gobuster, Wapiti, Nikto)
4. Vulnerability Assessment — pattern/scan-based checks (Nuclei, SSLyze, WPScan)
5. Reporting — structured export of findings, logs and state

Each module is designed to be configurable and easily extended with additional tools or custom scripts.

---

## Contributing
Contributions, issues, and suggestions are welcome.
- Fork the repo
- Create a feature branch
- Add tests/documentation where applicable
- Open a pull request with a clear description

Follow responsible disclosure and avoid including sensitive data in PRs.

---

## License
MIT License — feel free to use, modify, and distribute. Please retain attribution:
Melvin PETIT / WhiteMuush

---

## ⚠️ Disclaimer
For educational and authorized security testing only. The author and maintainers are not responsible for misuse. Always obtain explicit permission before testing systems you do not own.

---

## Links & Contact
Linktree: https://linktr.ee/melvinpetit
Repo: https://github.com/WhiteMuush/kraken

Enjoy — and test responsibly.