#!/bin/sh

# Node's gyp runs one shared cargo action for both toolsets, but mksnapshot
# (host, 32-bit x86) and node (target, armv7) each need their own architecture's
# crates. Build both triples; run.sh / the CI workflow patch crates.gyp to point
# each toolset at its own. Upstream does per-platform target selection for
# Windows in deps/crates/cargo_build.py; Linux cross-compilation has no
# equivalent yet.
set -e

HOST_TRIPLE=i686-unknown-linux-gnu
CROSS_TRIPLE=armv7-unknown-linux-gnueabihf

if [ -n "$CARGO_REAL" ]; then
  CARGO="$CARGO_REAL"
elif [ -x /opt/cargo/bin/cargo ]; then
  CARGO=/opt/cargo/bin/cargo
elif [ -x "$HOME/.cargo/bin/cargo" ]; then
  CARGO="$HOME/.cargo/bin/cargo"
else
  CARGO=/usr/bin/cargo
fi

targetdir=""
prev=""
for arg in "$@"; do
  if [ "$prev" = "--target-dir" ]; then
    targetdir="$arg"
  fi
  prev="$arg"
done

# only gyp's build invocations pass --target-dir; everything else (e.g.
# `cargo --version` from node's configure) passes through untouched
if [ -z "$targetdir" ]; then
  exec "$CARGO" "$@"
fi

"$CARGO" "$@" --target "$HOST_TRIPLE"
"$CARGO" "$@" --target "$CROSS_TRIPLE"

# gyp's action output is the triple-less path; satisfy its freshness check
if [ -n "$targetdir" ]; then
  for profile in release debug; do
    if [ -f "${targetdir}/${CROSS_TRIPLE}/${profile}/libnode_crates.a" ]; then
      mkdir -p "${targetdir}/${profile}"
      cp "${targetdir}/${CROSS_TRIPLE}/${profile}/libnode_crates.a" "${targetdir}/${profile}/"
    fi
  done
fi
