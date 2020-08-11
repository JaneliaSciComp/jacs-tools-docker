#!/usr/bin/env nextflow

params.in = "$HOME/tile-2816195289193381909.h5j"

process get_metadata {

    container = "registry.int.janelia.org/jacs-scripts/h5j_metadata:1.0.1"
    cpus 1

    input:
    path 'input.fa' from params.in

    output:
    stdout into result

    '''
    /app/run.sh -i input.fa
    '''
}

result.subscribe { println it }


