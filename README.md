# dart_edf

Monorepo for EDF read/write in Dart.

Packages:

- `edf_lib` — EDF read/write library (publish to pub.dev)
- `edf_viewer` — CLI viewer that depends on `edf_lib`

Quick start:

```bash
cd /Users/zikang/dev/proj/dart_edf
dart pub get
dart run edf_viewer path/to/file.edf
```
