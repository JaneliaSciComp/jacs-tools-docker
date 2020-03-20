#!/usr/bin/env bash

helpmsg="<c3d|c4d> [<tool-specific-args>]"

if [ $# == 0 ] ; then
    echo "${helpmsg}"
    exit 1
fi

umask 0002

tool="$1"
shift

/usr/local/bin/${tool} "$@"
