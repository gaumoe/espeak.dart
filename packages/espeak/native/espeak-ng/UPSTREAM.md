# espeak-ng Vendored Source

This directory is a plain-file vendored copy of upstream espeak-ng for pub.dev
releases. Consumers of the published Dart package receive these files directly;
they do not need to initialize Git submodules.

The maintenance workflow lives at the repository root:

- `third_party/espeak-ng` tracks upstream as a Git submodule.
- `patches/espeak-ng/*.patch` contains package-local source patches.
- `tool/export_espeak_ng.sh` exports the submodule into this directory.

The current vendored tree predates this tracking workflow, so it has not been
regenerated in this change. The export tool is the path for the next upstream
refresh, where the generated diff should be reviewed as a normal vendored source
update.
