#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/third_party/espeak-ng"
DST="$ROOT/packages/espeak/native/espeak-ng"
PATCH_DIR="$ROOT/patches/espeak-ng"

if [ ! -d "$SRC/.git" ]; then
  echo "Missing espeak-ng submodule at $SRC" >&2
  echo "Run: git submodule update --init --recursive third_party/espeak-ng" >&2
  exit 1
fi

if ! git -C "$SRC" diff --quiet || ! git -C "$SRC" diff --cached --quiet; then
  echo "Refusing to export from a dirty espeak-ng submodule." >&2
  exit 1
fi

upstream_commit="$(git -C "$SRC" rev-parse HEAD)"

rm -rf "$DST"
mkdir -p "$DST"

rsync -a --delete --exclude '.git' "$SRC"/ "$DST"/

if [ -d "$PATCH_DIR" ]; then
  for patch in "$PATCH_DIR"/*.patch; do
    [ -e "$patch" ] || continue
    git -C "$DST" apply "$patch"
  done
fi

cat > "$DST/UPSTREAM.md" <<EOF
# espeak-ng Vendored Source

This directory is an exported copy of upstream espeak-ng for pub.dev releases.
Consumers of the published Dart package receive these plain files directly; they
do not need to initialize Git submodules.

- Upstream: https://github.com/espeak-ng/espeak-ng
- Exported commit: $upstream_commit
- Export command: tool/export_espeak_ng.sh
- Local patches: patches/espeak-ng/*.patch

To refresh this vendored source:

1. Update the submodule under third_party/espeak-ng.
2. Add or remove patch files under patches/espeak-ng.
3. Run tool/export_espeak_ng.sh.
4. Review the full generated diff before committing.
EOF

echo "Exported espeak-ng $upstream_commit to $DST"
