import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:edf_lib/reader.dart';
import 'package:edf_lib/edf_header.dart';
import 'package:edf_lib/edf_signal.dart';
import 'signal_chart.dart';

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
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.black54,
                      tabs: [
                        Tab(text: 'Header'),
                        Tab(text: 'Signals'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildHeaderView(),
                          _buildSignalsView(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(8.0),
      child:
          SelectableText(_headerText.isEmpty ? 'No file loaded.' : _headerText),
    );
  }

  Widget _buildSignalsView() {
    if (_signals == null || _signals!.isEmpty) {
      return Center(child: Text('No signals loaded.'));
    }

    return ListView.builder(
      itemCount: _signals!.length,
      itemBuilder: (context, index) {
        final signal = _signals![index];
        final label = signal.label.value?.trim() ?? 'Signal $index';

        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label (Freq: ${signal.frequencyInHZ} Hz, Samples: ${signal.samplesCount})',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: SignalChart(
                    data: signal.values,
                    frequency: signal.frequencyInHZ,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
