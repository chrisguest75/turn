#!/usr/bin/env bash

if [[ $_ != $0 ]]; then 
    echo "Script is being sourced"
else 
    echo "Script is not being sourced"
    return 1
fi

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
    local basepath="./"
    if [[ -n $1 ]]; then 
        basepath=$1
    fi
    basepath="${basepath}/"

    echo "* Creating version logs"
    git --no-pager tag --list -n1 > ${basepath}/tags.tags    
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
        echo "$(trim $current_tag) is between $(trim $previous_id) and $(trim $current_id)"

        if [[ "$current_id" == "$previous_id" ]]; then
            git --no-pager log --pretty=format:"'%h'${SEPERATOR}'%an'${SEPERATOR}'%s'" $(trim $current_id) > ${basepath}${current_tag}.txt
        else
            git --no-pager log --pretty=format:"'%h'${SEPERATOR}'%an'${SEPERATOR}'%s'" $(trim $previous_id)..$(trim $current_id) > ${basepath}${current_tag}.txt
        fi
        previous_tag=$current_tag
        previous_id=$current_id
    done < ${basepath}/tags.tags

}



