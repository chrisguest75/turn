#!/usr/bin/env bash 

if ! bats -t ./test/prereqs.bats; then
    echo "Prerequisites failed"
    exit 1
fi
set -e
bats -t ./test/shellcheck.bats
bats -t ./test/releasenotes.bats
bats -t ./test/deployment.bats
bats -t ./test/slack.bats
bats -t ./test/tags-to-ranges.bats