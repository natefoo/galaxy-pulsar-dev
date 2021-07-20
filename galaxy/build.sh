#!/bin/bash
#
# rather than using compose's native build functionality, we use this script to prepare Galaxy to run, since it has to
# do a bit of starting and stopping and there are things we don't want to do every time.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." ; pwd)"

# we want one source of truth and need UID set in .env for docker-compose, but it's a read-only var in bash (but not
# automatically set in other shells, whee)
while read line; do
    # transform 'VAR=val' into ': ${VAR:=val}'
    eval $(echo "$line" | sed -E 's/^(.*)=(.*)$/: ${\1:=\2}/')
done <"${root}/.env"


log() {
    [ -t 0 ] && echo -e '\033[1;32m#' "$@" '\033[0m' 1>&2 || echo '#' "$@" 1>&2
}

log_exec() {
    set -x
    "$@"
    { set +x; } 2>/dev/null
}

docker_run() {
    log_exec docker run --rm -it --name galaxy-init -w /galaxy --user "${UID}:${GID}" "$@"
}


# clone galaxy as needed, subshell so paths are relative to $root
(
    cd "$root"
    if [ ! -d "$GALAXY_ROOT" ]; then
        log "Galaxy not found, cloning..."
        log_exec git clone https://github.com/galaxyproject/galaxy.git "$GALAXY_ROOT"
    else
        log "Existing Galaxy found in ${GALAXY_ROOT}, change by setting \$GALAXY_ROOT in .env"
    fi
)


# create venv as needed
if [ ! -d "${root}/galaxy/venv" ]; then
    # common_startup.sh doesn't upgrade pip or use python3's builtin venv, it probably should.
    log "Creating Galaxy .venv"
    docker_run -v "${root}/galaxy:/galaxy" "$GALAXY_IMAGE" python3 -m venv .venv
    log_exec mv "${root}/galaxy/.venv" "${root}/galaxy/venv"
    log "Upgrading pip"
    docker_run -v "${GALAXY_ROOT}:/galaxy" -v "${root}/galaxy/venv:/galaxy/.venv" "$GALAXY_IMAGE" ./.venv/bin/pip install --upgrade pip setuptools wheel
else
    log "Skipping venv creation, remove ${root}/galaxy/venv to fully reinitialize"
fi

log "Running common_startup.sh"
docker_run -v "${GALAXY_ROOT}:/galaxy" -v "${root}/galaxy/venv:/galaxy/.venv" -v "${root}/galaxy/config/galaxy.yml:/galaxy/config/galaxy.yml:ro" -v "${root}/galaxy/config/job_conf.yml:/galaxy/config/job_conf.yml:ro" -e HOME=/tmp/galaxy "$GALAXY_IMAGE" bash ./scripts/common_startup.sh
