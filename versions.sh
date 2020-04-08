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
        version=$(trim $version)
        rev1=$(trim $rev1)
        rev2=$(trim $rev2)
        echo "$version is between $rev1 and $rev2"

        local rev1depth=0
        local rev2depth=0        
        rev1depth=$(expr $(git --no-pager rev-list --first-parent --count $rev1) - 1)
        rev2depth=$(expr $(git --no-pager rev-list --first-parent --count $rev2) - 1)
        if [[ $rev1depth -gt $rev2depth ]]; then
            echo "ROLLBACK from $rev2 ($rev2depth) to $rev1 ($rev1depth)"   
            git --no-pager log  --pretty=format:"'%h'${SEPERATOR}'%an'${SEPERATOR}'%s'" $rev2..$rev1 > ${basepath}ROLLBACK.txt    
            break        
        else
            if [[ "$rev1" == "$rev2" ]]; then
                git --no-pager log  --pretty=format:"'%h'${SEPERATOR}'%an'${SEPERATOR}'%s'" $rev2 > ${basepath}${version}.txt
            else
                git --no-pager log  --pretty=format:"'%h'${SEPERATOR}'%an'${SEPERATOR}'%s'" $rev1..$rev2 > ${basepath}${version}.txt
            fi        
        fi
    done < ${ranges_filepath}
}
