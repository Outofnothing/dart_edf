import 'package:edf_lib/edf_field.dart';
import 'package:edf_lib/header_item.dart';

class FixedLengthString extends HeaderItem {
  String? value;

  FixedLengthString(EdfField info) : super(info);

  @override
  String toAscii() {
    final s = value ?? '';
    return s.padRight(asciiLength, ' ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FixedLengthString && other.value == value;
  }

  @override
  int get hashCode => value?.hashCode ?? 0;

  @override
  String toString() => toAscii();
}
