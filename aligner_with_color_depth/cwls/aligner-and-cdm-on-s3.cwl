cwlVersion: v1.0

baseCommand: /opt/aligner-scripts/run_aligner_using_s3.sh

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
    templatesBucket:
        type: Directory
        inputBinding:
            prefix: --templates-s3bucket-name
    inputsBucket:
        type: string
        inputBinding:
            prefix: --inputs-s3bucket-name
    inputPath:
        type: File
        inputBinding:
            prefix: -i
    neuronMaskPath:
        type: File
        inputBinding:
            prefix: -nmask
    outputsBucket:
        type: Directory
        inputBinding:
            prefix: --outputs-s3bucket-name
    outputDirectory:
        type: Directory
        inputBinding:
            prefix: -o
    iamRole:
        type: string
        inputBinding:
            prefix: --use-iam-role
    numberOfSlots:
        type: int
        inputBinding:
            prefix: --nslots
outputs:
    vaa3dResults:
        type: File
        outputBinding:
            glob: s3://$(inputs.outputsBucket)/$(inputs.outputDirectory)/*.v3dpbd
    resultsMetadata:
        type: File
        outputBinding:
            glob: s3://$(inputs.outputsBucket)/$(inputs.outputDirectory)/*.properties
