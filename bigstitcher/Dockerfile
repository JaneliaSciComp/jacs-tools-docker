# Staged build using builder container
FROM janeliascicomp/builder:1.2.0 as builder
ARG APP_TAG=master

# Checkout and build the code
WORKDIR /tmp/bigstitcher
RUN git clone --branch $APP_TAG --depth 1 https://github.com/PreibischLab/BigStitcher.git . \
    && mvn -Pfatjar clean package

# Find the built jar, based on the version in the pom file
RUN xq -r '.project.artifactId+"-"+.project.version+".jar"' pom.xml > filename \
    && mv /tmp/bigstitcher/target/`cat filename` bigstitcher.jar

# Final image
FROM janeliascicomp/fiji:fiji-openjdk-8
COPY --from=builder /tmp/bigstitcher/bigstitcher.jar /app/bigstitcher.jar
RUN printf "#!/bin/bash\njava -cp /app/bigstitcher.jar net.preibisch.mvrecon.fiji.plugin.resave.Resave_N5\n" \
    >> /entrypoint.sh \
    && chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh"]
