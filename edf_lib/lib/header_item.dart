import 'package:edf_lib/edf_field.dart';

abstract class HeaderItem {
  final String name;
  final int asciiLength;

  HeaderItem(EdfField fieldInfo)
      : name = fieldInfo.name,
        asciiLength = fieldInfo.asciiLength;

  String toAscii();
}
