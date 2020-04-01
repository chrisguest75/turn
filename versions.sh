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
    : ${1?"${FUNCNAME[0]}(basepath, ranges_filepath) - missing basepath argument"}

    local basepath="./"
    if [[ -n $1 ]]; then 
        basepath=$1
    fi
    local ranges_filepath="./ranges.csv"
    if [[ -n $2 ]]; then 
        ranges_filepath=$2
    fi

    if [[ ! -f ${ranges_filepath} ]]; then
        echo "${ranges_filepath} not found"
        return 1
    fi 

    basepath="${basepath}/"

    while IFS=, read -r rev1 rev2 version
    do
        echo "$(trim $version) is between $(trim $rev1) and $(trim $rev2)"
        if [[ "$(trim $rev1)" == "$(trim $rev2)" ]]; then
            git --no-pager log  --pretty=format:"'%h', '%an', '%s'" $(trim $rev2) > ${basepath}$(trim $version).txt
        else
            git --no-pager log  --pretty=format:"'%h', '%an', '%s'" $(trim $rev1)..$(trim $rev2) > ${basepath}$(trim $version).txt
        fi        
    done < ${ranges_filepath}
}
