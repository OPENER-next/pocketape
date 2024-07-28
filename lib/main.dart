import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pocketape/arkit_tracer.dart';
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
  Vector3? _firstValue;
  Vector3? _lastValue;
  late StreamSubscription<Vector3>? _subscription;
  bool get isMeasuring => _subscription != null;
  double _distance = 0.0;
  String _replacementResult = '';

  @override
  void initState() {
    super.initState();
    _subscription = null;
  }

  void _toggleMeasurement() {
    if (isMeasuring) {
      _stopMeasurement();
    } else {
      _firstValue = null;
      _lastValue = null;
      _startMeasurement();
    }
  }

  void _startMeasurement() {
    if (!isMeasuring) {
      _subscription = ArkitTracer.trace().listen(
        (position) {
          setState(() {
            if (_firstValue == null) {
              _firstValue = position;
            }
            else {
              _lastValue = position;
              _distance = _firstValue!.distanceTo(_lastValue!);
              _ajustMeasurement();
            }
          });
        },
        onError: (error) {},
        onDone: () {
        },
      );
    }
  }

  void _ajustMeasurement() {
    var difX = (_lastValue!.x - _firstValue!.x).abs();
    var difZ = (_lastValue!.z - _firstValue!.z).abs();
    var difY = (_lastValue!.y - _firstValue!.y).abs();
    if (difY > difZ && difY > difX) {
      var newEnd = Vector3(_firstValue!.x, _lastValue!.y, _firstValue!.z);
      var newDistance = _firstValue!.distanceTo(newEnd);
      _replacementResult = "Vertical measure: ${newDistance.toStringAsFixed(2)}";
    }
    else{ 
      var newEnd = (difZ < difX)
          ? Vector3(_lastValue!.x, _firstValue!.y, _firstValue!.z)
          : Vector3(_firstValue!.x, _firstValue!.y, _lastValue!.z);
      var newDistance = _firstValue!.distanceTo(newEnd);
      _replacementResult = "Horizontal measure: ${newDistance.toStringAsFixed(2)}";
    }
  }

  void _stopMeasurement() {
    if (isMeasuring) {
      _subscription!.cancel();
      setState(() {
        _subscription = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ARKit Measurement')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('First Value:'),
            const SizedBox(height: 16),
            Text(
              'X: ${_firstValue?.x.toStringAsFixed(2)}, '
              'Y: ${_firstValue?.y.toStringAsFixed(2)},'
              'Z: ${_firstValue?.z.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 32),
            const Text('Latest Value:'),
            const SizedBox(height: 16),
            Text(
              'X: ${_lastValue?.x.toStringAsFixed(2)}, '
              'Y: ${_lastValue?.y.toStringAsFixed(2)}, '
              'Z: ${_lastValue?.z.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _toggleMeasurement,
              child: Text(isMeasuring ? 'Stop' : 'Start'),
            ),
            const SizedBox(height: 32),
            Text('Free Distance: ${_distance.toStringAsFixed(2)} meters'),
            const SizedBox(height: 32),
            Text('Coodinate Replacement: \n$_replacementResult'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (isMeasuring) {
      _subscription!.cancel();
      _subscription = null;
    }
    super.dispose();
  }
}
