import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_strings.dart';
import '../models/security_credential_type.dart';
import 'app_failure.dart';

class SecurityService {
  static const _pinHashKey = 'master_pin_hash';
  static const _credentialTypeKey = 'security_credential_type';
  static const _biometricsKey = 'biometrics_enabled';
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  String _hash(String pin) => sha256.convert(utf8.encode(pin)).toString();

  Future<bool> hasCredential() async =>
      (await SharedPreferences.getInstance()).containsKey(_pinHashKey);

  Future<bool> hasPin() => hasCredential();

  Future<SecurityCredentialType> credentialType() async {
    final preferences = await SharedPreferences.getInstance();
    return SecurityCredentialType.fromStorage(
      preferences.getString(_credentialTypeKey),
    );
  }

  Future<void> saveCredential(
    String credential, {
    required SecurityCredentialType type,
    required bool enableBiometrics,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_pinHashKey, _hash(credential));
    await preferences.setString(_credentialTypeKey, type.storageValue);
    await preferences.setBool(_biometricsKey, enableBiometrics);
  }

  Future<void> savePin(String pin, {required bool enableBiometrics}) async {
    await saveCredential(
      pin,
      type: SecurityCredentialType.numericPin,
      enableBiometrics: enableBiometrics,
    );
  }

  Future<bool> verifyCredential(String credential) async {
    final storedHash = (await SharedPreferences.getInstance()).getString(
      _pinHashKey,
    );
    return storedHash != null && storedHash == _hash(credential);
  }

  Future<bool> verifyPin(String pin) => verifyCredential(pin);

  Future<bool> biometricsEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_biometricsKey) ?? false;

  Future<bool> authenticateWithBiometrics() async {
    try {
      if (!await biometricsEnabled()) {
        throw const AppFailure(AppStrings.biometricDisabled);
      }
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
