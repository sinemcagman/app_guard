import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_strings.dart';
import 'app_failure.dart';

class SecurityService {
  static const _pinHashKey = 'master_pin_hash';
  static const _biometricsKey = 'biometrics_enabled';
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  String _hash(String pin) => sha256.convert(utf8.encode(pin)).toString();

  Future<bool> hasPin() async =>
      (await SharedPreferences.getInstance()).containsKey(_pinHashKey);

  Future<void> savePin(String pin, {required bool enableBiometrics}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_pinHashKey, _hash(pin));
    await preferences.setBool(_biometricsKey, enableBiometrics);
  }

  Future<bool> verifyPin(String pin) async {
    final storedHash = (await SharedPreferences.getInstance()).getString(
      _pinHashKey,
    );
    return storedHash != null && storedHash == _hash(pin);
  }

  Future<bool> biometricsEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_biometricsKey) ?? false;

  Future<bool> authenticateWithBiometrics() async {
    try {
      if (!await _localAuthentication.canCheckBiometrics ||
          !await _localAuthentication.isDeviceSupported()) {
        throw const AppFailure(AppStrings.biometricUnavailable);
      }
      final enrolled = await _localAuthentication.getAvailableBiometrics();
      if (enrolled.isEmpty) {
        throw const AppFailure(AppStrings.noBiometricCredential);
      }
      return _localAuthentication.authenticate(
        localizedReason: AppStrings.biometricReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure(AppStrings.biometricUnavailable);
    }
  }
}
