# H5J Metadata Reader/Writer

Can be used to read or write the H5J metadata in YAML format.

Build
```
docker build . -t jacs-scripts/h5j_metadata:1.0.0
```

Local Usage
```
export DIR=/path/to/your/h5j/file
# Read metadata from H5J and write metadata.yaml
docker run -it -v $DIR:$DIR jacs-scripts/h5j_metadata:1.0.0 -i $DIR/tile-2607115756248236069.h5j -m metadata.yaml
# Read metadata from metadata.yaml and write to H5J
docker run -it -v $DIR:$DIR jacs-scripts/h5j_metadata:1.0.0 -o $DIR/tile-2607115756248236069.h5j -m metadata.yaml
```

Run with Singularity
```
singularity build /tmp/out.sif docker-daemon://jacs-scripts/h5j_metadata:1.0.0
singularity run -B $DIR /tmp/out.sif -i $DIR/tile-2607115756248236069.h5j
```

Distribution using Docker Registry
```
docker build . -t registry.int.janelia.org/jacs-scripts/h5j_metadata:1.0.0
docker push registry.int.janelia.org/jacs-scripts/h5j_metadata:1.0.0
export DIR=/dir/to/your/file
docker run -it -v $DIR:$DIR registry.int.janelia.org/jacs-scripts/h5j_metadata:1.0.0 -d $DIR/tile-2607115756248236069.h5j > metadata.yaml
```
