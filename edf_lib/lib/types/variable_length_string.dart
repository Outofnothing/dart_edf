import 'package:edf_lib/edf_field.dart';
import 'package:edf_lib/header_item.dart';

class VariableLengthString extends HeaderItem {
  List<String>? value;

  VariableLengthString(EdfField info) : super(info);

  @override
  String toAscii() {
    if (value == null) return '';
    final buffer = StringBuffer();
    for (final str in value!) {
      buffer.write(str.padRight(asciiLength, ' '));
    }
    return buffer.toString();
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
    return other is VariableLengthString && _listEquals(value, other.value);
  }

  @override
  int get hashCode => value?.hashCode ?? 0;

  @override
  String toString() => toAscii();
}
