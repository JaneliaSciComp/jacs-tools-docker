#!/bin/bash

INPUT=$1
OUTPUT=$2

perl /app/scripts/perl/lsm_json_dump.pl "$INPUT" > "$OUTPUT"

