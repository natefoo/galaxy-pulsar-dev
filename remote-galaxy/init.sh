#!/bin/bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." ; pwd)"

. "${root}/util/util.sh"


docker_run() {
    log_exec docker run --rm -it --name pulsar-init -w /remote-galaxy --user "${UID}:${GID}" "$@"
}


# create venv as needed
venv 'remote-galaxy' "$PULSAR_IMAGE"

log "Updating remote Galaxy venv for remote metadata"
docker_run \
    -v "${GALAXY_ROOT}:/remote-galaxy:ro" \
    -v "${root}/remote-galaxy/venv:/remote-galaxy/.venv" \
    "$PULSAR_IMAGE" \
    bash ./scripts/common_startup.sh --skip-client-build
