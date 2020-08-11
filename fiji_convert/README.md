# Fiji Image Conversion Macro

Simple image conversion macro which converts between any format Fiji can read and a few chosen formats: tif, zip, nrrd, v3draw. It can also split channels into individual files.

## Build
```
docker build . -t jacs-tools/fiji_convert:latest
```

## Usage

The parameter to the macro is "\<input file>,\<output file>,\<split channels>" where \<split channels> is a 0 or 1.
```
DIR=/path/to/your/image/files
docker run --user `id -u` -v $DIR:$DIR jacs-tools/fiji_convert:latest $DIR/tile.v3draw,$DIR/tile.nrrd,1
```

To run with Singularity, convert to SIF first, and then bind the directory into the container when running:
```
singularity build /tmp/out.sif docker-daemon://jacs-tools/fiji_convert:latest
singularity run -B $DIR /tmp/out.sif $DIR/tile.v3draw,$DIR/tile.nrrd,1
```

