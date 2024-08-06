import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pocketape/pocketape.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    _checkCameraPermission();
    return const MaterialApp(
      home: MeasurementScreen(),
    );
  }
}

class MeasurementScreen extends StatefulWidget {
  const MeasurementScreen({super.key});

  @override
  State<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  Stream<({Vector3 from, Vector3 to})>? _stream;
  bool get isMeasuring => _stream != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ARKit Measurement')),
      body: Center(
        child: StreamBuilder<({Vector3 from, Vector3 to})>(
          initialData: (from: Vector3.zero(), to: Vector3.zero()),
          stream: _stream,
          builder: (context, snapshot) {
            final from = snapshot.requireData.from;
            final to = snapshot.requireData.to;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('First Value:'),
                const SizedBox(height: 16),
                Text(
                  'X: ${from.x.toStringAsFixed(2)}, '
                  'Y: ${from.y.toStringAsFixed(2)},'
                  'Z: ${from.z.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 32),
                const Text('Latest Value:'),
                const SizedBox(height: 16),
                Text(
                  'X: ${to.x.toStringAsFixed(2)}, '
                  'Y: ${to.y.toStringAsFixed(2)}, '
                  'Z: ${to.z.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _toggleMeasurement,
                  child: Text(isMeasuring ? 'Stop' : 'Start'),
                ),
                const SizedBox(height: 32),
                Text('Free Distance: ${from.distanceTo(to).toStringAsFixed(2)} meters'),
                const SizedBox(height: 32),
                Text( _adjustMeasurement(from, to)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _toggleMeasurement() {
    setState(() {
      _stream = isMeasuring ? null : Pocketape.traceRange();
    });
  }

  String _adjustMeasurement(Vector3 first, Vector3 last) {
    var difX = (last.x - first.x).abs();
    var difZ = (last.z - first.z).abs();
    var difY = (last.y - first.y).abs();
    if (difY > difZ && difY > difX) {
      return "Vertical measure: ${difY.toStringAsFixed(2)}";
    }
    else{
      var newDistance = difZ < difX ? difX : difZ;
      return "Horizontal measure: ${newDistance.toStringAsFixed(2)}";
    }
  }
}
