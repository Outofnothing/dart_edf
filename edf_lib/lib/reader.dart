import 'dart:io';
import 'dart:typed_data';

import 'package:edf_lib/edf_header.dart';
import 'package:edf_lib/edf_signal.dart';
import 'package:edf_lib/edf_field.dart';
import 'package:edf_lib/header_times.dart';

class ReadResults {
  final List<EdfSignal> signals;
  final List<dynamic>? annotationSignal;

  ReadResults(this.signals, {this.annotationSignal});
}

/// EDF reader: supports reading from a RandomAccessFile or from an in-memory
/// byte buffer.
class Reader {
  RandomAccessFile? _file;
  Uint8List? _bytes;
  int _pos = 0;

  Reader(RandomAccessFile file) {
    _file = file;
  }

  Reader.fromBytes(Uint8List bytes) {
    _bytes = bytes;
    _pos = 0;
  }

  void dispose() {
    try {
      _file?.closeSync();
    } catch (_) {}
    _file = null;
    _bytes = null;
  }

  void _seek(int offset) {
    if (_file != null) {
      _file!.setPositionSync(offset);
    } else {
      _pos = offset;
    }
  }

  int _position() {
    if (_file != null) return _file!.positionSync();
    return _pos;
  }

  Uint8List _readBytes(int count) {
    if (_file != null) {
      final data = _file!.readSync(count);
      return Uint8List.fromList(data);
    }
    final end = (_pos + count).clamp(0, _bytes!.length) as int;
    final slice = _bytes!.sublist(_pos, end);
    _pos = end;
    return slice;
  }

  /// Read header and return an [EdfHeader].
  EdfHeader readHeader() {
    _seek(0);

    final version = _readAscii(HeaderTimes.version);
    final patientID = _readAscii(HeaderTimes.patientID);
    final recordID = _readAscii(HeaderTimes.recordID);
    final recordingStartDate = _readAscii(HeaderTimes.recordingStartDate);
    final recordingStartTime = _readAscii(HeaderTimes.recordingStartTime);
    final sizeInBytes = _readInt(HeaderTimes.sizeInBytes);
    final reserved = _readAscii(HeaderTimes.reserved);
    final numberOfDataRecords = _readLong(HeaderTimes.numberOfDataRecords);
    final recordDurationInSeconds =
        _readDouble(HeaderTimes.recordDurationInSeconds);
    final numberOfSignalsInRecord =
        _readInt(HeaderTimes.numberOfSignalsInRecord);

    final ns = numberOfSignalsInRecord;
    final labels = _readMultipleAscii(HeaderTimes.label, ns);
    final transducerTypes = _readMultipleAscii(HeaderTimes.transducerType, ns);
    final physicalDimensions =
        _readMultipleAscii(HeaderTimes.physicalDimension, ns);
    final physicalMinimums =
        _readMultipleDouble(HeaderTimes.physicalMinimum, ns);
    final physicalMaximums =
        _readMultipleDouble(HeaderTimes.physicalMaximum, ns);
    final digitalMinimums = _readMultipleInt(HeaderTimes.digitalMinimum, ns);
    final digitalMaximums = _readMultipleInt(HeaderTimes.digitalMaximum, ns);
    final preFilterings = _readMultipleAscii(HeaderTimes.prefiltering, ns);
    final numberOfSamplesPerRecord =
        _readMultipleInt(HeaderTimes.numberOfSamplesInDataRecord, ns);
    final signalsReserved = _readMultipleAscii(HeaderTimes.signalsReserved, ns);

    final header = EdfHeader.withValues(
      version,
      patientID,
      recordID,
      recordingStartDate,
      recordingStartTime,
      sizeInBytes,
      reserved,
      numberOfDataRecords,
      recordDurationInSeconds,
      numberOfSignalsInRecord,
      labels,
      transducerTypes,
      physicalDimensions,
      physicalMinimums,
      physicalMaximums,
      digitalMinimums,
      digitalMaximums,
      preFilterings,
      numberOfSamplesPerRecord,
      signalsReserved,
    );

    return header;
  }

  List<EdfSignal> allocateSignals(EdfHeader header) {
    final ns = header.numberOfSignalsInRecord.value ?? 0;
    final signals = List<EdfSignal>.generate(ns, (i) {
      final numberOfSamplesInRecord = header.numberOfSamplesPerRecord.value![i];
      final frequency = numberOfSamplesInRecord /
          (header.recordDurationInSeconds.value ?? 1.0);
      final totalSamples =
          numberOfSamplesInRecord * (header.numberOfDataRecords.value ?? 0);
      final s = EdfSignal(index: i, frequencyInHZ: frequency);
      s.label.value =
          header.labels.value != null && i < header.labels.value!.length
              ? header.labels.value![i]
              : null;
      s.transducerType.value = header.transducerTypes.value != null &&
              i < header.transducerTypes.value!.length
          ? header.transducerTypes.value![i]
          : null;
      s.physicalDimension.value = header.physicalDimensions.value != null &&
              i < header.physicalDimensions.value!.length
          ? header.physicalDimensions.value![i]
          : null;
      s.physicalMinimum.value = header.physicalMinimums.value != null &&
              i < header.physicalMinimums.value!.length
          ? header.physicalMinimums.value![i]
          : null;
      s.physicalMaximum.value = header.physicalMaximums.value != null &&
              i < header.physicalMaximums.value!.length
          ? header.physicalMaximums.value![i]
          : null;
      s.digitalMinimum.value = header.digitalMinimums.value != null &&
              i < header.digitalMinimums.value!.length
          ? header.digitalMinimums.value![i]
          : null;
      s.digitalMaximum.value = header.digitalMaximums.value != null &&
              i < header.digitalMaximums.value!.length
          ? header.digitalMaximums.value![i]
          : null;
      s.prefiltering.value = header.preFilterings.value != null &&
              i < header.preFilterings.value!.length
          ? header.preFilterings.value![i]
          : null;
      s.reserved.value = header.signalsReserved.value != null &&
              i < header.signalsReserved.value!.length
          ? header.signalsReserved.value![i]
          : null;
      s.numberOfSamplesInDataRecord.value = numberOfSamplesInRecord;
      if (header.startTime != null) {
        s.calculateAllTimeStamps(header.startTime!, frequency, totalSamples);
      }
      return s;
    });

    return signals;
  }

  void readSignal(EdfHeader header, EdfSignal signal) {
    final current = header.startTime?.millisecondsSinceEpoch ?? 0;
    final interval =
        signal.frequencyInHZ == 0 ? 0 : (1000 / signal.frequencyInHZ).toInt();
    _seek(header.sizeInBytes.value ?? 0);

    signal.samples.clear();
    signal.timestamps.clear();
    signal.values.clear();

    final records = header.numberOfDataRecords.value ?? 0;
    for (var j = 0; j < records; j++) {
      final currentPerRecord = current +
          (j * ((header.recordDurationInSeconds.value ?? 0.0) * 1000)).toInt();
      for (var i = 0; i < (header.numberOfSignalsInRecord.value ?? 0); i++) {
        if (i == signal.index) {
          _readNextSignalSamples(signal, currentPerRecord);
        } else {
          _skipSignalSamples(header.numberOfSamplesPerRecord.value![i]);
        }
      }
    }
  }

  ReadResults readSignals(EdfHeader header) {
    final current = header.startTime?.millisecondsSinceEpoch ?? 0;
    final signals = allocateSignals(header);
    final annotation = <dynamic>[];
    final records = header.numberOfDataRecords.value ?? 0;

    for (var j = 0; j < records; j++) {
      final currentPerRecord = current +
          (j * ((header.recordDurationInSeconds.value ?? 0.0) * 1000)).toInt();
      for (var i = 0; i < signals.length; i++) {
        // no special annotation handling implemented here
        _readNextSignalSamples(signals[i], currentPerRecord);
      }
    }

    return ReadResults(signals, annotationSignal: annotation);
  }

  void _readNextSignalSamples(EdfSignal signal, int currentTimestamp) {
    final sampleCount = signal.numberOfSamplesInDataRecord.value ?? 0;
    if (sampleCount == 0) return;
    final interval =
        signal.frequencyInHZ == 0 ? 0 : (1000 / signal.frequencyInHZ).toInt();
    final bytes = _readBytes(sampleCount * 2);
    final bd = bytes.buffer.asByteData();
    var ts = currentTimestamp;
    for (var i = 0; i < sampleCount; i++) {
      final intVal = bd.getInt16(i * 2, Endian.little);
      signal.samples.add(intVal);
      signal.values.add(intVal * signal.scaleFactor());
      signal.timestamps.add(ts);
      ts += interval;
    }
  }

  void _skipSignalSamples(int sampleCount) {
    final toSkip = sampleCount * 2;
    if (_file != null) {
      _file!.setPositionSync(_file!.positionSync() + toSkip);
    } else {
      _pos = (_pos + toSkip).clamp(0, _bytes!.length) as int;
    }
  }

  String _readAscii(EdfField item) {
    final bytes = _readBytes(item.asciiLength);
    return String.fromCharCodes(bytes).trim();
  }

  List<String> _readMultipleAscii(EdfField item, int numberOfParts) {
    final parts = <String>[];
    for (var i = 0; i < numberOfParts; i++) {
      parts.add(_readAscii(item));
    }
    return parts;
  }

  int _readInt(EdfField item) {
    final s = _readAscii(item).trim();
    return int.tryParse(s) ?? 0;
  }

  int _readLong(EdfField item) {
    final s = _readAscii(item).trim();
    return int.tryParse(s) ?? 0;
  }

  double _readDouble(EdfField item) {
    final s = _readAscii(item).trim();
    return double.tryParse(s) ?? 0.0;
  }

  List<int> _readMultipleInt(EdfField item, int numberOfParts) {
    final out = <int>[];
    for (var i = 0; i < numberOfParts; i++) {
      out.add(_readInt(item));
    }
    return out;
  }

  List<double> _readMultipleDouble(EdfField item, int numberOfParts) {
    final out = <double>[];
    for (var i = 0; i < numberOfParts; i++) {
      out.add(_readDouble(item));
    }
    return out;
  }

  List<String> _readMultipleAsciiGeneric(EdfField item, int numberOfParts) {
    return _readMultipleAscii(item, numberOfParts);
  }
}
