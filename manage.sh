#!/bin/bash

SUDO=
DOCKER=docker

function build {
    local _name="$1"
    shift
    local _otherTags="$@"

    CDIR=''
    for i in $(find . -name "${_name}" );  do
        if [[ -f ${i}/Dockerfile ]]; then
            echo "Found container directory ${CDIR}"
            CDIR=${i}
            break            
        fi
    done

    if [[ -z ${CDIR} ]]; then
        echo "Container directory not found -> ${CDIR}"
        exit 1
    fi

    local BUILD_ARGS=""
    if [[ -e "${CDIR}/TAGS" ]]; then
	    local local_container_tags=($(awk '{ print($1)}' "$CDIR/TAGS"))
        for t in ${local_container_tags[@]}; do
            BUILD_ARGS="${BUILD_ARGS} -t ${t}"
        done
    fi
    for t in ${_otherTags[@]}; do
        BUILD_ARGS="${BUILD_ARGS} -t ${t}"
    done
    $SUDO $DOCKER build $BUILD_ARGS $CDIR
}


COMMANDS=$1
CMDARR=(${COMMANDS//+/ })
shift 1 # remove command parameter from args

helpmsg="$0 
    build <buildargs> 
    help
"

for COMMAND in "${CMDARR[@]}" ; do
    case $COMMAND in
        build)
            container_names=()
            container_tags=()
            while [[ $# > 0 ]]; do
                key="$1"
                shift # past the key
                case $key in
                    -t)
                        container_tag="$1"
                        shift
                        container_tags=("${container_tags[@]}" ${container_tag})
                        ;;
                    *)
                        container_names=("${container_names[@]}" ${key})
                        ;;
                esac
            done
            for container_name in "${container_names[@]}"; do
                echo "Build $container_name ${container_tags[@]}"
                build ${container_name} ${container_tags[@]}
            done
            ;;
        help)
            echo $helpmsg
            exit 0
            ;;
    esac
done
