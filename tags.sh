#!/usr/bin/env bash

if [[ $_ != $0 ]]; then 
    echo "Script is being sourced"
else 
    echo "Script is not being sourced"
    return 1
fi

function process() {
    local basepath="./"
    if [[ -n $1 ]]; then 
        basepath=$1
    fi
    basepath="${basepath}/"

    echo "* Creating version logs"
    git tag --list -n1 > ./output/tags.txt
    cat ./output/tags.txt 
    git log  --pretty=format:"'%h', '%an', '%s'" 162856a..ea5f6b1 > ./output/1.0.txt

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

