# source me
# sourcing script must set $root

# we want one source of truth and need UID set in .env for docker-compose, but it's a read-only var in bash (but not
# automatically set in other shells, whee)
if [ ! -f "${root}/.env" ]; then
    echo "${0}: error: run 'make .env' to generate ${root}.env before executing this script"
    exit 1
fi

while read line; do
    # transform 'VAR=val' into ': ${VAR:=val}'
    eval $(echo "$line" | sed -E 's/^(.*)=(.*)$/: ${\1:=\2}/')
done <"${root}/.env"


# utility functions

log() {
    [ -t 0 ] && echo -e '\033[1;32m#' "$@" '\033[0m' 1>&2 || echo '#' "$@" 1>&2
}

log_exec() {
    set -x
    "$@"
    { set +x; } 2>/dev/null
}

clone() {
    local name="$1"
    local path="$2"

    log "Using ${name^} clone in ${path}, change by setting \$${name^^}_ROOT in .env"
    (
        # clone as needed, subshell so paths are relative to $root and we don't have to cd back
        cd "$root"
        if [ ! -d "$path" ]; then
            log "${name^} not found, cloning..."
            log_exec git clone https://github.com/galaxyproject/${name}.git "$path"
        fi
    )
}

venv() {
    # caller should define docker_run and set the container workdir and user appropriately
    local name="$1"
    local image="$2"

    if [ ! -d "${root}/${name}/venv" ]; then
        # common_startup.sh doesn't upgrade pip or use python3's builtin venv, it probably should
        log "Creating ${name^} .venv"
        docker_run -v "${root}/${name}:/${name}" "$image" python3 -m venv .venv
        log_exec mv "${root}/${name}/.venv" "${root}/${name}/venv"
        log "Upgrading pip"
        docker_run -v "${root}/${name}/venv:/${name}/.venv" "$image" ./.venv/bin/pip install --upgrade pip setuptools wheel
    else
        log "Skipping venv creation, remove ${root}/galaxy/venv to fully reinitialize"
    fi
}
