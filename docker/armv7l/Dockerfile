# Node.js linux-armv7l runtime image based on Debian stable slim.
# The node binary comes from this repository's GitHub Releases
# (tag: armv7l-<version>), not from nodejs.org.
#
# Build for armhf:
#   docker buildx build --platform linux/arm/v7 \
#     --build-arg NODE_VERSION=v26.8.1 \
#     --build-arg RELEASE_REPO=TS-228/unofficial-builds \
#     -t node-armv7l:v26.8.1 \
#     -f docker/armv7l/Dockerfile .

FROM debian:stable-slim

ARG NODE_VERSION
ARG RELEASE_REPO=TS-228/unofficial-builds
ARG RELEASE_TAG=

# Node.js 25+ binaries need libatomic at runtime.
RUN set -eux; \
    if [ -z "${NODE_VERSION}" ]; then \
      echo "NODE_VERSION build-arg is required (e.g. v26.8.1)" >&2; \
      exit 1; \
    fi; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      xz-utils \
      libatomic1; \
    TAG="${RELEASE_TAG:-armv7l-${NODE_VERSION}}"; \
    BASE="https://github.com/${RELEASE_REPO}/releases/download/${TAG}"; \
    curl -fsSLO "${BASE}/node-${NODE_VERSION}-linux-armv7l.tar.xz"; \
    curl -fsSLO "${BASE}/SHASUMS256.txt"; \
    grep " node-${NODE_VERSION}-linux-armv7l.tar.xz\$" SHASUMS256.txt | sha256sum -c -; \
    tar -xJf "node-${NODE_VERSION}-linux-armv7l.tar.xz" -C /usr/local --strip-components=1; \
    rm -f "node-${NODE_VERSION}-linux-armv7l.tar.xz" SHASUMS256.txt; \
    rm -rf \
      /usr/local/CHANGELOG.md \
      /usr/local/LICENSE \
      /usr/local/README.md \
      /usr/local/share/doc \
      /usr/local/share/man \
      /usr/local/share/systemtap; \
    apt-get purge -y --auto-remove curl xz-utils; \
    rm -rf /var/lib/apt/lists/*; \
    node --version; \
    npm --version

WORKDIR /app
CMD ["node"]
