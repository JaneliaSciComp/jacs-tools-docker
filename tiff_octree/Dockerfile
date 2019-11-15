FROM julia:1.2.0

WORKDIR /applib
WORKDIR /app

ENV JULIA_DEPOT_PATH /applib:$JULIA_DEPOT_PATH
ENV JULIA_PROJECT /app

COPY Project.toml .
COPY src src

RUN julia -e ' \
    import Pkg; \
    Pkg.instantiate(); \
    Pkg.resolve(); \
    Pkg.build(); \
'

RUN julia -e 'using Images; using ImageMagick; using OctreeBuilder;'

RUN find /applib -type d -exec chmod 777 {} \;
RUN find /applib -type f -exec chmod 666 {} \;
ENTRYPOINT ["julia", "/app/src/main.jl"]
