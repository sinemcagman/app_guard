import 'package:flutter/material.dart';

import '../../localization/app_strings.dart';
import '../../services/security_service.dart';
import '../../theme/app_colors.dart';
import '../security/pin_verification_sheet.dart';
import '../security/security_setup_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({required this.securityService, super.key});

  final SecurityService securityService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;
  bool _hasPin = false;
  bool _biometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final hasPin = await widget.securityService.hasPin();
    final biometricsEnabled = await widget.securityService.biometricsEnabled();
    if (!mounted) {
      return;
    }
    setState(() {
      _hasPin = hasPin;
      _biometricsEnabled = biometricsEnabled;
      _loading = false;
    });
  }

  Future<void> _configureExitPin() async {
    if (_hasPin) {
      final verified = await PinVerificationSheet.show(
        context,
        securityService: widget.securityService,
      );
      if (!verified || !mounted) {
        return;
      }
    }

    if (!mounted) {
      return;
    }
    final setup = await SecuritySetupSheet.show(context);
    if (setup == null) {
      return;
    }
    await widget.securityService.savePin(
      setup.pin,
      enableBiometrics: setup.enableBiometrics,
    );
    await _loadSettings();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(AppStrings.exitPinSaved)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.cyan),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      children: [
        Text(
          AppStrings.securitySettings,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(
          AppStrings.securitySettingsDescription,
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        _SettingsCard(
          icon: Icons.password_outlined,
          title: AppStrings.exitPin,
          description: AppStrings.exitPinDescription,
          status: _hasPin ? AppStrings.configured : AppStrings.notConfigured,
          statusActive: _hasPin,
          actionLabel: _hasPin
              ? AppStrings.changeExitPin
              : AppStrings.setExitPin,
          onPressed: _configureExitPin,
        ),
        const SizedBox(height: 14),
        _SettingsCard(
          icon: Icons.fingerprint,
          title: AppStrings.biometricUnlock,
          description: AppStrings.biometricDescription,
          status: _biometricsEnabled ? AppStrings.enabled : AppStrings.disabled,
          statusActive: _biometricsEnabled,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cyan.withValues(alpha: .07),
            border: Border.all(color: AppColors.cyan.withValues(alpha: .25)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: AppColors.cyan),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.pinRequiredForActivation,
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.statusActive,
    this.actionLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String status;
  final bool statusActive;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.cyan),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: (statusActive ? AppColors.cyan : AppColors.outline)
                      .withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusActive
                        ? AppColors.cyan
                        : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (actionLabel != null)
                FilledButton.tonal(
                  onPressed: onPressed,
                  child: Text(actionLabel!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
