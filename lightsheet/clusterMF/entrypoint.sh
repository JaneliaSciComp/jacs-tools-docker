#!/usr/bin/env bash

if [ -d /scratch ] ; then
  export MCR_CACHE_ROOT="/scratch/${USER}/mcr_cache_$$"
else
  export MCR_CACHE_ROOT=`mktemp -u`
fi

echo "User ${USER}"
echo "Use MCR_CACHE_ROOT ${MCR_CACHE_ROOT}"

[ -d ${MCR_CACHE_ROOT} ] || mkdir -p ${MCR_CACHE_ROOT}

helpmsg="[<options>] <json-config> [<timepoints-per-job> <job-number>]"

if [ $# == 0 ] ; then
    echo "${helpmsg}"
    exit 1
fi

umask 0002

step="clusterMF"
flag="$1"

case ${flag} in
     -h|--help)
         echo "${helpmsg}"
         exit 0
         ;;
     *) # for anything else run the step
         /app/${step}_fn "$@"
         echo "Clean ${MCR_CACHE_ROOT}" && rm -rf "${MCR_CACHE_ROOT}"
         exit 0
         ;;
esac
