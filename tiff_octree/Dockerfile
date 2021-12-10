FROM julia:1.2.0

WORKDIR /applib
WORKDIR /app

ENV JULIA_DEPOT_PATH /applib:$JULIA_DEPOT_PATH
ENV JULIA_PROJECT /app

COPY Project.toml .
COPY src src
COPY octree.sh /

RUN julia -e ' \
    import Pkg; \
    Pkg.instantiate(); \
    Pkg.resolve(); \
    Pkg.build(); \
'

RUN julia -e 'using Images; using ImageMagick; using OctreeBuilder;'

RUN find /applib -type d -exec chmod 2777 {} \;
RUN find /applib -type f -exec chmod 666 {} \;
RUN chmod 2777 /octree.sh
ENTRYPOINT ["/octree.sh"]
