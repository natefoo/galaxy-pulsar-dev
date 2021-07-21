#!/bin/bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." ; pwd)"

. "${root}/util/util.sh"


docker_run() {
    log_exec docker run --rm -it --name pulsar-galaxy-lib --user "${UID}:${GID}" "$@"
}


log "Building minty fresh pulsar-galaxy-lib from ${PULSAR_ROOT}"
log_exec rm -rf "${PULSAR_ROOT}/build" "${PULSAR_ROOT}/dist" "${PULSAR_ROOT}"/*.egg-info
# build pulsar with galaxy's python
docker_run \
    -v "${PULSAR_ROOT}:/pulsar" \
    -v "${root}/galaxy/venv:/galaxy/.venv" \
    -w /pulsar \
    -e PULSAR_GALAXY_LIB=1 \
    "$GALAXY_IMAGE" \
    /galaxy/.venv/bin/python setup.py bdist_wheel
whl=$(basename "${PULSAR_ROOT}/dist"/pulsar_galaxy_lib-*.whl)
#log_exec cp "${PULSAR_ROOT}/dist/${whl}" "${GALAXY_ROOT}"
#log_exec rm -rf "${PULSAR_ROOT}/build" "${PULSAR_ROOT}/dist" "${PULSAR_ROOT}"/*.egg-info

log "Uninstalling pulsar-galaxy-lib from ${GALAXY_ROOT} venv"
docker_run \
    -v "${GALAXY_ROOT}:/galaxy" \
    -v "${root}/galaxy/venv:/galaxy/.venv" \
    -w /galaxy \
    "$GALAXY_IMAGE" \
    ./.venv/bin/pip uninstall -y pulsar-galaxy-lib

log "Installing pulsar-galaxy-lib from ${PULSAR_ROOT} in ${GALAXY_ROOT} venv"
docker_run \
    -v "${GALAXY_ROOT}:/galaxy" \
    -v "${root}/galaxy/venv:/galaxy/.venv" \
    -v "${PULSAR_ROOT}/dist/${whl}:/${whl}:ro" \
    -w /galaxy \
    "$GALAXY_IMAGE" \
    ./.venv/bin/pip install "/${whl}"

log "Fixing devmode Pulsar after wheel build"
log_exec rm -rf "${PULSAR_ROOT}/build" "${PULSAR_ROOT}/dist" "${PULSAR_ROOT}"/*.egg-info
docker_run \
    -v "${PULSAR_ROOT}:/pulsar" \
    -v "${root}/pulsar/venv:/pulsar/.venv" \
    -w /pulsar \
    "$PULSAR_IMAGE" \
    ./.venv/bin/pip install -e .
