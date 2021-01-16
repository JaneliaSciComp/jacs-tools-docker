## Building

With [Maru](https://github.com/JaneliaSciComp/maru) installed:
```
maru build --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"
```

Otherwise:
```
docker build --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" -t registry.int.janelia.org/jacs-scripts/flylight_perl:1.0.0 -t registry.int.janelia.org/jacs-scripts/flylight_perl --label "sage_loader_version=1.46" .
docker push registry.int.janelia.org/jacs-scripts/flylight_perl:1.0.1
docker push registry.int.janelia.org/jacs-scripts/flylight_perl
```

## Using on the cluster

First, some environment variables must be set:
```
export SINGULARITY_BINDPATH='/groups:/groups,/misc/sc/pipeline:/misc/sc/pipeline'
```
You can now use singularity to execute your command:
```
singularity run docker://registry.int.janelia.org/jacs-scripts/flylight_perl /app/scripts/cmd/sageLoader.sh -config /groups/scicomp/informatics/data/flylightflip_light_imagery-config.xml -grammar /misc/sc/pipeline/grammar/projtechres.gra -lab flylight -debug -item "2021/01/06/JPTR_20210108132345995_7223.lsm"
```

## Issues
All issues refer to the execution of sageLoader.sh within a Docker container - they do not affect running it standalone.
1. When run inside a Docker container, SAGE loader is currently only able to process image indexing requests (base CV = light_imagery).
2. When run inside a Docker container, SAGE loader does not support the -kafka flag.
3. The use of senndmail from inside a Docker container is currently not set up (this is of minimal concern for image indexing requests).
4. There is sometimes a warning "Redundant argument in printf..." when run inside a Docker container - this is no cause for concern, and will be fixed in a future version.

## Notes
1. The Dockerfile calls for usage of Python - despite the name ("flylight_perl"), while Perl is used for most image indexing requests, some Python is used for FFC and PTR.
