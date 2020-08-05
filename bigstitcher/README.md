# Docker/Singularity image for BigStitcher

Example for containerizing BigStitcher, based on https://github.com/PreibischLab/BigStitcher-Singularity

## Build
```
docker build . -t janeliascicomp/bigstitcher:latest
```

## Run with Docker
```
docker run janeliascicomp/bigstitcher:latest
```

## Run with Singularity
```
singularity build /tmp/out.sif docker-daemon://janeliascicomp/bigstitcher:latest
singularity run /tmp/out.sif
```

