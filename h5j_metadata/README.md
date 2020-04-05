# H5J Metadata Reader/Writer

Can be used to read or write the H5J metadata in YAML format.

Build
```
docker build . -t registry.int.janelia.org/jacs-scripts/h5j_metadata:1.0.0
```

Usage
```
export DIR=/dir/to/your/file
docker run -it -v $DIR:$DIR registry.int.janelia.org/jacs-scripts/h5j_metadata:1.0.0 -d $DIR/tile-2607115756248236069.h5j > metadata.yaml
docker run -it -v $DIR:$DIR registry.int.janelia.org/jacs-scripts/h5j_metadata:1.0.0 -d $DIR/tile-2607115756248236069.h5j < metadata.yaml

```
