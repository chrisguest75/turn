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
    local include_next=
    if [[ -n $1 ]]; then 
        include_next=$1
    fi
        
    local previous_tag=0.0
    local depth=$(expr $(git rev-list --first-parent --count master) - 1)
    #local depth=$(git --no-pager rev-list --first-parent --count master)
    local previous_id=$(git --no-pager rev-list -n 1 --first-parent master~${depth}) 
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

    if [[ -n $include_next && $include_next == true ]]; then
        current_id=$(git --no-pager rev-list -n 1 HEAD)
        if [[ $previous_id != $current_id ]]; then 
            echo "$(trim $previous_id), $(trim $current_id), Next"
        fi 
    fi
}

process $1