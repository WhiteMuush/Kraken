#!/usr/bin/env bats
# tests/compat.bats - lib/compat.sh: host distro detection and the shared
# container bootstrap argument builders. No container is ever launched here.

load 'test_helper'

setup() {
    load_libs
    source "${KRAKEN_ROOT}/lib/compat.sh"
    OSR_DIR="$(mktemp -d)"
}

teardown() {
    rm -rf "${OSR_DIR}"
}

_fake_osr() { printf '%s\n' "$2" > "${OSR_DIR}/$1"; printf '%s' "${OSR_DIR}/$1"; }

@test "distro family: plain Debian is debian" {
    local f; f="$(_fake_osr debian 'ID=debian')"
    [ "$(detect_distro_family "$f")" = "debian" ]
}

@test "distro family: Kali via ID_LIKE is debian" {
    local f; f="$(_fake_osr kali 'ID=kali
ID_LIKE=debian')"
    [ "$(detect_distro_family "$f")" = "debian" ]
}

@test "distro family: Fedora/Bazzite is other" {
    local f; f="$(_fake_osr bazzite 'ID=bazzite
ID_LIKE="fedora"')"
    [ "$(detect_distro_family "$f")" = "other" ]
}

@test "host_is_supported: true on debian family, false otherwise" {
    local deb arch
    deb="$(_fake_osr d 'ID=debian')"
    arch="$(_fake_osr a 'ID=arch')"
    run host_is_supported "$deb";  [ "$status" -eq 0 ]
    run host_is_supported "$arch"; [ "$status" -ne 0 ]
}

@test "container_runtime: returns a known token" {
    run container_runtime
    [[ "$output" =~ ^(podman|docker|none)$ ]]
}

@test "box create args: named, host network, caps, mounts, sleep" {
    run _box_create_args pentest-toolbox debian:stable-slim /host/toolkits /host/engagements
    [[ "$output" == *"--name pentest-toolbox"* ]]
    [[ "$output" == *"--network host"* ]]
    [[ "$output" == *"--cap-add NET_RAW"* ]]
    [[ "$output" == *"/host/toolkits:/opt/toolkits:z"* ]]
    [[ "$output" == *"debian:stable-slim"* ]]
    [[ "$output" == *"sleep infinity"* ]]
}

@test "box_name: shared by default" {
    unset PENTEST_BOX_NAME PENTEST_BOX_DEDICATED
    [ "$(_box_name Kraken)" = "pentest-toolbox" ]
}

@test "box_name: dedicated gives one box per toolkit" {
    unset PENTEST_BOX_NAME
    export PENTEST_BOX_DEDICATED=1
    [ "$(_box_name Kraken)" = "pentest-kraken" ]
}

@test "box_name: an explicit PENTEST_BOX_NAME wins" {
    export PENTEST_BOX_NAME=custom-box PENTEST_BOX_DEDICATED=1
    [ "$(_box_name Kraken)" = "custom-box" ]
}

@test "box exec args: marker env and the toolkit's own entry script" {
    run _box_exec_args pentest-toolbox /opt/toolkits/Kraken/kraken.sh
    [[ "$output" == *"PENTEST_IN_BOX=1"* ]]
    [[ "$output" == *"PENTEST_ENGAGEMENTS=/root/pentest-engagements"* ]]
    [[ "$output" == *"/opt/toolkits/Kraken/kraken.sh"* ]]
}
