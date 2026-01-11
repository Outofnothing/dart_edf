import 'package:flutter/material.dart';
import 'package:edf_lib/edf_lib.dart';

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
  final _controller = TextEditingController();
  String _output = '';

  Future<void> _load() async {
    final path = _controller.text.trim();
    if (path.isEmpty) return;
    final reader = EdfReaderWriter();
    try {
      final edf = await reader.read(path);
      setState(() {
        _output = 'Opened: ${edf.path}\nHeader:\n${edf.header}';
      });
    } catch (e) {
      setState(() {
        _output = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('EDF Viewer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Path to EDF file'),
            ),
            SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: Text('Load')),
            SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(_output),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
