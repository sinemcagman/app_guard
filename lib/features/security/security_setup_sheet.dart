import 'package:flutter/material.dart';

import '../../localization/app_strings.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_guard_logo.dart';
import '../../widgets/pin_keypad.dart';

class SecuritySetupResult {
  const SecuritySetupResult(this.pin, this.enableBiometrics);
  final String pin;
  final bool enableBiometrics;
}

class SecuritySetupSheet extends StatefulWidget {
  const SecuritySetupSheet({super.key, this.requiredForActivation = false});

  final bool requiredForActivation;

  static Future<SecuritySetupResult?> show(
    BuildContext context, {
    bool requiredForActivation = false,
  }) {
    return showModalBottomSheet<SecuritySetupResult>(
      context: context,
      isScrollControlled: true,
      isDismissible: !requiredForActivation,
      enableDrag: !requiredForActivation,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          SecuritySetupSheet(requiredForActivation: requiredForActivation),
    );
  }

  @override
  State<SecuritySetupSheet> createState() => _SecuritySetupSheetState();
}

class _SecuritySetupSheetState extends State<SecuritySetupSheet> {
  String _pin = '';
  String? _initialPin;
  String? _error;
  bool _enableBiometrics = false;

  void _addDigit(String digit) {
    if (_pin.length == 4) return;
    setState(() {
      _error = null;
      _pin += digit;
    });
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _error = null;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  void _continue() {
    if (_pin.length != 4) return;
    if (_initialPin == null) {
      setState(() {
        _initialPin = _pin;
        _pin = '';
      });
      return;
    }
    if (_pin != _initialPin) {
      setState(() {
        _error = AppStrings.pinsDoNotMatch;
        _pin = '';
      });
      return;
    }
    Navigator.of(context).pop(SecuritySetupResult(_pin, _enableBiometrics));
  }

  @override
  Widget build(BuildContext context) {
    final confirming = _initialPin != null;
    return PopScope(
      canPop: !widget.requiredForActivation,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640),
        decoration: const BoxDecoration(
          color: AppColors.surfaceLow,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppGuardLogo(size: 58),
              const SizedBox(height: 18),
              Text(
                confirming
                    ? AppStrings.confirmPin
                    : AppStrings.setSecurityMethod,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                confirming
                    ? AppStrings.confirmPinDescription
                    : AppStrings.createPinDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              PinKeypad(
                pinLength: _pin.length,
                onDigit: _addDigit,
                onBackspace: _backspace,
                compact: true,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.alertSoft),
                ),
              ],
              const SizedBox(height: 14),
              SwitchListTile.adaptive(
                value: _enableBiometrics,
                onChanged: (value) => setState(() => _enableBiometrics = value),
                activeTrackColor: AppColors.cyan,
                title: const Text(AppStrings.enableBiometricUnlock),
                subtitle: const Text(AppStrings.biometricDescription),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _pin.length == 4 ? _continue : null,
                  icon: Icon(
                    confirming
                        ? Icons.verified_user_outlined
                        : Icons.lock_outline,
                  ),
                  label: Text(
                    confirming
                        ? widget.requiredForActivation
                              ? AppStrings.saveExitPin
                              : AppStrings.activateAndLock
                        : AppStrings.setMasterPin,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.cyanBright,
                    foregroundColor: AppColors.cyanDark,
                    disabledBackgroundColor: AppColors.surfaceHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (!widget.requiredForActivation)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(AppStrings.cancelAndReturn),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
