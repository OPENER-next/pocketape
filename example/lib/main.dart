import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pocketape/pocketape.dart';
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
  StreamSubscription<Vector3>? _subscription= null;
  bool get isMeasuring => _subscription != null;

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
      _subscription = Pocketape.trace().listen(
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
    }
  }

  String _adjustMeasurement() {
    var difX = (_lastValue!.x - _firstValue!.x).abs();
    var difZ = (_lastValue!.z - _firstValue!.z).abs();
    var difY = (_lastValue!.y - _firstValue!.y).abs();
    if (difY > difZ && difY > difX) {
      return "Vertical measure: ${difY.toStringAsFixed(2)}";
    }
    else{ 
      var newDistance = difZ < difX ? difX : difZ;
      return "Horizontal measure: ${newDistance.toStringAsFixed(2)}";
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
            Text('Free Distance: ${(_firstValue != null && _lastValue != null)
              ? _firstValue!.distanceTo(_lastValue!).toStringAsFixed(2)
              : '0.00'} meters'),
            const SizedBox(height: 32),
            Text('Coordinate Replacement: \n${(_firstValue != null && _lastValue != null)
              ? _adjustMeasurement()
              : ''}'
            ),
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
