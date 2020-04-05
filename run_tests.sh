#!/usr/bin/env bash 

bats -t ./test/prereqs.bats
if [[ $? -ne 0 ]]; then
    echo "Prerequisites failed"
    exit 1
fi
set -e
bats -t ./test/releasenotes.bats
bats -t ./test/deployment.bats
bats -t ./test/slack.bats
