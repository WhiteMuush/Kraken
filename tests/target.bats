#!/usr/bin/env bats
# tests/target.bats - lib/core.sh: kraken_valid_target input hardening.

load 'test_helper'

setup() {
    load_libs
}

@test "valid_target: accepts hostnames, IPv4, IPv6 and pre-trimmed URL hosts" {
    kraken_valid_target example.com
    kraken_valid_target scanme.nmap.org
    kraken_valid_target 10.0.0.1
    kraken_valid_target 2001:db8::1
    kraken_valid_target example.com/admin
}

@test "valid_target: rejects an empty target" {
    ! kraken_valid_target ""
}

@test "valid_target: rejects whitespace" {
    ! kraken_valid_target "a b"
    ! kraken_valid_target "$(printf 'a\tb')"
}

@test "valid_target: rejects shell metacharacters" {
    ! kraken_valid_target 'a;rm -rf /'
    ! kraken_valid_target 'a|b'
    ! kraken_valid_target 'a&b'
    ! kraken_valid_target 'a$(id)'
    ! kraken_valid_target 'a`id`'
    ! kraken_valid_target 'a>b'
}

@test "valid_target: rejects characters outside the host-legal set" {
    ! kraken_valid_target 'user@host'
    ! kraken_valid_target 'a,b'
}
