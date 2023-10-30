#!/bin/bash

DEFAULT_NAMESPACE=
DEFAULT_SUDO=
SUDO=${SUDO:-${DEFAULT_SUDO}}
DOCKER=docker
NAMESPACE=${NAMESPACE:-${DEFAULT_NAMESPACE}}
BUILD_ARGS=

container_dirs=()

function findContainerDirs {
    local _name="$1"

    container_dirs=()
    for i in $(find . -name "${_name}" );  do
        if [[ -f ${i}/Dockerfile ]]; then
            container_dirs+=("${i}")
            break
        else
            for containerDir in $(find "${i}" -name "Dockerfile");  do
                container_dirs+=($(dirname "${containerDir}"))
            done
        fi
    done
    if [[ -z ${container_dirs} ]]; then
        echo "No container directory was found for ${container_name}"
        exit 1
    fi
}

function build {
    local _name="$1"
    shift
    local _otherTags="$@"

    findContainerDirs "${_name}"

    for cdir in ${container_dirs[@]}; do
        local container_name=$(basename "$cdir")
        local LOCAL_BUILD_ARGS=""
        if [[ -n ${NAMESPACE} ]]; then
            local container_version="";
            if [[ -e "${cdir}/VERSION" ]]; then
                container_version=$(cat "$cdir/VERSION")
            fi

            if [[ -n ${container_version} ]]; then
                local vname=${NAMESPACE}/${container_name}:${container_version}
                LOCAL_BUILD_ARGS="${LOCAL_BUILD_ARGS} -t ${vname}"
            fi
            local lname=${NAMESPACE}/${container_name}:"latest"
            LOCAL_BUILD_ARGS="${LOCAL_BUILD_ARGS} -t ${lname}"
        fi


        if [[ -e "${cdir}/TAGS" ]]; then
            local local_container_tags=($(awk '{ print($1)}' "$cdir/TAGS"))
            for t in ${local_container_tags[@]}; do
                LOCAL_BUILD_ARGS="${LOCAL_BUILD_ARGS} -t ${t}"
            done
        fi

        for t in ${_otherTags[@]}; do
            LOCAL_BUILD_ARGS="${LOCAL_BUILD_ARGS} -t ${t}"
        done
        $SUDO $DOCKER build $BUILD_ARGS $LOCAL_BUILD_ARGS $cdir
    done
}

function push {
    local _name="$1"

    findContainerDirs "${_name}"

    for cdir in ${container_dirs[@]}; do
        local container_name=$(basename "${cdir}")
        if [[ -n ${NAMESPACE} ]]; then
            local container_version="";
            if [[ -e "${cdir}/VERSION" ]]; then
                container_version=$(cat "$cdir/VERSION")
            fi

            if [[ -n ${container_version} ]]; then
                local vname=${NAMESPACE}/${container_name}:${container_version}
                $SUDO $DOCKER push $vname
            fi
            local lname=${NAMESPACE}/${container_name}:"latest"
            $SUDO $DOCKER push $lname
        else
            echo "No namespace defined for pushing $container_name"
        fi
    done
}

function pushTags {
    local _name="$1"

    findContainerDirs "${_name}"

    for cdir in ${container_dirs[@]}; do
        if [[ -e "${cdir}/TAGS" ]]; then
            local local_container_tags=($(awk '{ print($1)}' "$cdir/TAGS"))
            for t in ${local_container_tags[@]}; do
                $SUDO $DOCKER push ${t}
            done
        fi
    done
}

COMMANDS=$1
CMDARR=(${COMMANDS//+/ })
shift 1 # remove command parameter from args

helpmsg="$0 
    build <buildargs>
    push <containers>
    pushTags <containers>
    help
"
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
        --platform)
            platform=$1
            shift
            BUILD_ARGS="${BUILD_ARGS} --platform ${platform}"
            ;;
        *)
            container_names=("${container_names[@]}" ${key})
            ;;
    esac
done

for COMMAND in "${CMDARR[@]}" ; do
    case $COMMAND in
        build)
            for container_name in "${container_names[@]}"; do
                echo "Build $container_name ${container_tags[@]}"
                build ${container_name} ${container_tags[@]}
            done
            ;;
        push)
            for container_name in "${container_names[@]}"; do
                echo "Push $container_name"
                push ${container_name}
            done
            ;;
        pushTags) # push the tags defined in the TAGS file under the container folder
            for container_name in "${container_names[@]}"; do
                echo "Push all tags from $container_name"
                pushTags ${container_name}
            done
            ;;
        -h|help)
            echo $helpmsg
            exit 0
            ;;
    esac
done
