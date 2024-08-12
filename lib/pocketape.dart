import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class Pocketape {

  static const _eventChannel = EventChannel('ar_events');

  static Stream<Vector3> trace() {
    late StreamSubscription<Vector3> subscription;
    late final StreamController<Vector3> controller;
    controller = StreamController<Vector3>(
      onListen: () async {
        if (Platform.isAndroid && !(await Permission.camera.request().isGranted)) {
          controller.addError(CameraPermissionDeniedException("Camera permission is required on Android in order to use ARCore."));
          return;
        }
        subscription = _eventChannel.receiveBroadcastStream().map(_parse).listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
      },
      onCancel: () async {
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
