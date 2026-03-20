#!/usr/bin/env bash

set -euo pipefail

PASS=0
FAIL=0
SHMAKE="./shMakefile"

_green='\033[32m'
_red='\033[31m'
_reset='\033[0m'

# assert_eq "test name" "expected value" "actual value"
# Passes if expected == actual (exact string match)
assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [[ "$actual" == "$expected" ]]; then
    echo -e "  ${_green}PASS${_reset}  $desc"
    PASS=$((PASS+1))
  else
    echo -e "  ${_red}FAIL${_reset}  $desc"
    echo    "        expected: $(echo "$expected" | head -1)"
    echo    "        actual:   $(echo "$actual"   | head -1)"
    FAIL=$((FAIL+1))
  fi
}

# assert_exit "test name" <exit_code> <command> [args...]
# Passes if the command exits with the expected exit code
# Ex: assert_exit "should fail" 123 ./shMakefile alice
assert_exit() {
  local desc="$1" expected_code="$2"
  shift 2
  local actual_code=0
  "$@" &>/dev/null || actual_code=$?
  assert_eq "$desc" "$expected_code" "$actual_code"
}

# assert_contains "test name" "needle" "$output"
# Passes if needle is found in output (output must be pre-captured in a variable)
# Ex: out=$(./shMakefile --help); assert_contains "has alice" "alice" "$out"
assert_contains() {
  local desc="$1" needle="$2" haystack="$3"
  if echo "$haystack" | grep -qF "$needle"; then
    echo -e "  ${_green}PASS${_reset}  $desc"
    PASS=$((PASS+1))
  else
    echo -e "  ${_red}FAIL${_reset}  $desc"
    echo    "        expected to contain: $needle"
    FAIL=$((FAIL+1))
  fi
}

# assert_not_contains "test name" "needle" "$output"
# Passes if needle is NOT found in output (output must be pre-captured in a variable)
# Ex: out=$(./shMakefile --help); assert_not_contains "no _foo" "_foo" "$out"
assert_not_contains() {
  local desc="$1" needle="$2" haystack="$3"
  if echo "$haystack" | grep -qF "$needle"; then
    echo -e "  ${_red}FAIL${_reset}  $desc"
    echo    "        expected NOT to contain: $needle"
    FAIL=$((FAIL+1))
  else
    echo -e "  ${_green}PASS${_reset}  $desc"
    PASS=$((PASS+1))
  fi
}

#

# ---------------------------------------------------------------------------
echo "=== functions.sh: increment_semver ==="

source ./functions.sh

assert_eq "increments patch"         "1.2.4" "$(increment_semver 1.2.3)"
assert_eq "increments from zero"     "0.0.1" "$(increment_semver 0.0.0)"
assert_eq "increments minor release" "2.1.1" "$(increment_semver 2.1.0)"

# ---------------------------------------------------------------------------
echo ""
echo "=== functions.sh: mustVar ==="

assert_exit "passes when var is set"    0   bash -c 'source ./functions.sh; env=prod mustVar env'
assert_exit "exits 123 when var unset" 123  bash -c 'source ./functions.sh; mustVar env'

# mustVar with allowed values
assert_exit "passes when value is in allowed list"   0   bash -c 'source ./functions.sh; env=prod mustVar env prod staging'
assert_exit "exits 124 when value not in allowed list" 124 bash -c 'source ./functions.sh; env=dev mustVar env prod staging'

# ---------------------------------------------------------------------------
echo ""
echo "=== shMakefile: argument parsing ==="

assert_eq  "alice with --env"          "alice prod " "$($SHMAKE alice --env=prod)"
assert_eq  "alice with --env and --name" "alice prod mario" "$($SHMAKE alice --env=prod --name=mario)"
assert_eq  "bob with --env"            "bob staging"          "$($SHMAKE bob --env=staging)"

assert_exit "missing required var exits 123" 123 $SHMAKE alice

# ---------------------------------------------------------------------------
echo ""
echo "=== shMakefile: --help ==="

help_out=$($SHMAKE --help 2>&1 || true)
assert_contains     "--help shows Usage line"      "Usage:"     "$help_out"
assert_contains     "--help lists alice"           "alice"      "$help_out"
assert_contains     "--help lists bob"             "bob"        "$help_out"
assert_not_contains "--help hides _show-help"      "_show-help" "$help_out"

# ---------------------------------------------------------------------------
echo ""
echo "=== shMakefile: submodule loading ==="

# test-data/shMakefile defines inner-func; it should be sourced since it's not in examples/
assert_exit "inner-func from test-data is available" 0 $SHMAKE inner-func --aval=hello

# functions from examples/ must NOT be loaded (excluded by glob filter)
examples_func_out=$($SHMAKE --help 2>&1 || true)
assert_not_contains "examples/ functions are not imported" "example-only-func" "$examples_func_out"

# ---------------------------------------------------------------------------
echo ""
echo "=== Results ==="
echo -e "  ${_green}$PASS passed${_reset}, ${_red}$FAIL failed${_reset}"
echo ""

[[ $FAIL -eq 0 ]]
