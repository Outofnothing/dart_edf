import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:edf_lib/reader.dart';
import 'package:edf_lib/edf_header.dart';
import 'package:edf_lib/edf_signal.dart';

void main() => runApp(EdfViewerApp());

class EdfViewerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EDF Viewer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: EdfHomePage(),
    );
  }
}

class EdfHomePage extends StatefulWidget {
  @override
  _EdfHomePageState createState() => _EdfHomePageState();
}

class _EdfHomePageState extends State<EdfHomePage> {
  String _filePath = '';
  String _headerText = '';
  EdfHeader? _header;
  List<EdfSignal>? _signals;
  int _selectedSignal = 0;

  Future<void> _pickAndLoad() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['edf'],
      allowMultiple: false,
    );
    if (result == null) return;
    final path = result.files.single.path;
    if (path == null) return;
    try {
      final bytes = await File(path).readAsBytes();
      final reader = Reader.fromBytes(Uint8List.fromList(bytes));
      final header = reader.readHeader();
      final res = reader.readSignals(header);
      setState(() {
        _filePath = path;
        _header = header;
        _signals = res.signals;
        _headerText = header.toString();
        _selectedSignal = 0;
      });
    } catch (e) {
      setState(() {
        _headerText = 'Error reading file: $e';
        _signals = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final signalCount = _signals?.length ?? 0;
    final selectedSignal = (signalCount > 0 && _selectedSignal < signalCount)
        ? _signals![_selectedSignal]
        : null;

    return Scaffold(
      appBar: AppBar(title: Text('EDF Viewer')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              ElevatedButton(
                  onPressed: _pickAndLoad, child: Text('Select EDF')),
              SizedBox(width: 12),
              Expanded(child: Text(_filePath, overflow: TextOverflow.ellipsis)),
            ]),
            SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Header:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    SelectableText(_headerText),
                    SizedBox(height: 12),
                    if (signalCount > 0) ...[
                      Row(
                        children: [
                          Text('Signal:'),
                          SizedBox(width: 12),
                          DropdownButton<int>(
                            value: _selectedSignal,
                            items: List.generate(signalCount, (i) {
                              final label =
                                  _signals![i].label.value ?? 'Signal $i';
                              return DropdownMenuItem(
                                  value: i, child: Text(label));
                            }),
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _selectedSignal = v);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                          'Plot (first ${selectedSignal?.samplesCount ?? 0} samples):',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      SizedBox(
                        height: 240,
                        child: Container(
                          color: Colors.black12,
                          child: selectedSignal != null
                              ? CustomPaint(
                                  painter:
                                      _LineChartPainter(selectedSignal.values),
                                  size: Size.infinite,
                                )
                              : Center(child: Text('No signal data')),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  _LineChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    if (values.isEmpty) return;

    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final span = (maxV - minV) == 0 ? 1.0 : (maxV - minV);

    final path = Path();
    final stepX = size.width / (values.length - 1).clamp(1, double.infinity);
    for (var i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - ((values[i] - minV) / span) * size.height;
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
