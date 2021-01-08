#!/usr/bin/env bash 

bats --version
if ! bats -t ./test/prereqs.bats --formatter junit -o ./test/results; then
    echo "Prerequisites failed"
    exit 1
fi
set -e
bats -t ./test/shellcheck.bats --formatter junit -o ./test/results
bats -t ./test/releasenotes.bats --formatter junit -o ./test/results
bats -t ./test/deployment.bats --formatter junit -o ./test/results
bats -t ./test/slack.bats --formatter junit -o ./test/results
bats -t ./test/tags-to-ranges.bats --formatter junit -o ./test/results
