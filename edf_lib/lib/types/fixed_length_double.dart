import 'package:edf_lib/edf_field.dart';
import 'package:edf_lib/header_item.dart';

class FixedLengthDouble extends HeaderItem {
  double? value;

  FixedLengthDouble(EdfField info) : super(info);

  @override
  String toAscii() {
    final s = value?.toString() ?? '';
    if (s.length >= asciiLength) {
      return s.substring(0, asciiLength);
    }
    return s.padRight(asciiLength, ' ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FixedLengthDouble && other.value == value;
  }

  @override
  int get hashCode => value?.hashCode ?? 0;

  @override
  String toString() => toAscii();
}
