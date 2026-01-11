import 'package:edf_lib/edf_field.dart';
import 'package:edf_lib/header_item.dart';

class VariableLengthDouble extends HeaderItem {
  List<double>? value;

  VariableLengthDouble(EdfField info) : super(info);

  @override
  String toAscii() {
    if (value == null) return '';
    final buffer = StringBuffer();
    for (final doubleVal in value!) {
      var temp = doubleVal.toString();
      if (temp.length > asciiLength) temp = temp.substring(0, asciiLength);
      buffer.write(temp);
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
    return other is VariableLengthDouble && _listEquals(value, other.value);
  }

  @override
  int get hashCode => value?.hashCode ?? 0;

  @override
  String toString() => toAscii();
}
