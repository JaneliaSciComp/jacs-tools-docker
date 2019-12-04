cwlVersion: v1.0

baseCommand: /opt/aligner-scripts/run_aligner.sh

inputs:
    area:
        type: string
        inputBinding:
            prefix: --area
            valueFrom: $("/Brain/VNC".split('/').slice(-1)[0])
    shape:
        type: string
        inputBinding:
            prefix: --shape
    gender:
        type: string
        inputBinding:
            prefix: --gender
            valueFrom: $("/f/m".split('/').slice(-1)[0])
    imageSize:
        type: string
        inputBinding:
            prefix: --isize
    voxelSize:
        type: string
        inputBinding:
            prefix: --vsize
    mountingProtocol:
        type: string
        inputBinding:
            prefix: --mprotocol
    numberOfChannels:
        type: int
        inputBinding:
            prefix: --nchannels
    referenceChannel:
        type: int
        inputBinding:
            prefix: --refchannel
    templateDirectory:
        type: Directory
        inputBinding:
            prefix: --templatedir
    input:
        type: File
        inputBinding:
            prefix: -i
    neuronMask:
        type: File
        inputBinding:
            prefix: -nmask
    outputDirectory:
        type: Directory
        inputBinding:
            prefix: -o
    numberOfSlots:
        type: int
        inputBinding:
            prefix: --nslots
outputs:
    vaa3dResults:
        type: File
        outputBinding:
            glob: $(inputs.outputDirectory)/*.v3dpbd
    resultsMetadata:
        type: File
        outputBinding:
            glob: $(inputs.outputDirectory)/*.properties
