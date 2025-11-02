# Kraken — Pentest Orchestration Framework

Kraken is a modular bash framework to automate common reconnaissance, scanning, web enumeration and report generation tasks. Designed for use only in authorized environments.

Author: Melvin PETIT  
Embedded version: 0.1.0

## Key features
- ASCII banner and simple TUI
- Modular modules:
    - Reconnaissance (DNS, whois, subdomains)
    - Port scanning (nmap or basic bash scan)
    - Web enumeration (headers, directories, robots.txt, technology detection)
    - Basic vulnerability assessment (headers, SSL)
    - Consolidated HTML report generation
- Automatic saving of results into a timestamped output directory

## Requirements
Recommended tools (for full functionality):
- bash (required)
- nmap
- curl
- host (or nslookup/getent)
- whois
- openssl
- subfinder (optional for subdomain enumeration)

Install packages via your distribution package manager as needed.

## Quick start
1. Make the script executable:
    ```bash
    chmod +x kraken.sh
    ```
2. Run Kraken:
    ```bash
    ./kraken.sh
    ```
3. Use the menu to choose a module (Recon, Scan, Web, Vuln, Report).

Results are saved under a directory created at runtime: `kraken_output_YYYYMMDD_HHMMSS/`.

## Output structure
- recon_<target>/ — dns_records.txt, subdomains.txt, whois.txt, ...
- scan_<target>/ — nmap_quick.txt, nmap_services.txt or bash_scan.txt
- web_<target>/ — headers.txt, directories.txt, technologies.txt, robots.txt
- vuln_<target>/ — ssl_cert.txt, findings.txt
- kraken_report_<timestamp>.html — consolidated HTML report

## Configuration & tool detection
The script displays the status of available tools at startup. Kraken runs with reduced functionality if some tools are missing.

## Best practices & legal warning
- Only use Kraken against targets for which you have explicit authorization.
- Respect the law and professional ethical guidelines.
- This framework performs intrusive actions (scans, requests) — test in a controlled environment.

---

Kraken provides a practical starting point for automating pentest orchestration tasks. Adapt and extend it according to your needs and legal constraints.