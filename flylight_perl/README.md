## Building

```
docker build --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" -t registry.int.janelia.org/jacs-scripts/flylight_perl:1.0.0 .
docker push registry.int.janelia.org/jacs-scripts/flylight_perl:1.0.1
```

## Using on the cluster

First, some environment variables must be set:
```
export LANG=C
export SINGULARITY_BINDPATH='/groups:/groups,/misc/sc/pipeline:/misc/sc/pipeline'
```
You can now use singularity to execute your command:
```
singularity run docker://registry.int.janelia.org/jacs-scripts/flylight_perl:1.0.1 perl /app/SAGE/bin/sage_loader.pl -config /groups/scicomp/informatics/data/flylightflip_light_imagery-config.xml -grammar /misc/sc/pipeline/grammar/projtechres.gra -lab flylight -debug -item "2021/01/06/JPTR_20210108132345995_7223.lsm"
```
