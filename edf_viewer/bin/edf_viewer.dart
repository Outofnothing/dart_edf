import 'dart:io';
import 'package:edf_lib/edf_lib.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: edf_viewer <path/to/file.edf>');
    exit(1);
  }
  final path = args[0];
  final reader = EdfReaderWriter();
  try {
    final edf = await reader.read(path);
    print('Opened EDF: ${edf.path}');
    print('Header: ${edf.header}');
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(2);
  }
}
