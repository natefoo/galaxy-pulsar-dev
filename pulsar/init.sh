#!/bin/bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." ; pwd)"

. "${root}/util/util.sh"


docker_run() {
    log_exec docker run --rm -it --name pulsar-init -w /pulsar --user "${UID}:${GID}" "$@"
}


# clone pulsar as needed
clone 'pulsar' "$PULSAR_ROOT"

# create venv as needed
venv 'pulsar' "$PULSAR_IMAGE"

log "Installing devmode Pulsar"
docker_run \
    -v "${PULSAR_ROOT}:/pulsar" \
    -v "${root}/pulsar/venv:/pulsar/.venv" \
    "$PULSAR_IMAGE" \
    ./.venv/bin/pip install -e .

log "Installing Pulsar additional dependencies"
docker_run \
    -v "${PULSAR_ROOT}:/pulsar" \
    -v "${root}/pulsar/venv:/pulsar/.venv" \
    "$PULSAR_IMAGE" \
    ./.venv/bin/pip install kombu pycurl
