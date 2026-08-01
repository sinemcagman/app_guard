import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import '../models/installed_app.dart';
import 'app_failure.dart';

enum PlatformEvent { unauthorizedExit }

abstract interface class PlatformAppGateway {
  Future<List<InstalledApp>> getLaunchableApps();
  Future<void> startPinnedMode();
  Future<void> launchApp(String packageName);
  Future<void> stopPinnedMode();
}

class PlatformAppService implements PlatformAppGateway {
  PlatformAppService._() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  static final instance = PlatformAppService._();
  static const _channel = MethodChannel('app_guard/platform');
  final _events = StreamController<PlatformEvent>.broadcast();

  Stream<PlatformEvent> get events => _events.stream;

  Future<void> _handleNativeCall(MethodCall call) async {
    if (call.method == 'unauthorizedExitDetected') {
      _events.add(PlatformEvent.unauthorizedExit);
    }
  }

  @override
  Future<List<InstalledApp>> getLaunchableApps() async {
    if (!Platform.isAndroid) return demoApplications;
    try {
      final raw = await _channel.invokeListMethod<Object?>('getLaunchableApps');
      return (raw ?? const [])
          .whereType<Map<Object?, Object?>>()
          .map(InstalledApp.fromPlatform)
          .toList(growable: false);
    } on PlatformException catch (error) {
      throw AppFailure.fromCode(error.code);
    }
  }

  @override
  Future<void> startPinnedMode() async {
    if (!Platform.isAndroid) {
      throw AppFailure.fromCode('UNSUPPORTED_PLATFORM');
    }
    try {
      await _channel.invokeMethod<void>('startPinnedMode');
    } on PlatformException catch (error) {
      throw AppFailure.fromCode(error.code);
    }
  }

  @override
  Future<void> launchApp(String packageName) async {
    if (!Platform.isAndroid) {
      throw AppFailure.fromCode('UNSUPPORTED_PLATFORM');
    }
    try {
      await _channel.invokeMethod<void>('launchApp', {
        'packageName': packageName,
      });
    } on PlatformException catch (error) {
      throw AppFailure.fromCode(error.code);
    }
  }

  @override
  Future<void> stopPinnedMode() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('stopPinnedMode');
    } on PlatformException {
      // The device may already have left lock-task mode; no user action is needed.
    }
  }
}
