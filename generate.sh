#!/usr/bin/env bash 
#Use !/bin/bash -x  for debugging 

readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_PATH=${0}
# shellcheck disable=SC2034
readonly SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

if [ -n "${DEBUG_ENVIRONMENT}" ];then 
    # if DEBUG_ENVIRONMENT is set
    echo "SCRIPT_NAME=${SCRIPT_NAME}"
    echo "SCRIPT_PATH=${SCRIPT_PATH}"
    echo "SCRIPT_DIR=${SCRIPT_DIR}"
    env
    export
fi

#****************************************************************************
#** Print out usage
#****************************************************************************

function help() {
    local EXITCODE=0

    cat <<- EOF
usage: $SCRIPT_NAME options

OPTIONS:
    -a --action              [create]
    -t --type                [release|deployment|slack|ALL]
    -o --out                 Output path - default "./"
    -w --work-dir            Working folder - default is to use tmp
    --debug                  
    --tags                   Use tags rather than ranges                     
    --clean                  Clean the temporary folder                  
    -h --help                show this help

Examples:
    $SCRIPT_NAME --action=create --type=release -o=../ 

EOF

    return ${EXITCODE}
}

#****************************************************************************
#** add_trailing_slash
#****************************************************************************

function add_trailing_slash() {
    : ${1?"${FUNCNAME[0]}(path) - missing path argument"}

    if [[ -z ${1} ]]; then 
        #echo "${FUNCNAME[0]}(path) - path is empty" && exit 1
        echo ""
        return
    fi
    # remove an existing slash and add new one.
    echo "${1%/}/"
}

#****************************************************************************
#** Main script 
#****************************************************************************

function main() {
    local EXITCODE=0
    local DEBUG=false  
    local CLEAN=false 
    local INCLUDENEXT=false
    local TEMPORARY_FOLDER=
    local OUTPUT_TYPE="ALL"
    local OUTPUT_LOCATION=./
    local MODE="range"

    for i in "$@"
    do
    case $i in
        -a=*|--action=*)
            local -r ACTION="${i#*=}"
            shift # past argument=value
        ;; 
        -t=*|--type=*)
            local -r OUTPUT_TYPE="${i#*=}"
            shift # past argument=value
        ;;                   
        -o=*|--out=*)
            local -r OUTPUT_LOCATION="${i#*=}"
            shift # past argument=value
        ;;                   
        -w=*|--work-dir=*)
            local -r TEMPORARY_FOLDER="${i#*=}"
            TEMPORARY_FOLDER=add_trailing_slash ${TEMPORARY_FOLDER}           
            shift # past argument=value
        ;;                   
        --debug)
            set -x
            # shellcheck disable=SC2034
            local -r DEBUG=true   
            shift # past argument=value
        ;; 
        --tags)
            # shellcheck disable=SC2034
            local -r MODE="tag"   
            shift # past argument=value
        ;;           
        --includenext)
            # shellcheck disable=SC2034
            local -r INCLUDENEXT=true   
            shift # past argument=value
        ;;           
        --clean)
            # shellcheck disable=SC2034
            local -r CLEAN=true   
            shift # past argument=value
        ;;   
        -h|--help)
            local -r HELP=true            
            shift # past argument=value
        ;;
        *)
            echo "Unrecognised ${i}"
        ;;
    esac
    done    

    if [ "${HELP}" = true ] ; then
        EXITCODE=1
        help
    else
        if [[ -f .env ]];then
            echo "* Sourcing local .env"
            . .env
        else
            echo "Warning no local .env found"
            exit 1
        fi
        if [[ ! $(command -v gomplate) ]]; then
            echo "gomplate tool not found.  Please install and retry"
            exit 1
        fi

        if [[ -n ${TEMPORARY_FOLDER} ]]; then
            # To allow clean need to make sure that directory is not root.
            #if [[ ${CLEAN} == true ]]; then            
                #rm -rf "${TEMPORARY_FOLDER}"
            #fi 
            if [[ ! -d "${TEMPORARY_FOLDER}" ]]; then
                mkdir -p ${TEMPORARY_FOLDER}
            fi 
        else
            TEMPORARY_FOLDER="$(mktemp -d)/"
            echo "TEMPORARY_FOLDER=${TEMPORARY_FOLDER}"
        fi

        if [ "${DEBUG}" == true ] ; then
            ls -al     
            ls -al ../    
            git --version
            gomplate --version
            git remote -v

            #git --no-pager log -n 1 --pretty=format:"%d" 
            #echo ""
            #git --no-pager log --pretty=format:"%h %an%x09%s" $(git --no-pager merge-base HEAD origin/master)..HEAD
            #echo ""
            echo ""
            git --no-pager log -n 1 --pretty=format:"%d" master
            echo ""
            git --no-pager log --pretty=format:"%h %an%x09%s" master
            echo ""
        fi

        readonly SEPERATOR=c80e53d155344a9dab87faad3884f679

        if [ "${ACTION}" ]; then
            case "${ACTION}" in
                help)
                    help
                ;;
                create)
                    echo "* Creating version logs"
                    if [[ ${MODE} == "tag" ]]; then
                        if [[ -f "${SCRIPT_DIR}/tags-to-ranges.sh" ]]; then
                            ${SCRIPT_DIR}/tags-to-ranges.sh ${INCLUDENEXT} > "./ranges.csv"
                        else
                            echo "${SCRIPT_DIR}/tags-to-ranges.sh not found"
                            exit 1
                        fi
                    fi
                    if [[ -f "${SCRIPT_DIR}/versions.sh" ]]; then
                        . ${SCRIPT_DIR}/versions.sh
                        process "${TEMPORARY_FOLDER}" "./ranges.csv"
                    else
                        echo "${SCRIPT_DIR}/versions.sh not found"
                        exit 1
                    fi

                    echo ""
                    local PROCESSED=false
                    if [[ "${OUTPUT_TYPE}" == "ALL" || "${OUTPUT_TYPE}" == "release" ]]; then 
                        TEMPLATE=${SCRIPT_DIR}/release_notes.gomplate

                        echo "* Building version markdown in ${TEMPORARY_FOLDER}"
                        for filename in ${TEMPORARY_FOLDER}*.txt; do
                            version=$(basename ${filename} .txt)
                            echo "${version}"
                            echo "{'version':'${version}', 'repo_url':'${REPO_URL}', 'issues_url':'${ISSUE_TRACKING_URL}', 'seperator':'${SEPERATOR}', 'issue_prefix':'${ISSUE_PREFIX}'}" | \
                                gomplate --file ${TEMPLATE} \
                                -c users=${SCRIPT_DIR}/user_mapping.json \
                                -c version=stdin:///in.json \
                                -c .=${filename} > ${TEMPORARY_FOLDER}${version}.md  
                        done

                        echo "* Building final markdown ${OUTPUT_LOCATION}RELEASE_NOTES.md"
                        echo "# RELEASE NOTES" > ${OUTPUT_LOCATION}RELEASE_NOTES.md
                        for filename in $(ls ${TEMPORARY_FOLDER} | grep md | sort -Vr); do
                            cat "${TEMPORARY_FOLDER}${filename}" >> ${OUTPUT_LOCATION}RELEASE_NOTES.md
                        done
                        PROCESSED=true
                    fi
                    if [[ "${OUTPUT_TYPE}" == "ALL" || "${OUTPUT_TYPE}" == "deployment" ]]; then 
                        TEMPLATE=${SCRIPT_DIR}/deployed.gomplate

                        echo "* Building version markdown in ${TEMPORARY_FOLDER}"
                        for filename in ${TEMPORARY_FOLDER}*.txt; do
                            version=$(basename ${filename} .txt)
                            echo "${version}"
                            echo "{'version':'${version}', 'repo_url':'${REPO_URL}', 'issues_url':'${ISSUE_TRACKING_URL}', 'seperator':'${SEPERATOR}', 'issue_prefix':'${ISSUE_PREFIX}'}" | \
                                gomplate --file ${TEMPLATE} \
                                -c emojis=${SCRIPT_DIR}/deployment_emojis.json \
                                -c users=${SCRIPT_DIR}/user_mapping.json \
                                -c version=stdin:///in.json \
                                -c .=${filename} > ${TEMPORARY_FOLDER}${version}.md  
                        done

                        echo "* Building final markdown ${OUTPUT_LOCATION}DEPLOYMENTS.md"
                        echo "# DEPLOYMENTS" > DEPLOYMENTS.md
                        for filename in $(ls ${TEMPORARY_FOLDER} | grep md | sort -Vr); do
                            cat "${TEMPORARY_FOLDER}${filename}" >> ${OUTPUT_LOCATION}DEPLOYMENTS.md
                        done
                        PROCESSED=true
                    fi
                    if [[ "${OUTPUT_TYPE}" == "ALL" || "${OUTPUT_TYPE}" == "slack" ]]; then 
                        TEMPLATE=${SCRIPT_DIR}/slack.gomplate

                        echo "* Building version markdown in ${TEMPORARY_FOLDER}"
                        for filename in ${TEMPORARY_FOLDER}*.txt; do
                            version=$(basename ${filename} .txt)
                            echo "${version}"
                            echo "{'version':'${version}', 'repo_url':'${REPO_URL}', 'issues_url':'${ISSUE_TRACKING_URL}', 'channel':'${SLACK_CHANNEL}', 'seperator':'${SEPERATOR}', 'issue_prefix':'${ISSUE_PREFIX}', 'metadata':'${METADATA}'}" | \
                                gomplate --file ${TEMPLATE} \
                                -c emojis=${SCRIPT_DIR}/deployment_emojis.json \
                                -c users=${SCRIPT_DIR}/user_mapping.json \
                                -c version=stdin:///in.json \
                                -c .=${filename} > ${TEMPORARY_FOLDER}${version}.md  
                        done

                        for filename in $(ls ${TEMPORARY_FOLDER} | grep md | sort -Vr | head -n 1); do
                            if [[ -n ${SLACK_POST} ]]; then 
                                echo "* Posting final markdown ${TEMPORARY_FOLDER}${filename}"
                                curl -X POST -H "Content-type: application/json" -d @"${TEMPORARY_FOLDER}${filename}" ${SLACK_POST}
                            else
                                echo "No URL is defined in \$SLACK_POST"
                                exit
                            fi
                        done
                        PROCESSED=true
                    fi
                    if [[ $PROCESSED == false ]]; then
                        echo "${OUTPUT_TYPE} not recognised"
                    fi                    
                ;;
                *)
                    echo "Unrecognised ${ACTION}"; 
                ;;
            esac
        else
            EXITCODE=1
            echo "No action specified use --action=<action>"
        fi
    fi
    return ${EXITCODE}
}

echo "Start"
main "$@"
exit $?
