import 'package:edf_lib/edf_signal.dart';
import 'package:edf_lib/types/fixed_length_string.dart';
import 'package:edf_lib/types/fixed_length_int.dart';
import 'package:edf_lib/types/fixed_length_double.dart';
import 'package:edf_lib/types/variable_length_string.dart';
import 'package:edf_lib/types/variable_length_int.dart';
import 'package:edf_lib/types/variable_length_double.dart';
import 'package:edf_lib/header_times.dart';

class EdfHeader {
  DateTime? startTime;
  DateTime? endTime;

  final FixedLengthString version;
  final FixedLengthString patientID;
  final FixedLengthString recordID;
  final FixedLengthString recordingStartDate;
  final FixedLengthString recordingStartTime;
  final FixedLengthInt sizeInBytes;
  final FixedLengthString reserved;
  final FixedLengthInt numberOfDataRecords;
  final FixedLengthDouble recordDurationInSeconds;
  final FixedLengthInt numberOfSignalsInRecord;

  final VariableLengthString labels;
  final VariableLengthString transducerTypes;
  final VariableLengthString physicalDimensions;
  final VariableLengthDouble physicalMinimums;
  final VariableLengthDouble physicalMaximums;
  final VariableLengthInt digitalMinimums;
  final VariableLengthInt digitalMaximums;
  final VariableLengthString preFilterings;
  final VariableLengthInt numberOfSamplesPerRecord;
  final VariableLengthString signalsReserved;

  double get totalDurationInSeconds {
    final n = numberOfDataRecords.value ?? 0;
    final d = recordDurationInSeconds.value ?? 0.0;
    return n * d;
  }

  EdfHeader()
      : version = FixedLengthString(HeaderTimes.version),
        patientID = FixedLengthString(HeaderTimes.patientID),
        recordID = FixedLengthString(HeaderTimes.recordID),
        recordingStartDate = FixedLengthString(HeaderTimes.recordingStartDate),
        recordingStartTime = FixedLengthString(HeaderTimes.recordingStartTime),
        sizeInBytes = FixedLengthInt(HeaderTimes.sizeInBytes),
        reserved = FixedLengthString(HeaderTimes.reserved),
        numberOfDataRecords = FixedLengthInt(HeaderTimes.numberOfDataRecords),
        recordDurationInSeconds =
            FixedLengthDouble(HeaderTimes.recordDurationInSeconds),
        numberOfSignalsInRecord =
            FixedLengthInt(HeaderTimes.numberOfSignalsInRecord),
        labels = VariableLengthString(HeaderTimes.label),
        transducerTypes = VariableLengthString(HeaderTimes.transducerType),
        physicalDimensions =
            VariableLengthString(HeaderTimes.physicalDimension),
        physicalMinimums = VariableLengthDouble(HeaderTimes.physicalMinimum),
        physicalMaximums = VariableLengthDouble(HeaderTimes.physicalMaximum),
        digitalMinimums = VariableLengthInt(HeaderTimes.digitalMinimum),
        digitalMaximums = VariableLengthInt(HeaderTimes.digitalMaximum),
        preFilterings = VariableLengthString(HeaderTimes.prefiltering),
        numberOfSamplesPerRecord =
            VariableLengthInt(HeaderTimes.numberOfSamplesInDataRecord),
        signalsReserved = VariableLengthString(HeaderTimes.signalsReserved);

  EdfHeader.withValues(
    String versionStr,
    String patientId,
    String recordId,
    String recordingStartDateStr,
    String recordingStartTimeStr,
    int sizeInBytesVal,
    String reservedStr,
    int numberOfDataRecordsVal,
    double recordDurationInSecondsVal,
    int numberOfSignalsInRecordVal,
    List<String> labelsArr,
    List<String> transducerTypesArr,
    List<String> physicalDimensionsArr,
    List<double> physicalMinimumsArr,
    List<double> physicalMaximumsArr,
    List<int> digitalMinimumsArr,
    List<int> digitalMaximumsArr,
    List<String> preFilteringsArr,
    List<int> numberOfSamplesPerRecordArr,
    List<String> signalsReservedArr,
  )   : version = FixedLengthString(HeaderTimes.version),
        patientID = FixedLengthString(HeaderTimes.patientID),
        recordID = FixedLengthString(HeaderTimes.recordID),
        recordingStartDate = FixedLengthString(HeaderTimes.recordingStartDate),
        recordingStartTime = FixedLengthString(HeaderTimes.recordingStartTime),
        sizeInBytes = FixedLengthInt(HeaderTimes.sizeInBytes),
        reserved = FixedLengthString(HeaderTimes.reserved),
        numberOfDataRecords = FixedLengthInt(HeaderTimes.numberOfDataRecords),
        recordDurationInSeconds =
            FixedLengthDouble(HeaderTimes.recordDurationInSeconds),
        numberOfSignalsInRecord =
            FixedLengthInt(HeaderTimes.numberOfSignalsInRecord),
        labels = VariableLengthString(HeaderTimes.label),
        transducerTypes = VariableLengthString(HeaderTimes.transducerType),
        physicalDimensions =
            VariableLengthString(HeaderTimes.physicalDimension),
        physicalMinimums = VariableLengthDouble(HeaderTimes.physicalMinimum),
        physicalMaximums = VariableLengthDouble(HeaderTimes.physicalMaximum),
        digitalMinimums = VariableLengthInt(HeaderTimes.digitalMinimum),
        digitalMaximums = VariableLengthInt(HeaderTimes.digitalMaximum),
        preFilterings = VariableLengthString(HeaderTimes.prefiltering),
        numberOfSamplesPerRecord =
            VariableLengthInt(HeaderTimes.numberOfSamplesInDataRecord),
        signalsReserved = VariableLengthString(HeaderTimes.signalsReserved) {
    version.value = versionStr;
    patientID.value = patientId;
    recordID.value = recordId;
    recordingStartDate.value = recordingStartDateStr;
    recordingStartTime.value = recordingStartTimeStr;
    sizeInBytes.value = sizeInBytesVal;
    reserved.value = reservedStr;
    numberOfDataRecords.value = numberOfDataRecordsVal;
    recordDurationInSeconds.value = recordDurationInSecondsVal;
    numberOfSignalsInRecord.value = numberOfSignalsInRecordVal;
    labels.value = labelsArr;
    transducerTypes.value = transducerTypesArr;
    physicalDimensions.value = physicalDimensionsArr;
    physicalMinimums.value = physicalMinimumsArr;
    physicalMaximums.value = physicalMaximumsArr;
    digitalMinimums.value = digitalMinimumsArr;
    digitalMaximums.value = digitalMaximumsArr;
    preFilterings.value = preFilteringsArr;
    numberOfSamplesPerRecord.value = numberOfSamplesPerRecordArr;
    signalsReserved.value = signalsReservedArr;

    startTime = _getDateTime(
        recordingStartDate.value ?? '', recordingStartTime.value ?? '');
    endTime = startTime?.add(Duration(seconds: totalDurationInSeconds.toInt()));
  }

  DateTime _getDateTime(String datePart, String timePart) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(0);
    try {
      final dParts = datePart.split('.');
      if (dParts.length == 3) {
        final day = int.tryParse(dParts[0]) ?? 1;
        final month = int.tryParse(dParts[1]) ?? 1;
        var year = int.tryParse(dParts[2]) ?? 0;
        // two-digit year -> assume 2000+
        if (year < 100) year += 2000;
        date = DateTime(year, month, day);
      }
    } catch (_) {}

    try {
      final tParts = timePart.split('.');
      if (tParts.length == 3) {
        final hour = int.tryParse(tParts[0]) ?? 0;
        final minute = int.tryParse(tParts[1]) ?? 0;
        final second = int.tryParse(tParts[2]) ?? 0;
        date = DateTime(date.year, date.month, date.day, hour, minute, second);
      }
    } catch (_) {}

    return date;
  }

  DateTime recordTime(int recordIndex) {
    final start = startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
    final secondsPerRecord = recordDurationInSeconds.value ?? 0.0;
    return start.add(Duration(
        milliseconds: (recordIndex * secondsPerRecord * 1000).toInt()));
  }

  DateTime sampleTime(EdfSignal signal, int sampleIndex) {
    final samplesPerRecord = signal.numberOfSamplesInDataRecord.value ?? 1;
    final recordIndex = (sampleIndex / samplesPerRecord).floor();
    final modulo = sampleIndex % samplesPerRecord;
    final recordTimeDt = recordTime(recordIndex);
    final ms = (recordDurationInSeconds.value ?? 0.0) *
        1000 *
        modulo /
        samplesPerRecord;
    return recordTimeDt.add(Duration(milliseconds: ms.toInt()));
  }

  @override
  String toString() {
    final sb = StringBuffer();
    sb.writeln('\n---------- Header ---------');
    sb.writeln('8b\tVersion [${version.value}]');
    sb.writeln('80b\tPatient ID [${patientID.value}]');
    sb.writeln('80b\tRecording ID [${recordID.value}]');
    sb.writeln('8b\tRecording start date [${recordingStartDate.value}]');
    sb.writeln('8b\tRecording start time [${recordingStartTime.value}]');
    sb.writeln('8b\tHeader size (bytes) [${sizeInBytes.value}]');
    sb.writeln('44b\tReserved [${reserved.value}]');
    sb.writeln('8b\tRecord count [${numberOfDataRecords.value}]');
    sb.writeln(
        '8b\tRecord duration in seconds [${recordDurationInSeconds.value}]');
    sb.writeln('4b\tSignal count [${numberOfSignalsInRecord.value}]\n');

    final ns = numberOfSignalsInRecord.value ?? 0;
    for (var i = 0; i < ns; i++) {
      final labelVal = labels.value != null && i < labels.value!.length
          ? labels.value![i]
          : '';
      sb.writeln('\tSignal $i: $labelVal\n');
      final trans =
          transducerTypes.value != null && i < transducerTypes.value!.length
              ? transducerTypes.value![i]
              : '';
      final phys = physicalDimensions.value != null &&
              i < physicalDimensions.value!.length
          ? physicalDimensions.value![i]
          : '';
      final pmin =
          physicalMinimums.value != null && i < physicalMinimums.value!.length
              ? physicalMinimums.value![i]
              : '';
      final pmax =
          physicalMaximums.value != null && i < physicalMaximums.value!.length
              ? physicalMaximums.value![i]
              : '';
      final dmin =
          digitalMinimums.value != null && i < digitalMinimums.value!.length
              ? digitalMinimums.value![i]
              : '';
      final dmax =
          digitalMaximums.value != null && i < digitalMaximums.value!.length
              ? digitalMaximums.value![i]
              : '';
      final pre = preFilterings.value != null && i < preFilterings.value!.length
          ? preFilterings.value![i]
          : '';
      final nspr = numberOfSamplesPerRecord.value != null &&
              i < numberOfSamplesPerRecord.value!.length
          ? numberOfSamplesPerRecord.value![i]
          : '';
      final sres =
          signalsReserved.value != null && i < signalsReserved.value!.length
              ? signalsReserved.value![i]
              : '';
      sb.writeln('\t\tTransducer type [$trans]');
      sb.writeln('\t\tPhysical dimension [$phys]');
      sb.writeln('\t\tPhysical minimum [$pmin]');
      sb.writeln('\t\tPhysical maximum [$pmax]');
      sb.writeln('\t\tDigital minimum [$dmin]');
      sb.writeln('\t\tDigital maximum [$dmax]');
      sb.writeln('\t\tPrefiltering [$pre]');
      sb.writeln('\t\tSample count per record [$nspr]');
      sb.writeln('\t\tSignals reserved [$sres]\n');
    }

    sb.writeln('\n-----------------------------------\n');
    return sb.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EdfHeader &&
        startTime == other.startTime &&
        endTime == other.endTime &&
        version == other.version &&
        patientID == other.patientID &&
        recordID == other.recordID &&
        recordingStartDate == other.recordingStartDate &&
        recordingStartTime == other.recordingStartTime &&
        sizeInBytes == other.sizeInBytes &&
        reserved == other.reserved &&
        numberOfDataRecords == other.numberOfDataRecords &&
        recordDurationInSeconds == other.recordDurationInSeconds &&
        numberOfSignalsInRecord == other.numberOfSignalsInRecord &&
        labels == other.labels &&
        transducerTypes == other.transducerTypes &&
        physicalDimensions == other.physicalDimensions &&
        physicalMinimums == other.physicalMinimums &&
        physicalMaximums == other.physicalMaximums &&
        digitalMinimums == other.digitalMinimums &&
        digitalMaximums == other.digitalMaximums &&
        preFilterings == other.preFilterings &&
        numberOfSamplesPerRecord == other.numberOfSamplesPerRecord &&
        signalsReserved == other.signalsReserved;
  }

  @override
  int get hashCode => Object.hashAll([
        startTime,
        endTime,
        version.value,
        patientID.value,
        recordID.value,
        recordingStartDate.value,
        recordingStartTime.value,
        sizeInBytes.value,
        reserved.value,
        numberOfDataRecords.value,
        recordDurationInSeconds.value,
        numberOfSignalsInRecord.value,
        labels.value?.length ?? 0,
        transducerTypes.value?.length ?? 0,
        physicalDimensions.value?.length ?? 0,
        physicalMinimums.value?.length ?? 0,
        physicalMaximums.value?.length ?? 0,
        digitalMinimums.value?.length ?? 0,
        digitalMaximums.value?.length ?? 0,
        preFilterings.value?.length ?? 0,
        numberOfSamplesPerRecord.value?.length ?? 0,
        signalsReserved.value?.length ?? 0,
      ]);
}
