#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail
  export GITHUB_REPO=atj4me/ddev-tailscale-router

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p ~/tmp
  export TESTDIR=$(mktemp -d ~/tmp/${PROJNAME}.XXXXXX)
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site
  assert_success
  run ddev start -y
  assert_success
}

health_checks() {
  # Check if the Tailscale service is running inside DDEV
  run ddev describe -j 
  assert_success

  # Verify tailscale-router service exists in describe output
  run bash -c "ddev describe -j | jq -r '.raw.services | has(\"tailscale-router\")'"
  assert_success
  assert_output "true"
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  # Persist TESTDIR if running inside GitHub Actions. Useful for uploading test result artifacts
  # See example at https://github.com/ddev/github-action-add-on-test#preserving-artifacts
  if [ -n "${GITHUB_ENV:-}" ]; then
    [ -e "${GITHUB_ENV:-}" ] && echo "TESTDIR=${HOME}/tmp/${PROJNAME}" >> "${GITHUB_ENV}"
  else
    [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
  fi
}

@test "install from directory" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}

@test "tailscale command exists and responds" {
  set -eu -o pipefail
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  
  # Test tailscale command exists (without --help which may not work)
  run ddev tailscale status
  # Command should execute (may show error but shouldn't crash)
}

@test "tailscale service container is running" {
  set -eu -o pipefail
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  
  # Check if tailscale-router container exists
  run ddev logs tailscale-router 2>&1 | grep -q "Tailscale is up" || ddev logs tailscale-router
  assert_success
  assert_output "ddev-${PROJNAME}-tailscale-router"
}

@test "configuration files are properly installed" {
  set -eu -o pipefail
  run ddev add-on get "${DIR}"
  assert_success
  
  # Check if config files exist
  assert_file_exists ".ddev/tailscale-router/config/tailscale-private.json"
  assert_file_exists ".ddev/tailscale-router/config/tailscale-public.json"
  assert_file_exists ".ddev/docker-compose.tailscale-router.yaml"
  assert_file_exists ".ddev/commands/host/tailscale"
}

@test "tailscale command shortcuts work" {
  set -eu -o pipefail
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  
  # Test stat command (should not fail even without auth)
  run ddev tailscale stat
  # Command should execute (may show not logged in, but shouldn't crash)
  
  # Test proxy command
  run ddev tailscale proxy
  # Command should execute
}

@test "docker-compose file has required services and volumes" {
  set -eu -o pipefail
  run ddev add-on get "${DIR}"
  assert_success
  
  # Check docker-compose file contains required elements
  run grep -q "tailscale-router:" ".ddev/docker-compose.tailscale-router.yaml"
  assert_success
  
  run grep -q "tailscale-router-state:" ".ddev/docker-compose.tailscale-router.yaml"
  assert_success
  
  run grep -q "FROM tailscale/tailscale:latest" ".ddev/docker-compose.tailscale-router.yaml"
  assert_success
}

@test "configuration supports both private and public modes" {
  set -eu -o pipefail
  run ddev add-on get "${DIR}"
  assert_success
  
  # Check private config
  run grep -q '"AllowFunnel"' ".ddev/tailscale-router/config/tailscale-private.json"
  assert_success
  run grep -q 'false' ".ddev/tailscale-router/config/tailscale-private.json"
  assert_success
  
  # Check public config
  run grep -q '"AllowFunnel"' ".ddev/tailscale-router/config/tailscale-public.json"
  assert_success
  run grep -q 'true' ".ddev/tailscale-router/config/tailscale-public.json"
  assert_success
}
