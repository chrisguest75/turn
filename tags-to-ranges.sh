#!/usr/bin/env bash

function trim() {
    : ${1?"${FUNCNAME[0]}(string) - missing string argument"}

    if [[ -z ${1} ]]; then 
        echo ""
        return
    fi
    # remove an 
    trimmed=${1##*( )}
    echo ${trimmed%%*( )}
}

function process() {
    local previous_tag=0.0
    #local depth=$(expr $(git rev-list --no-merges --count master) - 1)
    local depth=$(git --no-pager rev-list --no-merges --count master)
    local previous_id=$(git --no-pager rev-list -n 1 --no-merges master~${depth}) 
    local current_tag=
    local current_id=
    while IFS= read -r version message
    do
        current_tag="$(trim $version)"
        local current_id=$(git --no-pager rev-list -n 1 ${current_tag})
        echo "$(trim $previous_id), $(trim $current_id), $(trim $current_tag)"

        previous_tag=$current_tag
        previous_id=$current_id
    done < <(git --no-pager tag --list -n1 | sort -V)

}

process 