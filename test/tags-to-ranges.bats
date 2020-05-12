#!/usr/bin/env bats
load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'
load 'test_helper/bats-mock/src/bats-mock'

# source the file to be tested
load "${BATS_TEST_DIRNAME}/../tags-to-ranges.sh"

setup() {
    if [[ -n $DEBUG_BATS ]]; then    
        INDEX=$((${BATS_TEST_NUMBER} - 1))
        echo "##### setup start" >&3 
        echo "BATS_TEST_NAME:        ${BATS_TEST_NAME}" >&3 
        echo "BATS_TEST_FILENAME:    ${BATS_TEST_FILENAME}" >&3 
        echo "BATS_TEST_DIRNAME:     ${BATS_TEST_DIRNAME}" >&3 
        echo "BATS_TEST_NAMES:       ${BATS_TEST_NAMES[$INDEX]}" >&3 
        echo "BATS_TEST_DESCRIPTION: ${BATS_TEST_DESCRIPTION}" >&3 
        echo "BATS_TEST_NUMBER:      ${BATS_TEST_NUMBER}" >&3 
        echo "BATS_TMPDIR:           ${BATS_TMPDIR}" >&3 
        echo "##### setup end" >&3 
    fi
}

teardown() {
    if [[ -n $DEBUG_BATS ]]; then
        echo -e "##### teardown ${BATS_TEST_NAME}\n" >&3 
    fi

    rm "${BATS_TMPDIR}/bats-mock.$$."* || :
    #ls -l "${BATS_TMPDIR}"/bats-mock* >&3    
}

#*******************************************************************
#* 
#*******************************************************************

git() { 
    #if [[ "$*" == "git --no-pager rev-list --first-parent --count master*" ]]; then
        ${git_mock} "$@";
    #else
    #    echo "Not recognised";
    #fi 
}
fake_git_log=$(cat <<'EOF'
9ac61e6 (HEAD -> bats-mock, origin/bats-mock) Better library for mocking.
EOF
)

fake_git_single_tag=$(cat <<'EOF'
0.0.0           Initial commit
EOF
)

fake_git_commit_id=$(cat <<'EOF'
9ac61e65960e5b0e9ddc98a99b16ba03a5774345
EOF
)

fake_git_log=$(cat <<'EOF'
9ac61e6 (HEAD -> bats-mock, origin/bats-mock) Better library for mocking.
cee3c1d Working out how to get mocks working correctly.
7ebf99f Add a script that needs mocking to test it.
91a5101 Merge pull request #9 from chrisguest75/add_shellcheck_test
6a1d0ff Add shellcheck tests and fix up the script
d406cbc Example of a logger from tfenv
EOF
)

@test "script_to_test - no tags, do not include next returns empty" {
    #echo "$fake_git_log" >&3 
    git_mock="$(mock_create)"
    mock_set_output "${git_mock}" "5" 1 
    mock_set_output "${git_mock}" "d406cbc" 2
    mock_set_output "${git_mock}" "" 3 
    #echo $git_mock >&3 
    run process  
    #echo $output >&3 
    assert_output ""
    assert_equal "$(mock_get_call_num ${git_mock})" 3
    #assert_equal "$(mock_get_call_args ${git_mock})" "log --oneline"
    assert_success
}

@test "script_to_test - no tags, include next returns whole range" {
    #echo "$fake_git_log" >&3 
    git_mock="$(mock_create)"
    mock_set_output "${git_mock}" "5" 1 
    mock_set_output "${git_mock}" "   d406cbc5960e5b0e9ddc98a99b16ba03a5774345  " 2
    mock_set_output "${git_mock}" "" 3 
    mock_set_output "${git_mock}" "  9ac61e65960e5b0e9ddc98a99b16ba03a5774345    " 4 
    #echo $git_mock >&3 
    run process true
    #echo $output >&3 
    assert_output "d406cbc5960e5b0e9ddc98a99b16ba03a5774345, 9ac61e65960e5b0e9ddc98a99b16ba03a5774345, Next"
    assert_equal "$(mock_get_call_num ${git_mock})" 4
    assert_success
}

@test "script_to_test - no tags, include next returns whole range - only 1 commit" {
    #echo "$fake_git_log" >&3 
    git_mock="$(mock_create)"
    mock_set_output "${git_mock}" "1" 1 
    mock_set_output "${git_mock}" "   d406cbc5960e5b0e9ddc98a99b16ba03a5774345  " 2
    mock_set_output "${git_mock}" "" 3 
    mock_set_output "${git_mock}" "  d406cbc5960e5b0e9ddc98a99b16ba03a5774345    " 4 
    #echo $git_mock >&3 
    run process true
    #echo $output >&3 
    assert_output "d406cbc5960e5b0e9ddc98a99b16ba03a5774345, d406cbc5960e5b0e9ddc98a99b16ba03a5774345, Next"
    assert_equal "$(mock_get_call_num ${git_mock})" 4
    assert_success
}

@test "script_to_test - single tag, do not include next, gives range" {
    #echo "$fake_git_log" >&3 
    git_mock="$(mock_create)"
    mock_set_output "${git_mock}" "5" 1 
    mock_set_output "${git_mock}" "d406cbc5960e5b0e9ddc98a99b16ba03a5774345" 2
    mock_set_output "${git_mock}" "$fake_git_single_tag" 3 
    mock_set_output "${git_mock}" "$fake_git_single_tag" 4 
    mock_set_output "${git_mock}" "9ac61e65960e5b0e9ddc98a99b16ba03a5774345" 5
    #echo $git_mock >&3 
    run process  
    #echo $output >&3 
    assert_output "d406cbc5960e5b0e9ddc98a99b16ba03a5774345, 9ac61e65960e5b0e9ddc98a99b16ba03a5774345, 0.0.0"
    assert_equal "$(mock_get_call_num ${git_mock})" 5
    assert_success
}

