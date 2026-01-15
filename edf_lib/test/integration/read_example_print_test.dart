import 'dart:io';

import 'package:test/test.dart';
import 'package:edf_lib/edf_file.dart';

void main() {
  test('read example.edf and print main contents', () {
    final path = 'test/example.edf';
    final f = File(path);
    expect(f.existsSync(), isTrue, reason: 'example.edf must exist at $path');

    final edf = EdfFile();
    edf.readAll(path);

    // Print header and signal summaries
    print('=== EDF Header ===');
    print(edf.header.toString());

    final signals = edf.signals ?? <dynamic>[];
    print('Signals count: ${signals.length}');
    for (var s in signals) {
      print(
          'Signal ${s.index}: label=${s.label.value} samples=${s.samples.length} first=${s.samples.take(10).toList()}');
    }

    // Basic assertion to make test meaningful
    expect(edf.header, isNotNull);
  });
}
