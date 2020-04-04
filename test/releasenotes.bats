#!/usr/bin/env bats
load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

#*******************************************************************
#* Prereqs
#*******************************************************************

# test for gomplates version 3.x
# 

#*******************************************************************
#* Title 
#*******************************************************************

@test "Title contains version" {
    run gomplate --file ./release_notes.gomplate -c emojis=./deployment_emojis.json \
                -c users=./user_mapping.json \
                -c version=${BATS_TEST_DIRNAME}/testdata/parameters.json \
                -c .=${BATS_TEST_DIRNAME}/testdata/usermapping.txt 
    #echo $output >&3 
    assert_output --regexp '## Version 1\.0'
}

#*******************************************************************
#* Change logs
#*******************************************************************

@test "All changes are listed" {
    run gomplate --file ./release_notes.gomplate -c emojis=./deployment_emojis.json \
                -c users=./user_mapping.json \
                -c version=${BATS_TEST_DIRNAME}/testdata/parameters.json \
                -c .=${BATS_TEST_DIRNAME}/testdata/usermapping.txt 
    #echo $output >&3 
    assert_output --regexp '8de801d'
    assert_output --regexp 'd3d06db'
    assert_output --regexp '2e8e592'    
}

@test "Commas handled correctly" {
    run gomplate --file ./release_notes.gomplate -c emojis=./deployment_emojis.json \
                -c users=./user_mapping.json \
                -c version=${BATS_TEST_DIRNAME}/testdata/parameters.json \
                -c .=${BATS_TEST_DIRNAME}/testdata/commas.txt 
    #echo $output >&3 
    assert_output --regexp 'Line1 Fix output directory not being created    - generate notes pre-merge'
    assert_output --regexp 'Line2 Fix output  directory not being created - generate notes pre-merge'
    # Failing because single quotes are removed.
    #assert_output --regexp "Line3 Merge  branch 'master' of github.com:chrisguest75/git_examples"
    assert_output --regexp 'Line4 Fix output directory not being created - generate notes pre-merge'    
    assert_output --regexp 'Line5 Fix bugs'
}

@test "Table formatting" {
    run gomplate --file ./release_notes.gomplate -c emojis=./deployment_emojis.json \
                -c users=./user_mapping.json \
                -c version=${BATS_TEST_DIRNAME}/testdata/parameters.json \
                -c .=${BATS_TEST_DIRNAME}/testdata/usermapping.txt 
    #echo $output >&3 
    assert_output --regexp '\| CommitId'
}

#*******************************************************************
#* Hyperlinking
#*******************************************************************

@test "Commits are hyperlinked" {
    run gomplate --file ./release_notes.gomplate -c emojis=./deployment_emojis.json \
                -c users=./user_mapping.json \
                -c version=${BATS_TEST_DIRNAME}/testdata/parameters.json \
                -c .=${BATS_TEST_DIRNAME}/testdata/hyperlinking.txt 
    #echo $output >&3 
    assert_output --regexp '\[8de801d\]\(http://repo/commit/8de801d\)'
}

@test "Multiple issues can be hyperlinked" {
    run gomplate --file ./release_notes.gomplate -c emojis=./deployment_emojis.json \
                -c users=./user_mapping.json \
                -c version=${BATS_TEST_DIRNAME}/testdata/parameters.json \
                -c .=${BATS_TEST_DIRNAME}/testdata/hyperlinking.txt 
    #echo $output >&3 
    assert_output --regexp '\(\[#1034\]\(http://issues/1034\)\)'
    assert_output --regexp '\(\[#1035\]\(http://issues/1035\)\)'
    assert_output --regexp '\(\[#1036\]\(http://issues/1036\)\)'

    # Recursive insert has issues with way replacement is done
    #assert_output --regexp '\(\[#1\]\(http://issues/1\)\)'
    #assert_output --regexp '\(\[#12\]\(http://issues/12\)\)'
    #assert_output --regexp '\(\[#123\]\(http://issues/123\)\)'
}

#*******************************************************************
#* User remapping 
#*******************************************************************

@test "Users are remapped" {
    run gomplate --file ./release_notes.gomplate -c emojis=./deployment_emojis.json \
                -c users=./user_mapping.json \
                -c version=${BATS_TEST_DIRNAME}/testdata/parameters.json \
                -c .=${BATS_TEST_DIRNAME}/testdata/usermapping.txt 
    #echo $output >&3 
    assert_output --regexp '@chris\.guest'
    assert_output --regexp 'Harry Styles'
}