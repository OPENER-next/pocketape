import 'dart:async';

import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';

abstract class ArkitTracer {

  static const _platformChannel = MethodChannel('arkit_channel');
  static const _eventChannel = EventChannel('arkit_events');

  // count how many listeners are registered
  static int _count = 0;

  static Stream<Vector3> trace() {
    late StreamSubscription<Vector3> subscription;
    late final StreamController<Vector3> controller;
    controller = StreamController<Vector3>(
      onListen: () async {
        _count++;
        subscription = _eventChannel.receiveBroadcastStream().map(_parse).listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
        if (_count == 1) {
          await _platformChannel.invokeMethod('startMeasure');
        }
      },
      onCancel: () async {
        _count--;
        subscription.cancel();
        if (_count == 0) {
          await _platformChannel.invokeMethod('stopMeasure');
        }
      },
    );
    return controller.stream;
  }

  static Vector3 _parse(dynamic event) {

    var input = event.toString();
    input = input.replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');
    List<String> parts = input.split(',');

    double x = double.parse(parts[0].trim());
    double y = double.parse(parts[1].trim());
    double z = double.parse(parts[2].trim());

    Vector3 vector = Vector3(x, y, z);
    return vector;
  }
}
