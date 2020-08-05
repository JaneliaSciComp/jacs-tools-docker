# Staged build using builder container
FROM janeliascicomp/builder:1.1.0 as builder
ARG APP_TAG=master

# Checkout and build the code
WORKDIR /tmp/bigstitcher
RUN git clone --branch $APP_TAG --depth 1 https://github.com/PreibischLab/BigStitcher.git . \
    && mvn -Pfatjar clean package

# Find the built jar, based on the version in the pom file
RUN cat pom.xml | grep -A 2 "<artifactId>Big" | grep "<version>" | awk -F ">" '{print $2}' | awk -F "<" '{print $1}' > version \
    && mv /tmp/bigstitcher/target/BigStitcher-`cat version`.jar bigstitcher.jar

# Final image
FROM janeliascicomp/fiji:fiji-openjdk-8
COPY --from=builder /tmp/bigstitcher/bigstitcher.jar /app/bigstitcher.jar
COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh"]
