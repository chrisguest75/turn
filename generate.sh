#!/usr/bin/env bash

if [[ -f .env ]];then
    echo "* Sourcing local .env"
    . .env
else
    echo "Warning no local .env found"
fi

if [[ -z $1 ]]; then 
    echo "Usage: generate_release.sh release|deployment"    
    exit 1
fi 

if [[ ! $(command -v gomplate) ]]; then
    echo "gomplate tool not found.  Please install and retry"
    exit
fi

if [[ ! -d "./output" ]]; then
    mkdir -p ./output
fi 

git log -n 1 --pretty=format:"%d" 
echo ""
git log --pretty=format:"%h %an%x09%s" $(git merge-base HEAD origin/master)..HEAD
echo ""
echo ""
git log -n 1 --pretty=format:"%d" master
echo ""
git log --pretty=format:"%h %an%x09%s" master
echo ""
echo "* Creating version logs"
. ./versions.sh
process "./output/"
echo ""

if [[ $1 == "release" ]]; then 
    TEMPLATE=./release_notes.gomplate

    echo "* Building version markdown"
    for filename in ./output/*.txt; do
        version=$(basename ${filename} .txt)
        echo "{'version':'${version}', 'repo_url':'${REPO_URL}', 'issues_url':'${ISSUE_TRACKING_URL}'}" | \
            gomplate --file ${TEMPLATE} \
            -c users=user_mapping.json \
            -c version=stdin:///in.json \
            -c .=${filename} > ./output/${version}.md  
    done

    echo "* Building final markdown"
    echo "# RELEASE NOTES" > RELEASE_NOTES.md
    for filename in $(ls ./output | grep md | sort -Vr); do
        cat "./output/${filename}" >> RELEASE_NOTES.md
    done

elif [[ $1 == "deployment" ]]; then 
    TEMPLATE=./deployed.gomplate

    echo "* Building version markdown"
    for filename in ./output/*.txt; do
        version=$(basename ${filename} .txt)
        echo "{'version':'${version}', 'repo_url':'${REPO_URL}', 'issues_url':'${ISSUE_TRACKING_URL}'}" | \
            gomplate --file ${TEMPLATE} \
            -c emojis=deployment_emojis.json \
            -c users=user_mapping.json \
            -c version=stdin:///in.json \
            -c .=${filename} > ./output/${version}.md  
    done

    echo "* Building final markdown"
    echo "# DEPLOYMENTS" > DEPLOYMENTS.md
    for filename in $(ls ./output | grep md | sort -Vr); do
        cat "./output/${filename}" >> DEPLOYMENTS.md
    done
else
    echo "$1 not recognised"
fi