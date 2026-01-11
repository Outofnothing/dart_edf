import 'package:edf_lib/edf_field.dart';
import 'package:edf_lib/header_item.dart';

class FixedLengthInt extends HeaderItem {
  int? value;

  FixedLengthInt(EdfField info) : super(info);

  @override
  String toAscii() {
    final s = value?.toString() ?? '';
    return s.padRight(asciiLength, ' ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FixedLengthInt && other.value == value;
  }

  @override
  int get hashCode => value?.hashCode ?? 0;

  @override
  String toString() => toAscii();
}
