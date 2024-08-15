import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:permission_handler/permission_handler.dart';


abstract class Pocketape {

  static const _eventChannel = EventChannel('ar_events');
  static final _dataStream = _eventChannel.receiveBroadcastStream().map(_parse);

  /// Track the device position in space.
  ///
  /// This initially starts at 0,0,0 when the stream isn't listened to already.

  static Stream<Vector3> trace() async* {
    if (Platform.isAndroid && !(await Permission.camera.request().isGranted)) {
      throw CameraPermissionDeniedException("Camera permission is required on Android in order to use ARCore.");
    }
    yield* _dataStream;
  }

  /// Track the first and latest device position in space.
  ///
  /// The first value will be 0,0,0 when the stream isn't listened to already.

  static Stream<({Vector3 from, Vector3 to})> traceRange() {
    Vector3? first;
    return trace().map((pos) {
      first ??= pos;
      return (from: first!, to: pos);
    });
  }

  static Vector3 _parse(dynamic event) {
    List<double> coordinates = event.cast<double>();
    return Vector3(
      coordinates[0],
      coordinates[1],
      coordinates[2],
    );
  }
}


class CameraPermissionDeniedException implements Exception {
  final String message;
  CameraPermissionDeniedException(this.message);

  @override
  String toString() => 'CameraPermissionDeniedException: $message';
}
