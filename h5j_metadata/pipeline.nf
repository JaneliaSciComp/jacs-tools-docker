#!/usr/bin/env nextflow

params.in = "$HOME/tile-2816195289193381909.h5j"

process get_metadata {

    container = "registry.int.janelia.org/jacs-scripts/h5j_metadata:1.0.2"
    cpus 1

    input:
    path 'input.fa' from params.in

    output:
    stdout into result

    script:
    """
    source /opt/conda/etc/profile.d/conda.sh
    conda activate py3
    python /app/h5j_metadata.py -i input.fa
    """

}

result.subscribe { println it }


