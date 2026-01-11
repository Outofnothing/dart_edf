import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:edf_lib/edf_signal.dart';
import 'package:edf_lib/edf_header.dart';
import 'package:edf_lib/edf_writer.dart';
import 'package:edf_lib/reader.dart';

/// Represents an EDF file and provides read/write helpers.
class EdfFile {
  EdfHeader? header;
  List<EdfSignal>? signals;
  List<dynamic> annotationSignals = <dynamic>[];
  Reader? reader;

  EdfFile();

  EdfFile.fromParts(this.header, this.signals, this.annotationSignals);

  EdfFile.fromPath(String filePath) {
    readAll(filePath);
  }

  EdfFile.fromBytes(Uint8List edfBytes) {
    readAllBytes(edfBytes);
  }

  @override
  String toString() => 'Header: $header';

  void dispose() {
    try {
      reader?.dispose();
    } catch (_) {}
    reader = null;
  }

  void readBase64(String edfBase64) {
    final bytes = base64Decode(edfBase64);
    readAllBytes(bytes);
  }

  /// Open the given EDF file, read its header and allocate corresponding Signal objects.
  void open(String filePath) {
    // Open file and create a Reader. Reader implementation is expected in the package.
    final file = File(filePath);
    reader = Reader(file.openSync());
    header = reader!.readHeader();
    signals = reader!.allocateSignals(header!);
  }

  /// Read the signal at the given index.
  void readSignal(int index) {
    reader?.readSignal(header!, signals![index]);
  }

  /// Read the signal matching the given name.
  EdfSignal? readSignalByName(String match) {
    final signal = signals?.firstWhereOrNull((s) => s.label.value == match);
    if (signal == null) return null;
    reader?.readSignal(header!, signal);
    return signal;
  }

  /// Read header only from file.
  static EdfHeader readHeader(String filename) {
    final file = File(filename);
    final r = Reader(file.openSync());
    try {
      return r.readHeader();
    } finally {
      try {
        r.dispose();
      } catch (_) {}
    }
  }

  /// Read the whole file into memory
  void readAll(String edfFilePath) {
    final file = File(edfFilePath);
    final r = Reader(file.openSync());
    try {
      header = r.readHeader();
      final result = r.readSignals(header!);
      signals = result.signals as List<EdfSignal>?;
      annotationSignals = result.annotationSignal ?? <dynamic>[];
    } finally {
      try {
        r.dispose();
      } catch (_) {}
    }
  }

  /// Read a whole EDF file from a memory buffer.
  void readAllBytes(Uint8List edfBytes) {
    final r = Reader.fromBytes(edfBytes);
    try {
      header = r.readHeader();
      final result = r.readSignals(header!);
      signals = result.signals as List<EdfSignal>?;
      annotationSignals = result.annotationSignal ?? <dynamic>[];
    } finally {
      try {
        r.dispose();
      } catch (_) {}
    }
  }

  void save(String filePath) {
    if (header == null) return;
    final writer = EdfWriter(File(filePath).openSync());
    try {
      writer.writeEDF(this, filePath);
    } finally {
      try {
        writer.dispose();
      } catch (_) {}
    }
  }
}

extension IterableExtensions<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
