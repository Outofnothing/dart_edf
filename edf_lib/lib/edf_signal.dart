import 'package:edf_lib/edf_base_signal.dart';
import 'package:edf_lib/types/fixed_length_string.dart';
import 'package:edf_lib/types/fixed_length_int.dart';
import 'package:edf_lib/types/fixed_length_double.dart';
import 'package:edf_lib/header_times.dart';

class EdfSignal extends EdfBaseSignal<int> {
  int index;
  double frequencyInHZ;
  List<int> timestamps = <int>[]; // nanoseconds since epoch
  List<double> values = <double>[];
  List<DateTime>? _times;

  EdfSignal({this.index = 0, this.frequencyInHZ = 0.0})
      : super(
          label: FixedLengthString(HeaderTimes.label),
          transducerType: FixedLengthString(HeaderTimes.transducerType),
          physicalDimension: FixedLengthString(HeaderTimes.physicalDimension),
          physicalMinimum: FixedLengthDouble(HeaderTimes.physicalMinimum),
          physicalMaximum: FixedLengthDouble(HeaderTimes.physicalMaximum),
          digitalMinimum: FixedLengthInt(HeaderTimes.digitalMinimum),
          digitalMaximum: FixedLengthInt(HeaderTimes.digitalMaximum),
          prefiltering: FixedLengthString(HeaderTimes.prefiltering),
          numberOfSamplesInDataRecord:
              FixedLengthInt(HeaderTimes.numberOfSamplesInDataRecord),
          reserved: FixedLengthString(HeaderTimes.signalsReserved),
          samples: <int>[],
        );

  List<DateTime> get times {
    if (_times == null || _times!.length != samples.length) {
      _times = timestamps
          .map((t) => DateTime.fromMillisecondsSinceEpoch(t))
          .toList();
    }
    return _times!;
  }

  set times(List<DateTime>? value) => _times = value;

  int get samplesCount => samples.length;

  double scaledSample(int aIndex) => samples[aIndex] * scaleFactor();

  double scaleFactor() {
    final pMax = physicalMaximum.value ?? 0.0;
    final pMin = physicalMinimum.value ?? 0.0;
    final dMax = (digitalMaximum.value ?? 0).toDouble();
    final dMin = (digitalMinimum.value ?? 0).toDouble();
    final denom = (dMax - dMin);
    if (denom == 0) return 0.0;
    return (pMax - pMin) / denom;
  }

  @override
  String toString() {
    final firstTen = samples.take(10).join(',');
    return '${label.value ?? ''} ${numberOfSamplesInDataRecord.value ?? ''}/${samples.length} [$firstTen ...]';
  }

  void calculateAllTimeStamps(
      DateTime startTime, double frequency, int totalSamples) {
    // Placeholder: implement timestamp calculation if needed.
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EdfSignal &&
        index == other.index &&
        label == other.label &&
        transducerType == other.transducerType &&
        physicalDimension == other.physicalDimension &&
        physicalMinimum == other.physicalMinimum &&
        physicalMaximum == other.physicalMaximum &&
        digitalMinimum == other.digitalMinimum &&
        digitalMaximum == other.digitalMaximum &&
        prefiltering == other.prefiltering &&
        numberOfSamplesInDataRecord == other.numberOfSamplesInDataRecord &&
        reserved == other.reserved &&
        frequencyInHZ == other.frequencyInHZ &&
        _listEquals(samples, other.samples);
  }

  @override
  int get hashCode => Object.hashAll([
        index,
        label.value,
        transducerType.value,
        physicalDimension.value,
        physicalMinimum.value,
        physicalMaximum.value,
        digitalMinimum.value,
        digitalMaximum.value,
        prefiltering.value,
        numberOfSamplesInDataRecord.value,
        reserved.value,
        frequencyInHZ,
        samples.length,
        timestamps.length,
      ]);
}
