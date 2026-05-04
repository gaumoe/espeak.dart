## 0.1.3

- Fixed Apple native builds by defining little-endian conversion macros.
- Fixed espeak-ng data paths longer than 160 characters on Apple platforms.
- Prevented `espeak_Initialize` from terminating the host process on failure.
- Linked `libm` for native code asset builds on non-Windows platforms.
- Suppressed `tmpnam` deprecation warnings from the espeak-ng native build.

## 0.1.1

- Added `bin/compile_data.dart` — run via `dart run espeak:compile_data`.
- Auto-downloads espeak-ng source on first run (no manual clone needed).
- Updated README with correct setup instructions.

## 0.1.0

- Initial release.
- FFI bindings for espeak-ng (text to phonemes).
- Punctuation-aware phonemization with clause terminators.
- Data compiler tool for building phoneme/dictionary data from source.
- Cross-platform: macOS, Linux, iOS, Android.
