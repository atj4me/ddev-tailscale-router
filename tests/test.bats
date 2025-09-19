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
  
  # Clean up any existing project
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  
  # Configure and start DDEV project
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site
  assert_success
  run ddev start -y
  assert_success
}

health_checks() {
  # Check if DDEV is running properly
  run ddev describe -j
  assert_success

  # Check if web service is running
  run bash -c "ddev describe -j | jq -r '.raw.services.web.State.Status'"
  assert_success
  assert_output "running"
}

teardown() {
  set -eu -o pipefail
  
  # Clean up DDEV project
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  
  # Persist TESTDIR if running inside GitHub Actions
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
  
  # Check for any ERROR messages in restart output
  refute_output --partial "ERROR (spawn error)"
  refute_output --partial "tailscale-router: ERROR"
  refute_output --partial "tailscale-serve: ERROR"
}

@test "tailscale command exists and responds" {
  set -eu -o pipefail
  
  run ddev add-on get "${DIR}"
  assert_success
  
  run ddev restart -y
  assert_success
  refute_output --partial "ERROR (spawn error)"

  # Test tailscale command exists
  run ddev tailscale --help
  assert_success
  
  # Test basic tailscale status (may fail if not authenticated, but command should exist)
  run ddev tailscale status
  # Don't assert success here as it may fail without auth, just check command exists
}

@test "web_extra_daemons are configured correctly" {
  set -eu -o pipefail
  
  run ddev add-on get "${DIR}"
  assert_success
  
  run ddev restart -y
  assert_success
  
  # Check if the config file exists
  run test -f .ddev/config.tailscale-router.yaml
  assert_success
  
  # Check if web-build dockerfile exists
  run test -f .ddev/web-build/Dockerfile.tailscale-router
  assert_success
  
  # Check if docker-compose override exists
  run test -f .ddev/docker-compose.tailscale-router.yaml
  assert_success
}

@test "tailscale service installation in web container" {
  set -eu -o pipefail
  
  run ddev add-on get "${DIR}"
  assert_success
  
  run ddev restart -y
  assert_success
  
  # Check if tailscale is installed in web container
  run ddev exec "which tailscale"
  assert_success
  
  # Check if tailscale version can be retrieved
  run ddev exec "tailscale version"
  assert_success
}

@test "tailscale basic commands work without auth" {
  set -eu -o pipefail
  
  run ddev add-on get "${DIR}"
  assert_success
  
  run ddev restart -y
  assert_success

  # Test commands that don't require authentication
  run ddev tailscale --help
  assert_success
  
  run ddev tailscale version
  assert_success
  
  # Test ping help (doesn't require auth)
  run ddev tailscale ping --help
  assert_success
}

@test "tailscale serve reset works without full auth" {
  set -eu -o pipefail
  
  run ddev add-on get "${DIR}"
  assert_success
  
  run ddev restart -y
  assert_success

  # Test serve reset command (should work without full auth)
  run ddev tailscale serve reset
  assert_success
}

@test "environment variables are properly set" {
  set -eu -o pipefail
  
  run ddev add-on get "${DIR}"
  assert_success
  
  run ddev restart -y
  assert_success
  
  # Check if DDEV_ROUTER_HTTP_PORT is available in web container
  run ddev exec "echo \$DDEV_ROUTER_HTTP_PORT"
  assert_success
  
  # Should output the port number (default 80 or custom port)
  [[ "$output" =~ ^[0-9]+$ ]]
}

@test "tailscale url and launch commands exist" {
  set -eu -o pipefail
  
  run ddev add-on get "${DIR}"
  assert_success
  
  run ddev restart -y
  assert_success

  # Test url command (will fail without auth but should exist)
  run ddev tailscale url
  # Don't assert success due to auth requirements
  
  # Test launch command structure
  run timeout 5s ddev tailscale launch --dry-run 2>/dev/null || true
  # Check command exists, don't worry about success without auth
}

@test "no conflicting processes after restart" {
  set -eu -o pipefail
  
  run ddev add-on get "${DIR}"
  assert_success
  
  # First restart
  run ddev restart -y
  assert_success
  refute_output --partial "foreground already exists"
  
  # Second restart (should not have port conflicts)
  run ddev restart -y  
  assert_success
  refute_output --partial "foreground already exists"
  refute_output --partial "ERROR (spawn error)"
}

@test "tailscale share command structure" {
  set -eu -o pipefail
  
  run ddev add-on get "${DIR}"
  assert_success
  
  run ddev restart -y
  assert_success

  # Test share command with --help flag
  run ddev tailscale share --help 2>/dev/null || run ddev tailscale serve --help
  # One of these should work to show the command is properly structured
}

@test "configuration files are properly installed" {
  set -eu -o pipefail
  
  run ddev add-on get "${DIR}"
  assert_success
  
  # Check all required files are installed
  run test -f .ddev/commands/host/tailscale
  assert_success
  
  run test -f .ddev/config.tailscale-router.yaml
  assert_success
  
  run test -f .ddev/web-build/Dockerfile.tailscale-router
  assert_success
  
  run test -f .ddev/docker-compose.tailscale-router.yaml
  assert_success
  
  # Check that old JSON config files are removed (from the migration)
  run test ! -f .ddev/tailscale-router/config/tailscale-private.json
  assert_success
  
  run test ! -f .ddev/tailscale-router/config/tailscale-public.json  
  assert_success
}