import 'package:flutter/material.dart';

import '../../localization/app_strings.dart';
import '../../services/app_failure.dart';
import '../../services/security_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_guard_logo.dart';
import '../../widgets/pin_keypad.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({
    required this.securityService,
    required this.onUnlocked,
    super.key,
  });

  final SecurityService securityService;
  final Future<void> Function() onUnlocked;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = '';
  String? _error;
  bool _checking = false;

  void _addDigit(String digit) {
    if (_pin.length == 4 || _checking) return;
    setState(() {
      _error = null;
      _pin += digit;
    });
    if (_pin.length == 4) _verifyPin();
  }

  void _backspace() {
    if (_pin.isEmpty || _checking) return;
    setState(() {
      _error = null;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _verifyPin() async {
    setState(() => _checking = true);
    final valid = await widget.securityService.verifyPin(_pin);
    if (!mounted) return;
    if (valid) {
      await widget.onUnlocked();
    } else {
      setState(() {
        _checking = false;
        _pin = '';
        _error = AppStrings.incorrectPin;
      });
    }
  }

  Future<void> _authenticate() async {
    try {
      if (await widget.securityService.authenticateWithBiometrics()) {
        await widget.onUnlocked();
      }
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: .98),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 780;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: compact ? 18 : 32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (compact ? 36 : 64),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        AppGuardLogo(size: compact ? 74 : 92, alert: true),
                        SizedBox(height: compact ? 16 : 24),
                        Text(
                          AppStrings.unauthorizedExit,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: compact ? 25 : 29,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppStrings.authenticationRequired,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: compact ? 20 : 30,
                      ),
                      child: PinKeypad(
                        pinLength: _pin.length,
                        onDigit: _addDigit,
                        onBackspace: _backspace,
                        compact: compact,
                        showLetters: true,
                      ),
                    ),
                    Column(
                      children: [
                        if (_checking)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: CircularProgressIndicator(
                              color: AppColors.cyan,
                            ),
                          )
                        else if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.alertSoft,
                              ),
                            ),
                          ),
                        Semantics(
                          button: true,
                          label: AppStrings.tapToScan,
                          child: InkWell(
                            onTap: _authenticate,
                            borderRadius: BorderRadius.circular(18),
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  AppGuardLogo(size: 62),
                                  SizedBox(height: 8),
                                  Text(
                                    AppStrings.tapToScan,
                                    style: TextStyle(
                                      color: AppColors.cyan,
                                      letterSpacing: 1.6,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.securityLayer,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.outline.withValues(alpha: .45),
                                letterSpacing: 2,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
