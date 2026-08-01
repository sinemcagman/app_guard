import 'package:flutter/material.dart';

import '../../localization/app_strings.dart';
import '../../models/security_credential_type.dart';
import '../../services/app_failure.dart';
import '../../services/security_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_guard_logo.dart';
import '../../widgets/pattern_input.dart';
import '../../widgets/pin_keypad.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({
    required this.securityService,
    required this.onUnlocked,
    super.key,
    this.title,
    this.description,
    this.showBiometrics = true,
  });

  final SecurityService securityService;
  final Future<void> Function() onUnlocked;
  final String? title;
  final String? description;
  final bool showBiometrics;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _passwordController = TextEditingController();
  SecurityCredentialType? _type;
  String _pin = '';
  String? _error;
  bool _checking = false;
  bool _obscurePassword = true;
  int _patternAttempt = 0;

  @override
  void initState() {
    super.initState();
    _loadType();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadType() async {
    final type = await widget.securityService.credentialType();
    if (mounted) {
      setState(() => _type = type);
    }
  }

  void _addDigit(String digit) {
    if (_pin.length == 4 || _checking) return;
    setState(() {
      _error = null;
      _pin += digit;
    });
    if (_pin.length == 4) {
      _verify(_pin);
    }
  }

  void _backspace() {
    if (_pin.isEmpty || _checking) return;
    setState(() {
      _error = null;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  String _failureMessage() => switch (_type) {
    SecurityCredentialType.pattern => AppStrings.incorrectPattern,
    SecurityCredentialType.textPassword => AppStrings.incorrectPassword,
    _ => AppStrings.incorrectPin,
  };

  Future<void> _verify(String credential) async {
    if (_checking || credential.isEmpty) {
      return;
    }
    setState(() {
      _checking = true;
      _error = null;
    });
    final valid = await widget.securityService.verifyCredential(credential);
    if (!mounted) return;
    if (valid) {
      await widget.onUnlocked();
    } else {
      setState(() {
        _checking = false;
        _pin = '';
        _passwordController.clear();
        _patternAttempt++;
        _error = _failureMessage();
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

  Widget _credentialInput(bool compact) => switch (_type) {
    SecurityCredentialType.pattern => PatternInput(
      key: ValueKey(_patternAttempt),
      size: compact ? 235 : 270,
      enabled: !_checking,
      onCompleted: (pattern) => _verify(pattern.join('-')),
    ),
    SecurityCredentialType.textPassword => ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Column(
        children: [
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            enabled: !_checking,
            autofocus: true,
            onSubmitted: _verify,
            decoration: InputDecoration(
              labelText: AppStrings.enterTextPassword,
              prefixIcon: const Icon(Icons.password_outlined),
              suffixIcon: IconButton(
                tooltip: _obscurePassword
                    ? AppStrings.showPassword
                    : AppStrings.hidePassword,
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _checking
                  ? null
                  : () => _verify(_passwordController.text),
              icon: const Icon(Icons.verified_user_outlined),
              label: const Text(AppStrings.verify),
            ),
          ),
        ],
      ),
    ),
    SecurityCredentialType.numericPin => PinKeypad(
      pinLength: _pin.length,
      onDigit: _addDigit,
      onBackspace: _backspace,
      compact: compact,
      showLetters: true,
    ),
    null => const CircularProgressIndicator(color: AppColors.cyan),
  };

  @override
  Widget build(BuildContext context) {
    final verificationOnly = widget.title != null;
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
                        AppGuardLogo(
                          size: compact ? 74 : 92,
                          alert: !verificationOnly,
                        ),
                        SizedBox(height: compact ? 16 : 24),
                        Text(
                          widget.title ?? AppStrings.unauthorizedExit,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: compact ? 25 : 29,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.description ??
                              AppStrings.authenticationRequired,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        if (_type != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _type!.label,
                            style: const TextStyle(
                              color: AppColors.cyan,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: compact ? 20 : 30,
                      ),
                      child: _credentialInput(compact),
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
                        if (widget.showBiometrics)
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
