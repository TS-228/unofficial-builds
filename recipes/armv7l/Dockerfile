FROM ubuntu:24.04

ARG GID=1000
ARG UID=1000

ENV RUSTUP_HOME=/opt/rustup \
    CARGO_HOME=/opt/cargo \
    CARGO_REAL=/opt/cargo/bin/cargo \
    RUSTC=/opt/cargo/bin/rustc \
    PATH="/usr/local/bin:/opt/cargo/bin:${PATH}"

RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y \
         adduser \
         git \
         gcc-14 \
         g++-14 \
         gcc-14-multilib \
         g++-14-multilib \
         libc6-dev-i386 \
         lib32stdc++-14-dev \
         curl \
         make \
         python3.10 \
         ccache \
         xz-utils \
         gcc-14-arm-linux-gnueabihf \
         g++-14-arm-linux-gnueabihf \
         gcc-14-arm-linux-gnueabihf-base \
    && echo '#include <cstdint>' | g++-14 -m32 -x c++ -c - -o /dev/null

RUN ln -s /usr/include/x86_64-linux-gnu/asm /usr/include/asm

# Temporal (Node 26+) needs rustc >= 1.82. Distro rustc is too old; install a
# pinned upstream toolchain plus the 32-bit host and armv7 target stds.
# Hashes are not pinned here because rustup verifies its own downloads.
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
      sh -s -- -y --default-toolchain 1.91.1 --profile minimal --no-modify-path \
    && /opt/cargo/bin/rustup target add i686-unknown-linux-gnu armv7-unknown-linux-gnueabihf \
    && chmod -R a+rX /opt/rustup /opt/cargo

RUN (addgroup --gid $GID node || groupmod -n node $(getent group $GID | cut -d: -f1)) \
    && (adduser --gid $GID --uid $UID --disabled-password --gecos "" node || usermod -l node -g $GID -d /home/node -m $(getent passwd $UID | cut -d: -f1))

RUN rm -f /usr/bin/python3
RUN ln -s /usr/bin/python3.10 /usr/bin/python3

COPY --chmod=755 host-cc.sh /usr/local/bin/gcc-14-m32
COPY --chmod=755 host-cxx.sh /usr/local/bin/g++-14-m32
COPY --chmod=755 cargo-shim.sh /usr/local/bin/cargo
COPY --chown=node:node run.sh patch-crates-gyp.sh cargo-config.toml /home/node/

VOLUME /home/node/.ccache
VOLUME /out
VOLUME /home/node/node.tar.xz

USER node

ENTRYPOINT [ "/home/node/run.sh" ]
