# Fiji Image Conversion Macro

Simple image conversion macro which converts between any format Fiji can read and a few chosen formats: tif, zip, nrrd, v3draw. It can also split channels into individual files.

## Build
```
docker build . -t jacs-tools/fiji_convert:latest
```

## Usage

The parameter to the macro is "<input file>,<output file>,<split channels>" where <split channels> is a 0 or 1.
```
DIR=/path/to/your/image/files
docker run --user `id -u` -v $DIR:$DIR jacs-tools/fiji_convert:latest $DIR/tile-2816195289193381909.v3draw,$DIR/tile-2816195289193381909.nrrd,1
```

To run with Singularity, you need to use `exec` command and explicitly specify the entrypoint script, because otherwise Singularity will look for it in the current directory, since it doesn't respect Docker's WORKDIR.
```
singularity build /tmp/out.sif docker-daemon://jacs-tools/fiji_convert:latest
singularity exec -B $DIR /tmp/out.sif $DIR/tile-2816195289193381909.v3draw,$DIR/tile-2816195289193381909.nrrd,1
```

