library edf_lib;

import 'dart:io';

class EdfFile {
  final String path;
  final Map<String, dynamic> header = {};
  EdfFile(this.path);
}

class EdfReaderWriter {
  Future<EdfFile> read(String path) async {
    final f = File(path);
    if (!await f.exists()) throw Exception('File not found: $path');
    // TODO: 实现真实的 EDF 解析，这里仅做占位返回
    return EdfFile(path)..header.addAll({'note': 'placeholder header'});
  }

  Future<void> write(String path, EdfFile file) async {
    final f = File(path);
    await f.writeAsString('EDF placeholder for ${file.path}');
  }
}
