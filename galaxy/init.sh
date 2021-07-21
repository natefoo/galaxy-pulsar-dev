#!/bin/bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." ; pwd)"

. "${root}/util/util.sh"


docker_run() {
    log_exec docker run --rm -it --name galaxy-init -w /galaxy --user "${UID}:${GID}" "$@"
}


# clone galaxy as needed
clone 'galaxy' "$GALAXY_ROOT"

# create venv as needed
venv 'galaxy' "$GALAXY_IMAGE"


log "Running Galaxy common_startup.sh"
docker_run \
    -v "${GALAXY_ROOT}:/galaxy" \
    -v "${root}/galaxy/venv:/galaxy/.venv" \
    -v "${root}/galaxy/config/galaxy.yml:/galaxy/config/galaxy.yml:ro" \
    -v "${root}/galaxy/config/job_conf.yml:/galaxy/config/job_conf.yml:ro" \
    -e HOME=/tmp/galaxy \
    "$GALAXY_IMAGE" \
    bash ./scripts/common_startup.sh \
