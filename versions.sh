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

    git log  --pretty=format:"'%h', '%an', '%s'" 162856a..ea5f6b1 > ${basepath}1.0.txt
    git log  --pretty=format:"'%h', '%an', '%s'" ea5f6b1..0ea7306 > ${basepath}1.1.txt
    git log  --pretty=format:"'%h', '%an', '%s'" 0ea7306..acf1304 > ${basepath}1.2.txt
    git log  --pretty=format:"'%h', '%an', '%s'" acf1304..58ee502 > ${basepath}1.3.txt
    git log  --pretty=format:"'%h', '%an', '%s'" 58ee502..5144e24 > ${basepath}2.0.txt
    git log  --pretty=format:"'%h', '%an', '%s'" 5144e24..7130ef6 > ${basepath}2.1.txt
    git log  --pretty=format:"'%h', '%an', '%s'" 7130ef6..ab4ffc5 > ${basepath}2.2.txt
    git log  --pretty=format:"'%h', '%an', '%s'" ab4ffc5..8de801d > ${basepath}2.17.txt
    git log  --pretty=format:"'%h', '%an', '%s'" 8de801d..5943833 > ${basepath}2.20.txt
    git log  --pretty=format:"'%h', '%an', '%s'" 5943833..acf8d2b > ${basepath}2.21.txt
    git log  --pretty=format:"'%h', '%an', '%s'" acf8d2b..24781ca > ${basepath}2.22.txt
    git log  --pretty=format:"'%h', '%an', '%s'" 24781ca..6e6b77c > ${basepath}3.0.txt
}
