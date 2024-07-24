import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pocketape/arkitTracer.dart';
// ignore: depend_on_referenced_packages
import 'package:vector_math/vector_math_64.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MeasurementScreen(),
    );
  }
}

class MeasurementScreen extends StatefulWidget {
  @override
  _MeasurementScreenState createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  late Stream<Vector3> _stream;
  Vector3? _firstValue;
  Vector3? _lastValue;
  double distance = 0.00;
  late StreamSubscription<Vector3> _subscription;
  bool _isMeasuring = false;

  @override
  void initState() {
    super.initState();
    _stream = ArkitTracer.trace();
     _subscription = _stream.listen(
        (position) {
          setState(() {
            if (_firstValue == null) {
              _firstValue = position;
            }
            else {
              _lastValue = position;
            }
          });
        },
        onError: (error) {},
        onDone: () {
        },
      );
      _subscription.pause();
  }

  void _toggleMeasurement() {
    if (_isMeasuring) {
      _stopMeasurement();
    } else {
      setState(() {
        _firstValue = null;
        _lastValue = null;
      });
      _startMeasurement();
    }
  }

  void _startMeasurement() {
    if (!_isMeasuring) {
      setState(() {
        _isMeasuring = true;
      });
      _subscription.resume();
    }
  }

  void _stopMeasurement() {
    if (_isMeasuring) {
      _subscription.pause();
      setState(() {
        _isMeasuring = false;
        if (_firstValue != null && _lastValue != null) {
          distance = calculateDistance(_firstValue!, _lastValue!);
        }
      });
    }
  }

  double calculateDistance(Vector3 from, Vector3 to) {
    final deltaX = to.x - from.x;
    final deltaY = to.y - from.y;
    final deltaZ = to.z - from.z;
    
    return sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ);
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ARKit Measurement')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('First Value:'),
            const SizedBox(height: 16),
            Text(
              'X: ${_firstValue?.x.toStringAsFixed(2)}\n'
              'Y: ${_firstValue?.y.toStringAsFixed(2)}\n'
              'Z: ${_firstValue?.z.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 32),
            const Text('Latest Value:'),
            const SizedBox(height: 16),
            Text(
              'X: ${_lastValue?.x.toStringAsFixed(2)}\n'
              'Y: ${_lastValue?.y.toStringAsFixed(2)}\n'
              'Z: ${_lastValue?.z.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _toggleMeasurement,
              child: Text(_isMeasuring ? 'Stop' : 'Start'),
            ),
            const SizedBox(height: 32),
            Text('Distance: ${distance.toStringAsFixed(2)} meters'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_isMeasuring) {
      _subscription.cancel();
    }
    super.dispose();
  }
}
