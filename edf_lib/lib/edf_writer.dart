import 'dart:io';
import 'dart:typed_data';

import 'package:edf_lib/edf_file.dart';
import 'package:edf_lib/edf_signal.dart';
import 'package:edf_lib/header_item.dart';

class EdfWriter {
  final RandomAccessFile _out;

  EdfWriter(this._out);

  void writeEDF(EdfFile edf, String edfFilePath) {
    edf.header?.sizeInBytes.value = _calcNumOfBytesInHeader(edf);

    // Fixed length header
    _writeItem(edf.header!.version);
    _writeItem(edf.header!.patientID);
    _writeItem(edf.header!.recordID);
    _writeItem(edf.header!.recordingStartDate);
    _writeItem(edf.header!.recordingStartTime);
    _writeItem(edf.header!.sizeInBytes);
    _writeItem(edf.header!.reserved);
    _writeItem(edf.header!.numberOfDataRecords);
    _writeItem(edf.header!.recordDurationInSeconds);
    _writeItem(edf.header!.numberOfSignalsInRecord);

    // Variable length header (per-signal items)
    final signals = edf.signals ?? <EdfSignal>[];
    _writeItems(signals.map((s) => s.label));
    _writeItems(signals.map((s) => s.transducerType));
    _writeItems(signals.map((s) => s.physicalDimension));
    _writeItems(signals.map((s) => s.physicalMinimum));
    _writeItems(signals.map((s) => s.physicalMaximum));
    _writeItems(signals.map((s) => s.digitalMinimum));
    _writeItems(signals.map((s) => s.digitalMaximum));
    _writeItems(signals.map((s) => s.prefiltering));
    _writeItems(signals.map((s) => s.numberOfSamplesInDataRecord));
    _writeItems(signals.map((s) => s.reserved));

    // Write signals (data records)
    _writeSignals(edf);

    try {
      _out.closeSync();
    } catch (_) {}
  }

  int _calcNumOfBytesInHeader(EdfFile edf) {
    const totalFixedLength = 256;
    var ns = (edf.signals?.length ?? 0);
    if (edf.annotationSignals.isNotEmpty) ns += edf.annotationSignals.length;
    final totalVariableLength =
        ns * 16 + (ns * 80) * 2 + (ns * 8) * 6 + (ns * 32);
    return totalFixedLength + totalVariableLength;
  }

  void _writeItem(HeaderItem item) {
    final s = item.toAscii();
    _out.writeFromSync(Uint8List.fromList(s.codeUnits));
  }

  void _writeItems(Iterable<HeaderItem> items) {
    final buffer = StringBuffer();
    for (final it in items) {
      buffer.write(it.toAscii());
    }
    _out.writeFromSync(Uint8List.fromList(buffer.toString().codeUnits));
  }

  void _writeSignals(EdfFile edf) {
    final header = edf.header!;
    final signals = edf.signals ?? <EdfSignal>[];
    final records = header.numberOfDataRecords.value ?? 0;
    for (var recordIndex = 0; recordIndex < records; recordIndex++) {
      for (final signal in signals) {
        final samplesPerRecord = signal.numberOfSamplesInDataRecord.value ?? 0;
        final start = recordIndex * samplesPerRecord;
        final end = (start + samplesPerRecord).clamp(0, signal.samples.length);
        final count = end - start;
        if (count <= 0) {
          // write zeros for the full block
          _out.writeFromSync(Uint8List(samplesPerRecord * 2));
          continue;
        }

        final bytes = Uint8List(count * 2);
        final bd = bytes.buffer.asByteData();
        for (var i = 0; i < count; i++) {
          bd.setInt16(i * 2, signal.samples[start + i], Endian.little);
        }
        _out.writeFromSync(bytes);
      }

      // annotations: if present, try to write, otherwise pad per-signal
      if (edf.annotationSignals.isNotEmpty) {
        for (final a in edf.annotationSignals) {
          // try to get sampleCount per record
          int sampleCountPerRecord = 0;
          try {
            sampleCountPerRecord = a.numberOfSamplesInDataRecord?.value ??
                a.numberOfSamplesInDataRecord ??
                0;
          } catch (_) {
            sampleCountPerRecord = 0;
          }
          final blockSize = sampleCountPerRecord * 2;
          if (blockSize <= 0) continue;
          // No TAL encoding implemented: write zeros
          _out.writeFromSync(Uint8List(blockSize));
        }
      }
    }
  }

  void dispose() {
    try {
      _out.closeSync();
    } catch (_) {}
  }
}
