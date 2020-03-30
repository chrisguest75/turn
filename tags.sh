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
    git tag --list -n1 > ${basepath}/tags.tags    
    local previous_tag=0.0
    local depth=$(expr $(git rev-list --count master) - 1)
    local previous_id=$(git rev-list -n 1 HEAD~${depth}) 
    local current_tag=
    local current_id=
    while IFS= read -r version message
    do
        current_tag="$(trim $version)"
        local current_id=$(git rev-list -n 1 ${current_tag})
        git log  --pretty=format:"'%h', '%an', '%s'" $(trim $previous_id)..$(trim $current_id) > ${basepath}${current_tag}.txt
        previous_tag=$current_tag
        previous_id=$current_id
    done < ${basepath}/tags.tags

}

function set_tags() {
    git tag -a -m "Initial commit" 0.0 162856a
    git tag -a -m "Example table in markdown" 1.0 ea5f6b1
    git tag -a -m "Add gitignore for output folder" 1.1 0ea7306
    git tag -a -m "Template contains a list of commits" 1.2 acf1304
    git tag 1.3 58ee502
    git tag 2.0 5144e24
    git tag 2.1 7130ef6
    git tag 2.2 ab4ffc5
    git tag 2.17 8de801d
    git tag 2.20 5943833
    git tag 2.21 acf8d2b
    git tag 2.22 24781ca
    git tag 3.0 6e6b77c
}

