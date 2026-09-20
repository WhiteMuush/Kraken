#!/usr/bin/env bats
# tests/netcaps.bats - raw-socket probe and the safe_nmap wrapper. The real
# nmap binary is stubbed; no scan ever runs.

load 'test_helper'

setup() { load_libs; }

@test "safe_nmap: no --unprivileged when raw sockets are available" {
    has_raw_socket() { return 0; }
    nmap() { echo "NMAP: $*"; }
    run safe_nmap -Pn -sV 10.0.0.1
    [ "$status" -eq 0 ]
    [[ "$output" == *"NMAP: -Pn -sV 10.0.0.1"* ]]
    [[ "$output" != *"--unprivileged"* ]]
}

@test "safe_nmap: prepends --unprivileged when no raw socket" {
    has_raw_socket() { return 1; }
    nmap() { echo "NMAP: $*"; }
    run safe_nmap -Pn -sV 10.0.0.1
    [ "$status" -eq 0 ]
    [[ "$output" == *"NMAP: --unprivileged -Pn -sV 10.0.0.1"* ]]
}

@test "has_raw_socket: non-zero when no probe interpreter is present" {
    local dir saved
    dir="$(mktemp -d)"
    saved="$PATH"
    unset _KRAKEN_RAW_SOCKET
    PATH="$dir"
    run has_raw_socket
    PATH="$saved"
    rm -rf "$dir"
    [ "$status" -ne 0 ]
}
