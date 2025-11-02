#!/usr/bin/env bash
# ============================================================================
# KRAKEN - Pentest Orchestration Framework
# ============================================================================
# Author: Melvin PETIT (https://github.com/WhiteMuush)
# Architecture: cw_system_sandevistanedgerunner x64
# Description: Modular framework for automated penetration testing
# ============================================================================

set -euo pipefail

# ============================================================================
# COLOR DEFINITIONS
# ============================================================================
readonly RESET="$(tput sgr0)"
readonly BOLD="$(tput bold)"
readonly DIM="$(tput dim)"

# Standard colors
readonly RED="$(tput setaf 1)"
readonly GREEN="$(tput setaf 2)"
readonly YELLOW="$(tput setaf 3)"
readonly BLUE="$(tput setaf 4)"
readonly MAGENTA="$(tput setaf 5)"
readonly CYAN="$(tput setaf 6)"

# Bright colors
readonly BRIGHT_RED="$(tput setaf 9)"
readonly BRIGHT_GREEN="$(tput setaf 10)"
readonly BRIGHT_YELLOW="$(tput setaf 11)"
readonly BRIGHT_BLUE="$(tput setaf 12)"
readonly BRIGHT_MAGENTA="$(tput setaf 13)"
readonly BRIGHT_CYAN="$(tput setaf 14)"

# ============================================================================
# GLOBAL VARIABLES
# ============================================================================
readonly SCRIPT_VERSION="0.1.0"
readonly SCRIPT_NAME="Kraken Pentest Framework"
readonly OUTPUT_DIR="kraken_output_$(date +%Y%m%d_%H%M%S)"

# ============================================================================
# ASCII ART BANNER
# ============================================================================
readonly ASCII_ART='⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣴⣶⣤⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣠⡤⣤⣄⣾⣿⣿⣿⣿⣿⣿⣷⣠⣀⣄⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠙⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣬⡿⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⣼⠟⢿⣿⣿⣿⣿⣿⣿⡿⠘⣷⣄⠀⠀⠀⠀⠀
⣰⠛⠛⣿⢠⣿⠋⠀⠀⢹⠻⣿⣿⡿⢻⠁⠀⠈⢿⣦⠀⠀⠀⠀
⢈⣵⡾⠋⣿⣯⠀⠀⢀⣼⣷⣿⣿⣶⣷⡀⠀⠀⢸⣿⣀⣀⠀⠀
⢾⣿⣀⠀⠘⠻⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⠿⣿⡁⠀⠀⠀
⠈⠙⠛⠿⠿⠿⢿⣿⡿⣿⣿⡿⢿⣿⣿⣿⣷⣄⠀⠘⢷⣆⠀⠀
⠀⠀⠀⠀⠀⢠⣿⠏⠀⣿⡏⠀⣼⣿⠛⢿⣿⣿⣆⠀⠀⣿⡇⡀
⠀⠀⠀⠀⢀⣾⡟⠀⠀⣿⣇⠀⢿⣿⡀⠈⣿⡌⠻⠷⠾⠿⣻⠁
⠀⠀⣠⣶⠟⠫⣤⠀⠀⢸⣿⠀⣸⣿⢇⡤⢼⣧⠀⠀⠀⢀⣿⠀
⠀⣾⡏⠀⡀⣠⡟⠀⠀⢀⣿⣾⠟⠁⣿⡄⠀⠻⣷⣤⣤⡾⠋⠀
⠀⠙⠷⠾⠁⠻⣧⣀⣤⣾⣿⠋⠀⠀⢸⣧⠀⠀⠀⠉⠁⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠈⠉⠉⠹⣿⣄⠀⠀⣸⡿⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠿⠟⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀'

# ============================================================================
# INFORMATION PANEL
# ============================================================================
readonly INFO_PANEL=(
    ""
    "${BOLD}${BRIGHT_MAGENTA}╔═══════════════════════════════════════════════════╗${RESET}"
    "${BOLD}${BRIGHT_MAGENTA}║${RESET}  ${BOLD}${SCRIPT_NAME} v${SCRIPT_VERSION}${RESET}"
    "${BRIGHT_MAGENTA}║${RESET}  Creator: ${BRIGHT_CYAN}\e]8;;https://github.com/WhiteMuush\aMelvin PETIT\e]8;;\a${RESET}"
    "${BOLD}${BRIGHT_MAGENTA}╚═══════════════════════════════════════════════════╝${RESET}"
    ""
    "${BRIGHT_YELLOW}${BOLD}[!]${RESET} ${DIM}Modular Bash framework for automated pentesting${RESET}"
    "${BRIGHT_YELLOW}${BOLD}[!]${RESET} ${DIM}Orchestrates recon, scanning, enumeration & reporting${RESET}"
    ""
    "${BRIGHT_GREEN}${BOLD}[✓]${RESET} ${GREEN}Use only on authorized targets${RESET}"
    ""
)

# ============================================================================
# MENU OPTIONS
# ============================================================================
readonly MENU_OPTIONS=(
    ""
    "${BRIGHT_MAGENTA}╔══════════════ ${BOLD}MAIN MENU${RESET}${BRIGHT_MAGENTA} ══════════════╗${RESET}"
    "${BRIGHT_MAGENTA}║${RESET}"
    "${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_CYAN}[1]${RESET} Reconnaissance Module"
    "${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_CYAN}[2]${RESET} Port Scanning Module"
    "${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_CYAN}[3]${RESET} Web Enumeration Module"
    "${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_CYAN}[4]${RESET} Vulnerability Assessment"
    "${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_CYAN}[5]${RESET} Report Generation"
    "${BRIGHT_MAGENTA}║${RESET}"
    "${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_YELLOW}[C]${RESET} Configuration"
    "${BRIGHT_MAGENTA}║${RESET}  ${BRIGHT_RED}[Q]${RESET} Quit"
    "${BRIGHT_MAGENTA}║${RESET}"
    "${BRIGHT_MAGENTA}╚════════════════════════════════════════╝${RESET}"
    ""
)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Clear screen and reset cursor
clear_screen() {
    clear
    tput cup 0 0
}

# Print separator line
print_separator() {
    local char="${1:-─}"
    local width
    width=$(tput cols)
    printf "${BRIGHT_MAGENTA}%*s${RESET}\n" "$width" | tr ' ' "$char"
}

# Log message with timestamp
log_message() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        info)    echo "${BRIGHT_BLUE}[i]${RESET} ${timestamp} - ${message}" ;;
        success) echo "${BRIGHT_GREEN}[✓]${RESET} ${timestamp} - ${message}" ;;
        warning) echo "${BRIGHT_YELLOW}[!]${RESET} ${timestamp} - ${message}" ;;
        error)   echo "${BRIGHT_RED}[✗]${RESET} ${timestamp} - ${message}" ;;
        *)       echo "${DIM}[?]${RESET} ${timestamp} - ${message}" ;;
    esac
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Test if target is reachable
test_connectivity() {
    local target="$1"
    if ping -c 1 -W 2 "$target" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# ============================================================================
# DISPLAY FUNCTIONS
# ============================================================================

# Display ASCII art with info panel side-by-side
display_banner() {
    local -a ascii_lines info_lines
    
    IFS=$'\n' read -r -d '' -a ascii_lines <<< "$ASCII_ART" || true
    info_lines=("${INFO_PANEL[@]}")
    
    local ascii_count=${#ascii_lines[@]}
    local info_count=${#info_lines[@]}
    local max_lines=$((ascii_count > info_count ? ascii_count : info_count))
    
    local max_ascii_width=0
    for line in "${ascii_lines[@]}"; do
        ((${#line} > max_ascii_width)) && max_ascii_width=${#line}
    done
    
    local spacing="    "
    
    for ((i=0; i<max_lines; i++)); do
        local ascii_line="${ascii_lines[i]:-}"
        local info_line="${info_lines[i]:-}"
        
        local colored_ascii="${BRIGHT_MAGENTA}${ascii_line}${RESET}"
        local pad=$((max_ascii_width - ${#ascii_line}))
        ((pad < 0)) && pad=0
        
        printf "   %b%*s%s%b\n" \
            "$colored_ascii" \
            "$pad" "" \
            "$spacing" \
            "$info_line"
    done
    
    echo ""
}

# Display main menu
display_menu() {
    for line in "${MENU_OPTIONS[@]}"; do
        echo "$line"
    done
}

# ============================================================================
# MODULE HANDLERS
# ============================================================================

module_recon() {
    clear_screen
    log_message "info" "Launching reconnaissance module..."
    echo ""
    
    # Input
    read -rp "${BRIGHT_CYAN}[?]${RESET} Enter target (domain or IP): " target
    
    if [[ -z "$target" ]]; then
        log_message "error" "No target specified"
        read -rp "${DIM}Press Enter to continue...${RESET}"
        return
    fi
    
    # Setup
    local recon_dir="$OUTPUT_DIR/recon_$target"
    mkdir -p "$recon_dir"
    log_message "success" "Output directory: $recon_dir"
    
    # === Connectivity Test ===
    log_message "info" "Testing connectivity..."
    if test_connectivity "$target"; then
        log_message "success" "Target is reachable"
    else
        log_message "warning" "Target may be unreachable or blocking ICMP"
    fi
    
    # === DNS Enumeration (native bash) ===
    log_message "info" "Performing DNS lookups..."
    {
        echo "# DNS Records for $target - $(date)"
        echo ""
        
        # Using host command (more universal than dig)
        if command_exists host; then
            echo "=== A Records ==="
            host -t A "$target" 2>/dev/null | grep "has address" || echo "No A records found"
            echo ""
            echo "=== MX Records ==="
            host -t MX "$target" 2>/dev/null | grep "mail is handled" || echo "No MX records"
            echo ""
            echo "=== NS Records ==="
            host -t NS "$target" 2>/dev/null | grep "name server" || echo "No NS records"
        elif command_exists nslookup; then
            echo "=== DNS Info (nslookup) ==="
            nslookup "$target" 2>/dev/null || echo "nslookup failed"
        else
            # Fallback: try to resolve with getent
            echo "=== Basic Resolution ==="
            getent hosts "$target" 2>/dev/null || echo "Could not resolve $target"
        fi
    } > "$recon_dir/dns_records.txt"
    log_message "success" "DNS records saved"
    
    # === Subdomain Enumeration ===
    if command_exists subfinder; then
        log_message "info" "Searching subdomains with subfinder..."
        subfinder -d "$target" -o "$recon_dir/subdomains.txt" -silent 2>/dev/null
        local sub_count=$(wc -l < "$recon_dir/subdomains.txt" 2>/dev/null || echo 0)
        log_message "success" "Found $sub_count subdomains"
    else
        log_message "warning" "subfinder not installed (install: go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest)"
    fi
    
    # === WHOIS ===
    if command_exists whois; then
        log_message "info" "Gathering WHOIS information..."
        whois "$target" > "$recon_dir/whois.txt" 2>/dev/null && \
            log_message "success" "WHOIS data saved" || \
            log_message "warning" "WHOIS lookup failed"
    fi
    
    # === Reverse DNS ===
    if command_exists host; then
        log_message "info" "Attempting reverse DNS..."
        local ip=$(host "$target" 2>/dev/null | grep "has address" | head -1 | awk '{print $NF}')
        if [[ -n "$ip" ]]; then
            host "$ip" > "$recon_dir/reverse_dns.txt" 2>/dev/null
            log_message "success" "Reverse DNS completed"
        fi
    fi
    
    # === Summary ===
    echo ""
    print_separator "─"
    log_message "success" "Reconnaissance complete!"
    echo "${BRIGHT_BLUE}Results saved in:${RESET} $recon_dir"
    
    if [[ -d "$recon_dir" ]]; then
        echo ""
        echo "${DIM}Files created:${RESET}"
        ls -lh "$recon_dir" | tail -n +2 | awk '{print "  - " $9 " (" $5 ")"}'
    fi
    
    echo ""
    read -rp "${DIM}Press Enter to continue...${RESET}"
}

module_scan() {
    clear_screen
    log_message "info" "Launching port scanning module..."
    echo ""
    
    read -rp "${BRIGHT_CYAN}[?]${RESET} Enter target IP/domain: " target
    
    if [[ -z "$target" ]]; then
        log_message "error" "No target specified"
        read -rp "${DIM}Press Enter to continue...${RESET}"
        return
    fi
    
    local scan_dir="$OUTPUT_DIR/scan_$target"
    mkdir -p "$scan_dir"
    log_message "success" "Output directory: $scan_dir"
    
    # === Connectivity Test ===
    log_message "info" "Testing connectivity..."
    if test_connectivity "$target"; then
        log_message "success" "Target is reachable"
    else
        log_message "warning" "Target may be blocking ICMP"
    fi
    
    # === Port Scanning ===
    if command_exists nmap; then
        log_message "info" "Scanning with nmap (this may take a while)..."
        echo ""
        
        # Quick scan first
        log_message "info" "Phase 1: Quick scan (top 100 ports)..."
        nmap -Pn -T4 --top-ports 100 "$target" -oN "$scan_dir/nmap_quick.txt" 2>/dev/null
        
        # Service detection on open ports
        log_message "info" "Phase 2: Service version detection..."
        nmap -Pn -sV --open "$target" -oN "$scan_dir/nmap_services.txt" 2>/dev/null
        
        log_message "success" "Nmap scan complete"
        
        # Display results
        echo ""
        echo "${BRIGHT_MAGENTA}═══ Open Ports ═══${RESET}"
        grep "open" "$scan_dir/nmap_services.txt" | grep -v "filtered" | while read -r line; do
            echo "  ${BRIGHT_GREEN}[+]${RESET} $line"
        done
        
    else
        log_message "warning" "nmap not installed, using native bash scan..."
        echo ""
        
        local common_ports=(21 22 23 25 53 80 110 143 443 445 3306 3389 5432 8080 8443)
        local open_count=0
        
        echo "${BRIGHT_MAGENTA}═══ Scanning Common Ports ═══${RESET}"
        for port in "${common_ports[@]}"; do
            if timeout 2 bash -c "echo >/dev/tcp/$target/$port" 2>/dev/null; then
                echo "  ${BRIGHT_GREEN}[+] Port $port: OPEN${RESET}"
                echo "Port $port: OPEN" >> "$scan_dir/bash_scan.txt"
                ((open_count++))
            fi
        done
        
        log_message "success" "Found $open_count open ports"
    fi
    
    # === Summary ===
    echo ""
    print_separator "─"
    log_message "success" "Port scanning complete!"
    echo "${BRIGHT_BLUE}Results saved in:${RESET} $scan_dir"
    echo ""
    read -rp "${DIM}Press Enter to continue...${RESET}"
}

module_web() {
    clear_screen
    log_message "info" "Launching web enumeration module..."
    echo ""
    
    read -rp "${BRIGHT_CYAN}[?]${RESET} Enter target URL (e.g., http://example.com): " url
    
    if [[ -z "$url" ]]; then
        log_message "error" "No URL specified"
        read -rp "${DIM}Press Enter to continue...${RESET}"
        return
    fi
    
    # Ensure URL has protocol
    if [[ ! "$url" =~ ^https?:// ]]; then
        url="http://$url"
        log_message "info" "Assuming http:// protocol"
    fi
    
    local web_dir="$OUTPUT_DIR/web_$(echo "$url" | sed 's|https\?://||' | tr '/:' '_')"
    mkdir -p "$web_dir"
    log_message "success" "Output directory: $web_dir"
    
    # === Connectivity Test ===
    log_message "info" "Testing web server connectivity..."
    if command_exists curl; then
        local status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url" 2>/dev/null)
        if [[ "$status" =~ ^[23] ]]; then
            log_message "success" "Server responded with HTTP $status"
        else
            log_message "warning" "Server responded with HTTP $status"
        fi
    fi
    
    # === HTTP Headers ===
    if command_exists curl; then
        log_message "info" "Fetching HTTP headers..."
        curl -s -I --max-time 10 "$url" > "$web_dir/headers.txt" 2>/dev/null
        log_message "success" "Headers saved"
        
        echo ""
        echo "${BRIGHT_MAGENTA}═══ Server Headers ═══${RESET}"
        head -10 "$web_dir/headers.txt" | while read -r line; do
            echo "  ${DIM}$line${RESET}"
        done
    fi
    
    # === Directory Enumeration ===
    log_message "info" "Testing common directories..."
    local dirs=(
        "admin" "administrator" "login" "dashboard" "panel"
        "backup" "backups" "config" "api" "test" "dev"
        "phpinfo.php" "info.php" ".git" ".env"
    )
    
    echo ""
    echo "${BRIGHT_MAGENTA}═══ Directory Enumeration ═══${RESET}"
    
    {
        echo "# Directory Scan - $(date)"
        echo "# Target: $url"
        echo ""
    } > "$web_dir/directories.txt"
    
    for dir in "${dirs[@]}"; do
        local test_url="$url/$dir"
        if command_exists curl; then
            local status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$test_url" 2>/dev/null)
            
            if [[ "$status" == "200" ]]; then
                echo "  ${BRIGHT_GREEN}[✓] /$dir${RESET} (HTTP $status)"
                echo "FOUND: /$dir (HTTP $status)" >> "$web_dir/directories.txt"
            elif [[ "$status" == "403" ]]; then
                echo "  ${BRIGHT_YELLOW}[!] /$dir${RESET} (HTTP $status - Forbidden)"
                echo "FORBIDDEN: /$dir (HTTP $status)" >> "$web_dir/directories.txt"
            elif [[ "$status" == "401" ]]; then
                echo "  ${BRIGHT_YELLOW}[!] /$dir${RESET} (HTTP $status - Auth Required)"
                echo "AUTH: /$dir (HTTP $status)" >> "$web_dir/directories.txt"
            fi
        fi
    done
    
    # === Technology Detection ===
    if command_exists curl; then
        log_message "info" "Detecting web technologies..."
        local content=$(curl -s --max-time 10 "$url" 2>/dev/null)
        
        {
            echo ""
            echo "# Technology Detection"
            echo ""
            
            echo "$content" | grep -i "wordpress" > /dev/null && echo "- WordPress detected"
            echo "$content" | grep -i "drupal" > /dev/null && echo "- Drupal detected"
            echo "$content" | grep -i "joomla" > /dev/null && echo "- Joomla detected"
            grep -i "server:" "$web_dir/headers.txt" 2>/dev/null
            grep -i "x-powered-by:" "$web_dir/headers.txt" 2>/dev/null
        } >> "$web_dir/technologies.txt"
    fi
    
    # === Robots.txt ===
    if command_exists curl; then
        log_message "info" "Checking robots.txt..."
        if curl -s --max-time 5 "$url/robots.txt" > "$web_dir/robots.txt" 2>/dev/null; then
            if [[ -s "$web_dir/robots.txt" ]]; then
                log_message "success" "robots.txt found"
            fi
        fi
    fi
    
    # === Summary ===
    echo ""
    print_separator "─"
    log_message "success" "Web enumeration complete!"
    echo "${BRIGHT_BLUE}Results saved in:${RESET} $web_dir"
    echo ""
    read -rp "${DIM}Press Enter to continue...${RESET}"
}

module_vuln() {
    clear_screen
    log_message "info" "Launching vulnerability assessment..."
    echo ""
    
    read -rp "${BRIGHT_CYAN}[?]${RESET} Enter target (IP/domain): " target
    
    if [[ -z "$target" ]]; then
        log_message "error" "No target specified"
        read -rp "${DIM}Press Enter to continue...${RESET}"
        return
    fi
    
    local vuln_dir="$OUTPUT_DIR/vuln_$target"
    mkdir -p "$vuln_dir"
    log_message "success" "Output directory: $vuln_dir"
    
    # === SSL/TLS Testing ===
    log_message "info" "Testing SSL/TLS configuration..."
    if command_exists openssl; then
        echo | openssl s_client -connect "$target:443" -servername "$target" 2>/dev/null | \
            openssl x509 -noout -text > "$vuln_dir/ssl_cert.txt" 2>/dev/null && \
            log_message "success" "SSL certificate analyzed" || \
            log_message "warning" "Could not retrieve SSL certificate"
    fi
    
    # === Check for common vulnerabilities ===
    log_message "info" "Checking common misconfigurations..."
    
    echo "${BRIGHT_MAGENTA}═══ Basic Security Checks ═══${RESET}"
    
    {
        echo "# Vulnerability Assessment - $(date)"
        echo "# Target: $target"
        echo ""
    } > "$vuln_dir/findings.txt"
    
    # Check HTTP methods
    if command_exists curl; then
        log_message "info" "Testing HTTP methods..."
        local methods=$(curl -s -X OPTIONS -I "http://$target" 2>/dev/null | grep -i "allow:")
        if [[ -n "$methods" ]]; then
            echo "  ${BRIGHT_YELLOW}[!]${RESET} Allowed HTTP methods: $methods"
            echo "HTTP_METHODS: $methods" >> "$vuln_dir/findings.txt"
        fi
    fi
    
    # Check security headers
    if command_exists curl; then
        log_message "info" "Checking security headers..."
        local headers=$(curl -s -I "http://$target" 2>/dev/null)
        
        if ! echo "$headers" | grep -qi "x-frame-options"; then
            echo "  ${BRIGHT_RED}[✗]${RESET} Missing: X-Frame-Options"
            echo "MISSING_HEADER: X-Frame-Options" >> "$vuln_dir/findings.txt"
        fi
        
        if ! echo "$headers" | grep -qi "content-security-policy"; then
            echo "  ${BRIGHT_RED}[✗]${RESET} Missing: Content-Security-Policy"
            echo "MISSING_HEADER: Content-Security-Policy" >> "$vuln_dir/findings.txt"
        fi
        
        if ! echo "$headers" | grep -qi "strict-transport-security"; then
            echo "  ${BRIGHT_RED}[✗]${RESET} Missing: Strict-Transport-Security"
            echo "MISSING_HEADER: Strict-Transport-Security" >> "$vuln_dir/findings.txt"
        fi
        
        if echo "$headers" | grep -qi "server:"; then
            local server=$(echo "$headers" | grep -i "server:" | head -1)
            echo "  ${BRIGHT_YELLOW}[!]${RESET} Server banner exposed: $server"
            echo "INFO_DISCLOSURE: $server" >> "$vuln_dir/findings.txt"
        fi
    fi
    
    # === Summary ===
    echo ""
    print_separator "─"
    log_message "success" "Vulnerability assessment complete!"
    echo "${BRIGHT_BLUE}Results saved in:${RESET} $vuln_dir"
    echo ""
    echo "${DIM}Note: This is a basic assessment. Use specialized tools for in-depth testing.${RESET}"
    echo ""
    read -rp "${DIM}Press Enter to continue...${RESET}"
}

module_report() {
    clear_screen
    log_message "info" "Generating comprehensive report..."
    echo ""
    
    if [[ ! -d "$OUTPUT_DIR" ]]; then
        log_message "error" "No output directory found. Run scans first."
        read -rp "${DIM}Press Enter to continue...${RESET}"
        return
    fi
    
    local report_file="$OUTPUT_DIR/kraken_report_$(date +%Y%m%d_%H%M%S).html"
    
    log_message "info" "Collecting scan data..."
    
    # Generate HTML report
    cat > "$report_file" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Kraken Pentest Report</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            color: #333;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px;
            text-align: center;
        }
        .header h1 { font-size: 2.5em; margin-bottom: 10px; }
        .header p { opacity: 0.9; }
        .content { padding: 40px; }
        .section {
            margin-bottom: 30px;
            padding: 20px;
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            border-radius: 5px;
        }
        .section h2 {
            color: #667eea;
            margin-bottom: 15px;
            font-size: 1.5em;
        }
        .finding {
            padding: 15px;
            background: white;
            margin: 10px 0;
            border-radius: 5px;
            border-left: 3px solid #28a745;
        }
        .finding.critical { border-left-color: #dc3545; }
        .finding.high { border-left-color: #fd7e14; }
        .finding.medium { border-left-color: #ffc107; }
        .finding.low { border-left-color: #17a2b8; }
        .finding.info { border-left-color: #6c757d; }
        .badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 3px;
            font-size: 0.85em;
            font-weight: bold;
            margin-right: 10px;
        }
        .badge.critical { background: #dc3545; color: white; }
        .badge.high { background: #fd7e14; color: white; }
        .badge.medium { background: #ffc107; color: #333; }
        .badge.low { background: #17a2b8; color: white; }
        .badge.info { background: #6c757d; color: white; }
        pre {
            background: #2d2d2d;
            color: #f8f8f2;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
            font-size: 0.9em;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .stat-card .number {
            font-size: 2.5em;
            font-weight: bold;
            color: #667eea;
        }
        .stat-card .label {
            color: #6c757d;
            margin-top: 10px;
        }
        .footer {
            background: #f8f9fa;
            padding: 20px;
            text-align: center;
            color: #6c757d;
            border-top: 1px solid #dee2e6;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
            background: white;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #dee2e6;
        }
        th {
            background: #667eea;
            color: white;
            font-weight: 600;
        }
        tr:hover { background: #f8f9fa; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🐙 Kraken Pentest Report</h1>
            <p>Generated on DATE_PLACEHOLDER</p>
            <p>Operator: USER_PLACEHOLDER</p>
        </div>
        
        <div class="content">
            <div class="section">
                <h2>Executive Summary</h2>
                <div class="stats">
                    <div class="stat-card">
                        <div class="number" id="total-findings">0</div>
                        <div class="label">Total Findings</div>
                    </div>
                    <div class="stat-card">
                        <div class="number" id="hosts-scanned">0</div>
                        <div class="label">Hosts Scanned</div>
                    </div>
                    <div class="stat-card">
                        <div class="number" id="ports-found">0</div>
                        <div class="label">Open Ports</div>
                    </div>
                    <div class="stat-card">
                        <div class="number" id="vulnerabilities">0</div>
                        <div class="label">Vulnerabilities</div>
                    </div>
                </div>
            </div>

            <div class="section">
                <h2>Scope</h2>
                <p><strong>Target(s):</strong> TARGETS_PLACEHOLDER</p>
                <p><strong>Output Directory:</strong> <code>OUTPUT_DIR_PLACEHOLDER</code></p>
            </div>

            <div class="section">
                <h2>Reconnaissance Results</h2>
                RECON_RESULTS_PLACEHOLDER
            </div>

            <div class="section">
                <h2>Port Scanning Results</h2>
                SCAN_RESULTS_PLACEHOLDER
            </div>

            <div class="section">
                <h2>Web Enumeration Results</h2>
                WEB_RESULTS_PLACEHOLDER
            </div>

            <div class="section">
                <h2>Vulnerability Assessment</h2>
                VULN_RESULTS_PLACEHOLDER
            </div>

            <div class="section">
                <h2>Recommendations</h2>
                <ul>
                    <li>Review and patch all identified vulnerabilities</li>
                    <li>Implement missing security headers</li>
                    <li>Disable unnecessary services and ports</li>
                    <li>Regular security audits and penetration testing</li>
                    <li>Keep all systems and software up to date</li>
                </ul>
            </div>
        </div>

        <div class="footer">
            <p>Generated by <strong>Kraken Pentest Framework v1.0.0</strong></p>
            <p>For authorized security testing only</p>
        </div>
    </div>
</body>
</html>
EOF

    # Replace placeholders
    sed -i "s|DATE_PLACEHOLDER|$(date '+%Y-%m-%d %H:%M:%S')|g" "$report_file"
    sed -i "s|USER_PLACEHOLDER|$(whoami)|g" "$report_file"
    sed -i "s|OUTPUT_DIR_PLACEHOLDER|$OUTPUT_DIR|g" "$report_file"
    
    # Collect targets
    local targets=$(find "$OUTPUT_DIR" -type d -name "recon_*" -o -name "scan_*" -o -name "web_*" | \
                    sed 's|.*/[^_]*_||' | sort -u | tr '\n' ', ' | sed 's/,$//')
    sed -i "s|TARGETS_PLACEHOLDER|${targets:-None}|g" "$report_file"
    
    # Process recon results
    local recon_html="<p>No reconnaissance data found.</p>"
    if ls "$OUTPUT_DIR"/recon_* &>/dev/null; then
        recon_html="<table><tr><th>Target</th><th>Subdomains</th><th>DNS Records</th></tr>"
        for dir in "$OUTPUT_DIR"/recon_*; do
            local target=$(basename "$dir" | sed 's/recon_//')
            local sub_count="N/A"
            local dns_count="N/A"
            
            [[ -f "$dir/subdomains.txt" ]] && sub_count=$(wc -l < "$dir/subdomains.txt")
            [[ -f "$dir/dns_records.txt" ]] && dns_count=$(grep -c "===" "$dir/dns_records.txt" || echo "N/A")
            
            recon_html+="<tr><td>$target</td><td>$sub_count</td><td>$dns_count</td></tr>"
        done
        recon_html+="</table>"
    fi
    sed -i "s|RECON_RESULTS_PLACEHOLDER|$recon_html|g" "$report_file"
    
    # Process scan results
    local scan_html="<p>No port scan data found.</p>"
    if ls "$OUTPUT_DIR"/scan_* &>/dev/null; then
        scan_html="<table><tr><th>Target</th><th>Open Ports</th><th>Services</th></tr>"
        for dir in "$OUTPUT_DIR"/scan_*; do
            local target=$(basename "$dir" | sed 's/scan_//')
            local port_count=0
            local services=""
            
            if [[ -f "$dir/nmap_services.txt" ]]; then
                port_count=$(grep -c "open" "$dir/nmap_services.txt" 2>/dev/null || echo 0)
                services=$(grep "open" "$dir/nmap_services.txt" | head -3 | awk '{print $1}' | tr '\n' ', ' | sed 's/,$//')
            elif [[ -f "$dir/bash_scan.txt" ]]; then
                port_count=$(wc -l < "$dir/bash_scan.txt")
                services=$(cut -d: -f1 "$dir/bash_scan.txt" | tr '\n' ', ' | sed 's/,$//')
            fi
            
            scan_html+="<tr><td>$target</td><td>$port_count</td><td>${services:-None}</td></tr>"
        done
        scan_html+="</table>"
    fi
    sed -i "s|SCAN_RESULTS_PLACEHOLDER|$scan_html|g" "$report_file"
    
    # Process web results
    local web_html="<p>No web enumeration data found.</p>"
    if ls "$OUTPUT_DIR"/web_* &>/dev/null; then
        web_html="<table><tr><th>Target</th><th>HTTP Status</th><th>Directories Found</th></tr>"
        for dir in "$OUTPUT_DIR"/web_*; do
            local target=$(basename "$dir" | sed 's/web_//')
            local status="N/A"
            local dir_count=0
            
            [[ -f "$dir/headers.txt" ]] && status=$(head -1 "$dir/headers.txt" | awk '{print $2}')
            [[ -f "$dir/directories.txt" ]] && dir_count=$(grep -c "FOUND:" "$dir/directories.txt" 2>/dev/null || echo 0)
            
            web_html+="<tr><td>$target</td><td>$status</td><td>$dir_count</td></tr>"
        done
        web_html+="</table>"
    fi
    sed -i "s|WEB_RESULTS_PLACEHOLDER|$web_html|g" "$report_file"
    
    # Process vulnerability results
    local vuln_html="<p>No vulnerability assessment data found.</p>"
    if ls "$OUTPUT_DIR"/vuln_* &>/dev/null; then
        vuln_html=""
        for dir in "$OUTPUT_DIR"/vuln_*; do
            local target=$(basename "$dir" | sed 's/vuln_//')
            vuln_html+="<h3>Target: $target</h3>"
            
            if [[ -f "$dir/findings.txt" ]]; then
                vuln_html+="<div class='finding medium'>"
                vuln_html+="<span class='badge medium'>MEDIUM</span>"
                vuln_html+="<strong>Security Findings:</strong><br>"
                vuln_html+="<pre>$(cat "$dir/findings.txt" | head -20)</pre>"
                vuln_html+="</div>"
            else
                vuln_html+="<p>No findings recorded.</p>"
            fi
        done
    fi
    sed -i "s|VULN_RESULTS_PLACEHOLDER|$vuln_html|g" "$report_file"
    
    # Update statistics
    local total_findings=$(find "$OUTPUT_DIR" -name "findings.txt" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}' || echo 0)
    local hosts_scanned=$(find "$OUTPUT_DIR" -type d \( -name "recon_*" -o -name "scan_*" \) | wc -l)
    local ports_found=$(find "$OUTPUT_DIR" -name "*scan*.txt" -exec grep -h "open" {} + 2>/dev/null | wc -l || echo 0)
    
    sed -i "s|<div class=\"number\" id=\"total-findings\">0</div>|<div class=\"number\" id=\"total-findings\">$total_findings</div>|g" "$report_file"
    sed -i "s|<div class=\"number\" id=\"hosts-scanned\">0</div>|<div class=\"number\" id=\"hosts-scanned\">$hosts_scanned</div>|g" "$report_file"
    sed -i "s|<div class=\"number\" id=\"ports-found\">0</div>|<div class=\"number\" id=\"ports-found\">$ports_found</div>|g" "$report_file"
    sed -i "s|<div class=\"number\" id=\"vulnerabilities\">0</div>|<div class=\"number\" id=\"vulnerabilities\">$total_findings</div>|g" "$report_file"
    
    log_message "success" "HTML report generated!"
    echo ""
    echo "${BRIGHT_GREEN}Report saved to:${RESET}"
    echo "  ${BRIGHT_BLUE}$report_file${RESET}"
    echo ""
    
    # Offer to open in browser
    read -rp "${BRIGHT_CYAN}[?]${RESET} Open report in browser? (y/N): " open_browser
    if [[ "${open_browser,,}" == "y" ]]; then
        if command_exists xdg-open; then
            xdg-open "$report_file" &>/dev/null &
        elif command_exists open; then
            open "$report_file" &>/dev/null &
        elif command_exists firefox; then
            firefox "$report_file" &>/dev/null &
        else
            log_message "warning" "Could not detect browser. Open manually: $report_file"
        fi
    fi
    
    echo ""
    read -rp "${DIM}Press Enter to continue...${RESET}"
}

show_config() {
    clear_screen
    echo "${BRIGHT_MAGENTA}${BOLD}╔═══════════════════════════════════════╗${RESET}"
    echo "${BRIGHT_MAGENTA}${BOLD}║         Configuration Info           ║${RESET}"
    echo "${BRIGHT_MAGENTA}${BOLD}╚═══════════════════════════════════════╝${RESET}"
    echo ""
    
    echo "${BRIGHT_CYAN}General:${RESET}"
    echo "  Script Version    : ${BRIGHT_BLUE}$SCRIPT_VERSION${RESET}"
    echo "  Current User      : ${BRIGHT_BLUE}$(whoami)${RESET}"
    echo "  Working Directory : ${BRIGHT_BLUE}$(pwd)${RESET}"
    echo "  Output Directory  : ${BRIGHT_BLUE}$OUTPUT_DIR${RESET}"
    echo ""
    
    echo "${BRIGHT_CYAN}Available Tools:${RESET}"
    local tools=("nmap" "curl" "host" "whois" "subfinder" "ping" "openssl")
    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            echo "  ${BRIGHT_GREEN}[✓]${RESET} $tool"
        else
            echo "  ${BRIGHT_RED}[✗]${RESET} $tool ${DIM}(not installed)${RESET}"
        fi
    done
    echo ""
    
    echo "${BRIGHT_CYAN}System Info:${RESET}"
    echo "  Hostname          : ${BRIGHT_BLUE}$(hostname)${RESET}"
    echo "  Kernel            : ${BRIGHT_BLUE}$(uname -r)${RESET}"
    echo "  Shell             : ${BRIGHT_BLUE}$SHELL${RESET}"
    echo ""
    
    if [[ -d "$OUTPUT_DIR" ]]; then
        echo "${BRIGHT_CYAN}Current Session:${RESET}"
        local scan_count=$(find "$OUTPUT_DIR" -type d -maxdepth 1 | wc -l)
        echo "  Scans Performed   : ${BRIGHT_BLUE}$((scan_count - 1))${RESET}"
        echo "  Total Size        : ${BRIGHT_BLUE}$(du -sh "$OUTPUT_DIR" 2>/dev/null | cut -f1)${RESET}"
    fi
    
    echo ""
    print_separator "─"
    echo ""
    read -rp "${DIM}Press Enter to continue...${RESET}"
}

# ============================================================================
# INPUT HANDLER
# ============================================================================

handle_selection() {
    local choice="$1"
    
    case "${choice,,}" in
        1) module_recon ;;
        2) module_scan ;;
        3) module_web ;;
        4) module_vuln ;;
        5) module_report ;;
        c|config) show_config ;;
        q|quit|exit)
            echo ""
            log_message "info" "Shutting down Kraken..."
            echo "${BRIGHT_MAGENTA}${BOLD}Thanks for using Kraken! 🐙${RESET}"
            echo ""
            exit 0
            ;;
        "")
            return
            ;;
        *)
            log_message "error" "Invalid option: $choice"
            sleep 1
            ;;
    esac
}

# ============================================================================
# MAIN LOOP
# ============================================================================

main_loop() {
    while true; do
        clear_screen
        display_banner
        display_menu
        
        read -rp " ${BRIGHT_MAGENTA}$(whoami)@Kraken${RESET}:~${BRIGHT_BLUE}$ ${RESET}" choice
        echo ""
        
        handle_selection "$choice"
    done
}

# ============================================================================
# INITIALIZATION & ENTRY POINT
# ============================================================================

# Check dependencies on startup
check_dependencies() {
    local missing_critical=()
    
    # Check for absolutely required tools
    if ! command_exists bash; then
        echo "ERROR: Bash is required"
        exit 1
    fi
    
    # Warn about missing optional tools
    local recommended=("nmap" "curl" "host")
    for tool in "${recommended[@]}"; do
        if ! command_exists "$tool"; then
            missing_critical+=("$tool")
        fi
    done
    
    if [[ ${#missing_critical[@]} -gt 0 ]]; then
        clear
        log_message "warning" "Some recommended tools are missing:"
        for tool in "${missing_critical[@]}"; do
            echo "  ${BRIGHT_YELLOW}[!]${RESET} $tool"
        done
        echo ""
        echo "${DIM}Kraken will work with reduced functionality.${RESET}"
        echo "${DIM}Install missing tools for full features.${RESET}"
        echo ""
        read -rp "${DIM}Press Enter to continue anyway...${RESET}"
    fi
}

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check if running as root (warning)
if [[ $EUID -eq 0 ]]; then
    clear
    log_message "warning" "Running as root - proceed with caution!"
    sleep 2
fi

# Check dependencies
check_dependencies

# Start main loop
main_loop