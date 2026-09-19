# tests/test_helper.bash - shared bootstrap for the Kraken bats suite.
KRAKEN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
export KRAKEN_ROOT
export TERM="${TERM:-xterm}"

load_libs() {
    # shellcheck source=../lib/core.sh
    source "${KRAKEN_ROOT}/lib/core.sh"
    # shellcheck source=../lib/logger.sh
    source "${KRAKEN_ROOT}/lib/logger.sh"
    # shellcheck source=../lib/installer.sh
    source "${KRAKEN_ROOT}/lib/installer.sh"
}
