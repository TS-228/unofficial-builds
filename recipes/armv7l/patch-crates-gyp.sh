#!/bin/bash
# Point each GYP toolset at its own rustc target. Host tools are 32-bit x86
# (gcc-14 -m32); the Node binary is armv7. A single libnode_crates.a cannot
# serve both. Safe no-op on Node < 26 (no deps/crates/crates.gyp).
set -euo pipefail

if [ ! -f deps/crates/crates.gyp ]; then
  echo "No deps/crates/crates.gyp; skipping rust crate toolset patch"
  exit 0
fi

python3 - <<'GYPPATCH'
import re
path = 'deps/crates/crates.gyp'
src = open(path).read()
pattern = re.compile(
    r"'link_settings':\s*\{\s*'libraries':\s*\[\s*'<\(node_crates_libpath\)',\s*\]", re.S)
replacement = """'link_settings': {
        'target_conditions': [
          ['_toolset=="host"', {
            'libraries': ['<(SHARED_INTERMEDIATE_DIR)/i686-unknown-linux-gnu/release/libnode_crates.a'],
          }],
          ['_toolset=="target"', {
            'libraries': ['<(SHARED_INTERMEDIATE_DIR)/armv7-unknown-linux-gnueabihf/release/libnode_crates.a'],
          }],
        ]"""
patched, count = pattern.subn(replacement, src, count=1)
assert count == 1, 'crates.gyp link_settings pattern not found'
open(path, 'w').write(patched)
print('Patched deps/crates/crates.gyp for i686 host + armv7 target crates')
GYPPATCH
