#!/usr/bin/env bats

setup() {
  set -eu -o pipefail
  export GITHUB_REPO=ddev/ddev-tailscale-router

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  
  # Safe temporary directory creation
  mkdir -p ~/tmp
  export TESTDIR=$(mktemp -d -t "${PROJNAME}.XXXXXX")

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

  # Check if Tailscale service logs indicate success
  run docker logs ddev-${PROJNAME}-tailscale-router 2>&1 | grep -q "Tailscale is up" || docker logs ddev-${PROJNAME}-tailscale-router
  assert_success

  # Check Tailscale connectivity
  run docker exec ddev-${PROJNAME}-tailscale-router tailscale status
  assert_success

  # Verify internet connectivity
  run curl -s https://icanhazip.com
  assert_success

  # Launch the DDEV site
  DDEV_DEBUG=true run ddev launch
  assert_success
  assert_output --partial "FULLURL https://${PROJNAME}.ddev.site"
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  if [ -n "${TESTDIR:-}" ]; then
    # Ensure we have permission to delete everything
    sudo chmod -R u+w "${TESTDIR}" 2>/dev/null || true
    sudo chown -R $(whoami) "${TESTDIR}" 2>/dev/null || true
    rm -rf "${TESTDIR}"
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
