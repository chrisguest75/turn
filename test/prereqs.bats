#!/usr/bin/env bats
load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

#*******************************************************************
#* Prereqs
#*******************************************************************

# test for gomplates version 3.x
@test "gomplates exists" {
    run command -v gomplate
    #echo $output >&3 
    assert_success
}


@test "Version of gomplates is correct" {
    run gomplate --version
    #echo $output >&3 
    assert_output --regexp 'gomplate version [3-9].[0-9].[0-9]'
}

# test for sort -V
@test "sort -V exists" {
    run ls | sort -V
    #echo $output >&3 
    #assert_success
}

#@test "Version of git is correct" {
#    run git version
#    #echo $output >&3 
#    assert_output --regexp 'git version [2-9].[2-9][5-9].[0-9]'
#}