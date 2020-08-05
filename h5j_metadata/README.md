# H5J Metadata Reader/Writer

Can be used to read or write the H5J metadata in YAML format.

## Build
This command builds the container and tags it with the name "jacs-scripts/h5j_metadata:1.0.0".
```
docker build . -t jacs-scripts/h5j_metadata:1.0.0
```

## Run with Docker
You need to make the input file accessible to Docker by mounting a volume (-v) into the container when you run it.
```
export DIR=/path/to/your/h5j/file
# Read metadata from H5J and write metadata.yaml
docker run -it -v $DIR:$DIR jacs-scripts/h5j_metadata:1.0.0 -i $DIR/tile-2607115756248236069.h5j -m metadata.yaml
# Read metadata from metadata.yaml and write to H5J
docker run -it -v $DIR:$DIR jacs-scripts/h5j_metadata:1.0.0 -o $DIR/tile-2607115756248236069.h5j -m metadata.yaml
```

## Run with Singularity
To run on a compute cluster, first convert the Docker container into SIF format, and then run it.
```
singularity build /tmp/out.sif docker-daemon://jacs-scripts/h5j_metadata:1.0.0
singularity run -B $DIR /tmp/out.sif -i $DIR/tile-2607115756248236069.h5j
```

## Distribution using Docker Registry
You can distribute the Docker container to any registry, such as DockerHub or Janelia's internal registry.
```
docker build . -t registry.int.janelia.org/jacs-scripts/h5j_metadata:1.0.0
docker push registry.int.janelia.org/jacs-scripts/h5j_metadata:1.0.0
export DIR=/dir/to/your/file
docker run -it -v $DIR:$DIR registry.int.janelia.org/jacs-scripts/h5j_metadata:1.0.0 -i $DIR/tile-2607115756248236069.h5j
```

## Run with Nextflow
[Nextflow](https://www.nextflow.io/docs/latest/getstarted.html) is a pipeline orchestrator which can run pipelines locally, on compute clusters, or in the cloud. 
```
nextflow run pipeline.nf
```


