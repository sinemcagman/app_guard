import 'package:flutter/material.dart';

import '../../localization/app_strings.dart';
import '../../models/security_credential_type.dart';
import '../../services/security_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_guard_logo.dart';
import '../../widgets/pattern_input.dart';
import 'security_setup_sheet.dart';

class CredentialSetupFlow {
  const CredentialSetupFlow._();

  static Future<bool> show(
    BuildContext context, {
    required SecurityService securityService,
    required bool requiredForActivation,
    SecurityCredentialType? preferredType,
  }) async {
    final type =
        preferredType ??
        await _CredentialTypeSheet.show(
          context,
          requiredForActivation: requiredForActivation,
        );
    if (type == null || !context.mounted) {
      return false;
    }

    final _CredentialSetupResult? result;
    switch (type) {
      case SecurityCredentialType.numericPin:
        final pinResult = await SecuritySetupSheet.show(
          context,
          requiredForActivation: requiredForActivation,
        );
        result = pinResult == null
            ? null
            : _CredentialSetupResult(pinResult.pin, pinResult.enableBiometrics);
      case SecurityCredentialType.pattern:
        result = await _PatternSetupSheet.show(
          context,
          requiredForActivation: requiredForActivation,
        );
      case SecurityCredentialType.textPassword:
        result = await _PasswordSetupSheet.show(
          context,
          requiredForActivation: requiredForActivation,
        );
    }
    if (result == null) {
      return false;
    }
    await securityService.saveCredential(
      result.secret,
      type: type,
      enableBiometrics: result.enableBiometrics,
    );
    return true;
  }
}

class _CredentialSetupResult {
  const _CredentialSetupResult(this.secret, this.enableBiometrics);
  final String secret;
  final bool enableBiometrics;
}

class _CredentialTypeSheet extends StatelessWidget {
  const _CredentialTypeSheet({required this.requiredForActivation});

  final bool requiredForActivation;

  static Future<SecurityCredentialType?> show(
    BuildContext context, {
    required bool requiredForActivation,
  }) => showModalBottomSheet<SecurityCredentialType>(
    context: context,
    isScrollControlled: true,
    isDismissible: !requiredForActivation,
    enableDrag: !requiredForActivation,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _CredentialTypeSheet(requiredForActivation: requiredForActivation),
  );

  IconData _icon(SecurityCredentialType type) => switch (type) {
    SecurityCredentialType.numericPin => Icons.pin_outlined,
    SecurityCredentialType.pattern => Icons.gesture,
    SecurityCredentialType.textPassword => Icons.password_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !requiredForActivation,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        decoration: const BoxDecoration(
          color: AppColors.surfaceLow,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppGuardLogo(size: 58),
            const SizedBox(height: 16),
            Text(
              AppStrings.chooseExitMethod,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              AppStrings.chooseExitMethodDescription,
              style: TextStyle(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            for (final type in SecurityCredentialType.values) ...[
              ListTile(
                onTap: () => Navigator.of(context).pop(type),
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icon(type), color: AppColors.cyan),
                ),
                title: Text(
                  type.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(type.description),
                trailing: const Icon(Icons.chevron_right),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.outlineVariant),
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (!requiredForActivation)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(AppStrings.cancel),
              ),
          ],
        ),
      ),
    );
  }
}

class _PatternSetupSheet extends StatefulWidget {
  const _PatternSetupSheet({required this.requiredForActivation});

  final bool requiredForActivation;

  static Future<_CredentialSetupResult?> show(
    BuildContext context, {
    required bool requiredForActivation,
  }) => showModalBottomSheet<_CredentialSetupResult>(
    context: context,
    isScrollControlled: true,
    isDismissible: !requiredForActivation,
    enableDrag: !requiredForActivation,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _PatternSetupSheet(requiredForActivation: requiredForActivation),
  );

  @override
  State<_PatternSetupSheet> createState() => _PatternSetupSheetState();
}

class _PatternSetupSheetState extends State<_PatternSetupSheet> {
  String? _firstPattern;
  String? _error;
  int _attempt = 0;
  bool _enableBiometrics = false;

  String _encode(List<int> pattern) => pattern.join('-');

  void _complete(List<int> pattern) {
    if (pattern.length < 4) {
      setState(() {
        _error = AppStrings.patternTooShort;
        _attempt++;
      });
      return;
    }
    final encoded = _encode(pattern);
    if (_firstPattern == null) {
      setState(() {
        _firstPattern = encoded;
        _error = null;
        _attempt++;
      });
      return;
    }
    if (_firstPattern != encoded) {
      setState(() {
        _error = AppStrings.patternsDoNotMatch;
        _attempt++;
      });
      return;
    }
    Navigator.of(
      context,
    ).pop(_CredentialSetupResult(encoded, _enableBiometrics));
  }

  @override
  Widget build(BuildContext context) {
    final confirming = _firstPattern != null;
    return PopScope(
      canPop: !widget.requiredForActivation,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        decoration: const BoxDecoration(
          color: AppColors.surfaceLow,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppGuardLogo(size: 56),
              const SizedBox(height: 14),
              Text(
                confirming
                    ? AppStrings.confirmPattern
                    : AppStrings.createPattern,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                confirming
                    ? AppStrings.drawPatternAgain
                    : AppStrings.drawPattern,
                style: const TextStyle(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              PatternInput(
                key: ValueKey(_attempt),
                size: 270,
                onCompleted: _complete,
              ),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.alertSoft),
                ),
              SwitchListTile.adaptive(
                value: _enableBiometrics,
                onChanged: (value) => setState(() => _enableBiometrics = value),
                title: const Text(AppStrings.enableBiometricUnlock),
                subtitle: const Text(AppStrings.biometricDescription),
                contentPadding: EdgeInsets.zero,
              ),
              if (!widget.requiredForActivation)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(AppStrings.cancel),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordSetupSheet extends StatefulWidget {
  const _PasswordSetupSheet({required this.requiredForActivation});

  final bool requiredForActivation;

  static Future<_CredentialSetupResult?> show(
    BuildContext context, {
    required bool requiredForActivation,
  }) => showModalBottomSheet<_CredentialSetupResult>(
    context: context,
    isScrollControlled: true,
    isDismissible: !requiredForActivation,
    enableDrag: !requiredForActivation,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _PasswordSetupSheet(requiredForActivation: requiredForActivation),
  );

  @override
  State<_PasswordSetupSheet> createState() => _PasswordSetupSheetState();
}

class _PasswordSetupSheetState extends State<_PasswordSetupSheet> {
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  String? _error;
  bool _obscure = true;
  bool _enableBiometrics = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _save() {
    final password = _passwordController.text;
    if (password.length < 4) {
      setState(() => _error = AppStrings.passwordTooShort);
      return;
    }
    if (password != _confirmationController.text) {
      setState(() => _error = AppStrings.passwordsDoNotMatch);
      return;
    }
    Navigator.of(
      context,
    ).pop(_CredentialSetupResult(password, _enableBiometrics));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.requiredForActivation,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceLow,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppGuardLogo(size: 58),
              const SizedBox(height: 16),
              Text(
                AppStrings.createTextPassword,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppStrings.textPasswordHint,
                  prefixIcon: const Icon(Icons.password_outlined),
                  suffixIcon: IconButton(
                    tooltip: _obscure
                        ? AppStrings.showPassword
                        : AppStrings.hidePassword,
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _confirmationController,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                decoration: const InputDecoration(
                  labelText: AppStrings.confirmTextPasswordHint,
                  prefixIcon: Icon(Icons.verified_user_outlined),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.alertSoft),
                ),
              ],
              SwitchListTile.adaptive(
                value: _enableBiometrics,
                onChanged: (value) => setState(() => _enableBiometrics = value),
                title: const Text(AppStrings.enableBiometricUnlock),
                subtitle: const Text(AppStrings.biometricDescription),
                contentPadding: EdgeInsets.zero,
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.lock_outline),
                  label: const Text(AppStrings.saveExitMethod),
                ),
              ),
              if (!widget.requiredForActivation)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(AppStrings.cancel),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
