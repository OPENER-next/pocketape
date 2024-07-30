import 'dart:async';

import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';

abstract class ArkitTracer {

  static const _platformChannel = MethodChannel('ar_channel');
  static const _eventChannel = EventChannel('ar_events');

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
    List<Object?> coordinates = event;

    double x = coordinates[0]! as double;
    double y = coordinates[1]! as double;
    double z = coordinates[2]! as double;

    Vector3 vector = Vector3(x, y, z);
    return vector;
  }
}
