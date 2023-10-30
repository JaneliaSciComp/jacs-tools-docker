#!/usr/bin/env bash

if [ -d /scratch ] ; then
  export MCR_CACHE_ROOT=`mktemp -u -d -p "/scratch/${USER}/mcr_cache_$$"`
else
  export MCR_CACHE_ROOT=`mktemp -u`
fi

echo "User ${USER}"
echo "Use MCR_CACHE_ROOT ${MCR_CACHE_ROOT}"

[ -d ${MCR_CACHE_ROOT} ] || mkdir -p ${MCR_CACHE_ROOT}

helpmsg="<tile filepath> <output tile filepath> <psf file> <flatfield dir> <background> <z resolution> <psf z step> <number of iterations>"

if [ $# == 0 ] ; then
    echo "${helpmsg}"
    exit 1
fi

umask 0002

appName="matlab_decon"
flag="$1"

case ${flag} in
     -h|--help)
         echo "${helpmsg}"
         exit 0
         ;;
     *) # for anything else run the step
         /app/${appName} "$@"
         echo "Clean ${MCR_CACHE_ROOT}" && rm -rf "${MCR_CACHE_ROOT}"
         exit 0
         ;;
esac
