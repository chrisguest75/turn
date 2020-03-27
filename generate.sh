#!/usr/bin/env bash 
#Use !/bin/bash -x  for debugging 

readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_PATH=${0}
# shellcheck disable=SC2034
readonly SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

if [ -n "${DEBUG_ENVIRONMENT}" ];then 
    # if DEBUG_ENVIRONMENT is set
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
    -t --type                [release|deployment|ALL]
    -o --out                 Output path default "./"
    --debug                  
    --clean                  Clean the temporary folder                  
    -h --help                show this help

Examples:
    $SCRIPT_NAME --action=create --type=release -o=../ 

EOF

    return ${EXITCODE}
}

#****************************************************************************
#** Main script 
#****************************************************************************

function main() {
    local EXITCODE=0
    local DEBUG=false  
    local CLEAN=false 
    local TEMPORARY_FOLDER=./output/
    local OUTPUT_TYPE="ALL"
    local OUTPUT_LOCATION=./

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
        --debug)
            set -x
            # shellcheck disable=SC2034
            local -r DEBUG=true   
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
        fi
        if [[ ! $(command -v gomplate) ]]; then
            echo "gomplate tool not found.  Please install and retry"
            exit 1
        fi

        if [[ ${CLEAN} == true ]]; then
            rm -rf "${TEMPORARY_FOLDER}"
        fi 
        if [[ ! -d "${TEMPORARY_FOLDER}" ]]; then
            mkdir -p ${TEMPORARY_FOLDER}
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

        if [ "${ACTION}" ]; then
            case "${ACTION}" in
                help)
                    help
                ;;
                create)
                    echo "* Creating version logs"
                    . ./versions.sh
                    process "${TEMPORARY_FOLDER}"
                    echo ""
                    local PROCESSED=false
                    if [[ "${OUTPUT_TYPE}" == "ALL" || "${OUTPUT_TYPE}" == "release" ]]; then 
                        TEMPLATE=./release_notes.gomplate

                        echo "* Building version markdown in ${TEMPORARY_FOLDER}"
                        for filename in ${TEMPORARY_FOLDER}*.txt; do
                            version=$(basename ${filename} .txt)
                            echo "{'version':'${version}', 'repo_url':'${REPO_URL}', 'issues_url':'${ISSUE_TRACKING_URL}'}" | \
                                gomplate --file ${TEMPLATE} \
                                -c users=user_mapping.json \
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
                        TEMPLATE=./deployed.gomplate

                        echo "* Building version markdown in ${TEMPORARY_FOLDER}"
                        for filename in ${TEMPORARY_FOLDER}*.txt; do
                            version=$(basename ${filename} .txt)
                            echo "{'version':'${version}', 'repo_url':'${REPO_URL}', 'issues_url':'${ISSUE_TRACKING_URL}'}" | \
                                gomplate --file ${TEMPLATE} \
                                -c emojis=deployment_emojis.json \
                                -c users=user_mapping.json \
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
