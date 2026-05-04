# espeak-ng Upstream Workflow

This repository keeps espeak-ng in two forms:

- `third_party/espeak-ng`: Git submodule used only by maintainers.
- `packages/espeak/native/espeak-ng`: plain vendored source published to pub.dev.

pub.dev consumers should never need to run `git submodule update`. The published
package must contain the exported source files directly.

## Refresh Steps

Pick the upstream revision:

```sh
git submodule update --init --recursive third_party/espeak-ng
git -C third_party/espeak-ng fetch --tags origin
git -C third_party/espeak-ng checkout <tag-or-commit>
```

Maintain package-local patches under `patches/espeak-ng/` as normal `git apply`
patch files relative to the upstream espeak-ng root.

Export the plain source into the package:

```sh
tool/export_espeak_ng.sh
```

Then review and commit all three parts together:

- the submodule pointer under `third_party/espeak-ng`
- the patch files under `patches/espeak-ng/`
- the exported source under `packages/espeak/native/espeak-ng`

Publish from `packages/espeak`, not from the repository root.
