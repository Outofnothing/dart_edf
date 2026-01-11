import 'package:edf_lib/types/fixed_length_string.dart';
import 'package:edf_lib/types/fixed_length_int.dart';
import 'package:edf_lib/types/fixed_length_double.dart';

abstract class EdfBaseSignal<T> {
  final FixedLengthString label;
  final FixedLengthString transducerType;
  final FixedLengthString physicalDimension;
  final FixedLengthDouble physicalMinimum;
  final FixedLengthDouble physicalMaximum;
  final FixedLengthInt digitalMinimum;
  final FixedLengthInt digitalMaximum;
  final FixedLengthString prefiltering;
  final FixedLengthInt numberOfSamplesInDataRecord;
  final FixedLengthString reserved;

  List<T> samples;

  EdfBaseSignal({
    required this.label,
    required this.transducerType,
    required this.physicalDimension,
    required this.physicalMinimum,
    required this.physicalMaximum,
    required this.digitalMinimum,
    required this.digitalMaximum,
    required this.prefiltering,
    required this.numberOfSamplesInDataRecord,
    required this.reserved,
    List<T>? samples,
  }) : samples = samples ?? <T>[];

  int get samplesCount => samples.length;
}
