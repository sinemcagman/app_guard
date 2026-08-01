import 'package:flutter/material.dart';

import '../../localization/app_strings.dart';
import '../../services/security_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_guard_logo.dart';
import '../../widgets/pin_keypad.dart';

class PinVerificationSheet extends StatefulWidget {
  const PinVerificationSheet({required this.securityService, super.key});

  final SecurityService securityService;

  static Future<bool> show(
    BuildContext context, {
    required SecurityService securityService,
  }) async {
    return await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (_) =>
              PinVerificationSheet(securityService: securityService),
        ) ??
        false;
  }

  @override
  State<PinVerificationSheet> createState() => _PinVerificationSheetState();
}

class _PinVerificationSheetState extends State<PinVerificationSheet> {
  String _pin = '';
  String? _error;
  bool _checking = false;

  void _addDigit(String digit) {
    if (_checking || _pin.length == 4) {
      return;
    }
    setState(() {
      _error = null;
      _pin += digit;
    });
    if (_pin.length == 4) {
      _verify();
    }
  }

  void _backspace() {
    if (_checking || _pin.isEmpty) {
      return;
    }
    setState(() {
      _error = null;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _verify() async {
    setState(() => _checking = true);
    final isValid = await widget.securityService.verifyPin(_pin);
    if (!mounted) {
      return;
    }
    if (isValid) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _checking = false;
      _pin = '';
      _error = AppStrings.incorrectPin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 640),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppGuardLogo(size: 58),
            const SizedBox(height: 18),
            Text(
              AppStrings.currentExitPin,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.currentExitPinDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            PinKeypad(
              pinLength: _pin.length,
              onDigit: _addDigit,
              onBackspace: _backspace,
              compact: true,
            ),
            if (_checking) ...[
              const SizedBox(height: 18),
              const CircularProgressIndicator(color: AppColors.cyan),
            ] else if (_error != null) ...[
              const SizedBox(height: 14),
              Text(_error!, style: const TextStyle(color: AppColors.alertSoft)),
            ],
            const SizedBox(height: 10),
            TextButton(
              onPressed: _checking
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: const Text(AppStrings.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
