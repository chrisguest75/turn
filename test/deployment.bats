#!/usr/bin/env bats
load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

#*******************************************************************
#* Title 
#*******************************************************************

@test "Title contains version" {
    run gomplate --file ./deployed.gomplate -c emojis=./deployment_emojis.json \
                -c users=./user_mapping.json \
                -c version=${BATS_TEST_DIRNAME}/testdata/parameters.json \
                -c .=${BATS_TEST_DIRNAME}/testdata/usermapping.txt 
    #echo $output >&3 
    assert_line --index 0 '## Deployment 1.0'
    assert_success
}

#*******************************************************************
#* Change logs
#*******************************************************************

@test "All changes are listed" {
    run gomplate --file ./deployed.gomplate -c emojis=./deployment_emojis.json \
                -c users=./user_mapping.json \
                -c version=${BATS_TEST_DIRNAME}/testdata/parameters.json \
                -c .=${BATS_TEST_DIRNAME}/testdata/usermapping.txt 
    #echo $output >&3 
    assert_line --index 2 --regexp '8de801d'
    assert_line --index 3 --regexp 'd3d06db'
    assert_line --index 4 --regexp '2e8e592'    
    assert_success    
}

@test "Commas handled correctly" {
    run gomplate --file ./deployed.gomplate -c emojis=./deployment_emojis.json \
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
    assert_success    
}

@test "Wiggly worm formatting" {
    run gomplate --file ./deployed.gomplate -c emojis=./deployment_emojis.json \
                -c users=./user_mapping.json \
                -c version=${BATS_TEST_DIRNAME}/testdata/parameters.json \
                -c .=${BATS_TEST_DIRNAME}/testdata/usermapping.txt 
    #echo $output >&3 
    assert_line --index 1  --regexp ':worm-vert-head-([a-z]*):'
    assert_line --index 2  --regexp ':worm-vert-body-([a-z]*): \[8de801d\]\(http://repo/commit/8de801d\) @chris.guest (.*)'
    assert_line --index 5  --regexp ':worm-vert-tail-([a-z]*):'
    assert_success
}

@test "Empty logs" {
    run gomplate --file ./deployed.gomplate -c emojis=./deployment_emojis.json \
                -c users=./user_mapping.json \
                -c version=${BATS_TEST_DIRNAME}/testdata/parameters.json \
                -c .=${BATS_TEST_DIRNAME}/testdata/empty.txt 
    #echo $output >&3 
    assert_line --index 1 --regexp 'No commits'
    assert_success    
}

@test "Single commit" {
    run gomplate --file ./deployed.gomplate -c emojis=./deployment_emojis.json \
                -c users=./user_mapping.json \
                -c version=${BATS_TEST_DIRNAME}/testdata/parameters.json \
                -c .=${BATS_TEST_DIRNAME}/testdata/single.txt 
    #echo $output >&3 
    assert_line --index 1  --regexp ':worm-vert-head-([a-z]*):'
    assert_line --index 2  --regexp ':worm-vert-body-([a-z]*): \[8de801d\]\(http://repo/commit/8de801d\) @chris.guest (.*)'    
    assert_line --index 3  --regexp ':worm-vert-tail-([a-z]*):'
    assert_success    
}
#*******************************************************************
#* Hyperlinking
#*******************************************************************

@test "Commits are hyperlinked" {
    run gomplate --file ./deployed.gomplate -c emojis=./deployment_emojis.json \
                -c users=./user_mapping.json \
                -c version=${BATS_TEST_DIRNAME}/testdata/parameters.json \
                -c .=${BATS_TEST_DIRNAME}/testdata/hyperlinking.txt 
    #echo $output >&3 
    assert_output --regexp '\[8de801d\]\(http://repo/commit/8de801d\)'
    assert_success    
}

@test "Multiple issues can be hyperlinked" {
    run gomplate --file ./deployed.gomplate -c emojis=./deployment_emojis.json \
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
    assert_success    
}

#*******************************************************************
#* User remapping 
#*******************************************************************

@test "Users are remapped" {
    run gomplate --file ./deployed.gomplate -c emojis=./deployment_emojis.json \
                -c users=./user_mapping.json \
                -c version=${BATS_TEST_DIRNAME}/testdata/parameters.json \
                -c .=${BATS_TEST_DIRNAME}/testdata/usermapping.txt 
    #echo $output >&3 
    assert_output --regexp '@chris\.guest'
    assert_output --regexp 'Harry Styles'
    assert_success    
}
