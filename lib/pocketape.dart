import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class Pocketape {

  static const _platformChannel = MethodChannel('ar_channel');
  static const _eventChannel = EventChannel('ar_events');

  // count how many listeners are registered
  static int _count = 0;

  static Stream<Vector3> trace() {
    late StreamSubscription<Vector3> subscription;
    late final StreamController<Vector3> controller;
    controller = StreamController<Vector3>(
      onListen: () async {
        if (_count == 0 && Platform.isAndroid && !(await _requestPermission())) {
          controller.addError(CameraPermissionDeniedException("Camera permission is required on Android in order to use ARCore."));
        }
        _count++;
        subscription = _eventChannel.receiveBroadcastStream().map(_parse).listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
        if (_count == 1) {
          print("Start");
          await _platformChannel.invokeMethod('startMeasure');
        }
      },
      onCancel: () async {
        _count--;
        if (_count == 0) {
          await _platformChannel.invokeMethod('stopMeasure');
        }
        await subscription.cancel();
      },
    );
    return controller.stream;
  }

  static Stream<({Vector3 from, Vector3 to})> traceRange() {
    Vector3? first;
    return trace().map((pos) {
      first ??= pos;
      return (from: first!, to: pos);
    });
  }

  static Future<bool> _requestPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  static Vector3 _parse(dynamic event) {
    List<Object?> coordinates = event;

    double x = coordinates[0]! as double;
    double y = coordinates[1]! as double;
    double z = coordinates[2]! as double;
    print("$x $y $z");
    Vector3 vector = Vector3(x, y, z);
    return vector;
  }
}

class CameraPermissionDeniedException implements Exception {
  final String message;
  CameraPermissionDeniedException(this.message);
  
  @override
  String toString() => 'CameraPermissionDeniedException: $message';
}
