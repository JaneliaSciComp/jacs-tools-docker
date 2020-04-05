# Extract H5J Channels

Extract all channels in an H5J into individual H5J files, each containing one channel

Build:
```
docker build . -t registry.int.janelia.org/jacs-scripts/h5j_extract_channels:1.0.0
```

Run:
```
export DIR=/dir/to/your/file
docker run -v $DIR:$DIR registry.int.janelia.org/jacs-scripts/h5j_extract_channels:1.0.0 -i $DIR/tile-2607115756248236069.h5j -o $DIR
```

