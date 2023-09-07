#!/bin/bash

function get_fedora_version() {
    rpm -E %fedora
}

function get_container_files_list() {
    local f
    for f in *.containerfile; do
        if [ -f "$f" ]; then
            echo "$f"
        fi
    done
}

function to_container_name() {
    xargs basename -s '.containerfile' | awk ' { print "gabrieleara/toolbox:" $0 "-"'"${FEDORA_VERSION}"' }'
}

function print_containers_list() {
    get_container_files_list | sort | to_container_name | awk '{ print "    - " $0 }'
}

function usage() {
    echo -n "usage: ${BASH_SOURCE[0]} [OPTIONS] [CONTAINER_FILES]

If a list of *.containerfile files is not supplied, the script will build
all containers specified in all files in the current directory.
For this directory, this is the list of containers that will be built
(in that order):

$(print_containers_list)

OPTIONS:
    -f FV, --fedora-version=FV
                            Accepted values are numbers or 'latest'.
                            By default, uses the value of the current
                            Fedora version: $(get_fedora_version).
"
}

function push_argument() {
    ARGUMENTS+=("$1")
}

function print_separate_lines() {
    printf '%s\n' "$@"
}

function handle_args() {
    FEDORA_VERSION_DEFAULT=$(get_fedora_version)
    FEDORA_VERSION="${FEDORA_VERSION_DEFAULT}"

    ARGUMENTS=()

    if [[ " $* " =~ " -h " ]] || [[ " $* " =~ " --help " ]]; then
        usage
        EXIT_CODE=0
        return 0
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            -f) FEDORA_VERSION="$2"; shift 2;;
            --fedora-version=*) FEDORA_VERSION="${1#*=}"; shift 1;;
            -*) echo "Unsupported argument: $1" >&2; usage; return 1;;
            *) push_argument "$1"; shift;
        esac
    done

    if [ "${#ARGUMENTS[@]}" = 0 ]; then
        readarray -t ARGUMENTS < <(get_container_files_list | sort)
    fi
}

function print_and_run() {
    echo "Running: $*"
    "$@"
}

function build() {
    local BUILD_CMD
    BUILD_CMD=(
        buildah bud -t "${BOX_TAG}"
        --build-arg FEDORA_VERSION="${FEDORA_VERSION}"
        --file "${BOX_FILE}"
    )

    print_and_run "${BUILD_CMD[@]}"
}

function push() {
    local PUSH_CMD
    PUSH_CMD=(
        buildah push "${BOX_TAG}"
    )

    print_and_run "${PUSH_CMD[@]}"
}

function main() {
    handle_args "$@"

    if [ -n "$EXIT_CODE" ]; then
        return "$EXIT_CODE"
    fi

    if [ "${#ARGUMENTS[@]}" = 0 ]; then
        echo "Error: nothing to do!" >&2
        return 1
    fi

    for arg in "${ARGUMENTS[@]}"; do
        BOX_FILE="$arg"
        BOX_TAG=$(echo "$arg" | to_container_name)

        build
        push
    done
}

(
    set -e
    main "$@"
)
