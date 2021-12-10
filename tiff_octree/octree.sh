#!/bin/bash

umask 0002

julia /app/src/main.jl $*
