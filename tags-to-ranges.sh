#!/usr/bin/env bash

function trim() {
    : "${1?\"${FUNCNAME[0]}(string) - missing string argument\"}"

    if [[ -z ${1} ]]; then 
        echo ""
        return
    fi
    # remove an 
    trimmed=${1##*( )}
    # shellcheck disable=SC2086
    echo ${trimmed%%*( )}
}

function process() {
    local include_next=
    if [[ -n $1 ]]; then 
        include_next=$1
    fi
    
    # NOTE: stdout is used to capture ranges.  
    # Do not log messages or debug 
    local branch=master
    local previous_tag=0.0
    local depth=$(( $(git --no-pager rev-list --first-parent --count ${branch}) - 1))
    #local depth=$(git --no-pager rev-list --first-parent --count master)
    # shellcheck disable=SC2155
    local previous_id=$(git --no-pager rev-list -n 1 --first-parent ${branch}~${depth}) 
    local current_tag=
    local current_id=

    if [[ -n $(git --no-pager tag --list -n1) ]]; then
        # shellcheck disable=SC2034
        while IFS= read -r version message
        do
            current_tag=$(trim "$version")
            # shellcheck disable=SC2155
            local current_id=$(git --no-pager rev-list -n 1 "${current_tag}")
            echo "$(trim "$previous_id"), $(trim "$current_id"), $(trim "$current_tag")"

            previous_tag=$current_tag
            previous_id=$current_id
        done < <(git --no-pager tag --list -n1 | sort -V)
    fi
    if [[ -n $include_next && $include_next == true ]]; then
        # use HEAD as it is what is next on current branch.
        current_id=$(git --no-pager rev-list -n 1 HEAD)
        if [[ $previous_id != "$current_id" ]]; then 
            echo "$(trim "$previous_id"), $(trim "$current_id"), Next"
        fi 
    fi
}

process "$1"