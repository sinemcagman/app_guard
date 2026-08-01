import 'package:flutter/material.dart';

import '../../features/lock/lock_screen.dart';
import '../../localization/app_strings.dart';
import '../../models/security_credential_type.dart';
import '../../services/security_service.dart';
import '../../theme/app_colors.dart';
import '../security/credential_setup_flow.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({required this.securityService, super.key});

  final SecurityService securityService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;
  bool _hasCredential = false;
  bool _biometricsEnabled = false;
  SecurityCredentialType _credentialType = SecurityCredentialType.numericPin;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final hasCredential = await widget.securityService.hasCredential();
    final credentialType = await widget.securityService.credentialType();
    final biometricsEnabled = await widget.securityService.biometricsEnabled();
    if (!mounted) return;
    setState(() {
      _hasCredential = hasCredential;
      _credentialType = credentialType;
      _biometricsEnabled = biometricsEnabled;
      _loading = false;
    });
  }

  Future<bool> _verifyExistingCredential() async {
    var verified = false;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.surface,
      pageBuilder: (dialogContext, _, _) => LockScreen(
        securityService: widget.securityService,
        title: AppStrings.verifyExitMethod,
        description: AppStrings.verifyExitMethodDescription,
        onUnlocked: () async {
          verified = true;
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        },
      ),
    );
    return verified;
  }

  Future<void> _configure(SecurityCredentialType type) async {
    if (_hasCredential && !await _verifyExistingCredential()) {
      return;
    }
    if (!mounted) return;
    final saved = await CredentialSetupFlow.show(
      context,
      securityService: widget.securityService,
      requiredForActivation: false,
      preferredType: type,
    );
    if (!saved) return;
    await _loadSettings();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(AppStrings.exitMethodSaved)));
  }

  IconData _icon(SecurityCredentialType type) => switch (type) {
    SecurityCredentialType.numericPin => Icons.pin_outlined,
    SecurityCredentialType.pattern => Icons.gesture,
    SecurityCredentialType.textPassword => Icons.password_outlined,
  };

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
          AppStrings.chooseExitMethodDescription,
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        if (_hasCredential)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: .08),
              border: Border.all(color: AppColors.cyan.withValues(alpha: .3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.cyan),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.currentExitMethod,
                        style: TextStyle(color: AppColors.onSurfaceVariant),
                      ),
                      Text(
                        _credentialType.label,
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        for (final type in SecurityCredentialType.values) ...[
          _MethodCard(
            icon: _icon(type),
            type: type,
            selected: _hasCredential && type == _credentialType,
            onPressed: () => _configure(type),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.fingerprint, color: AppColors.cyan, size: 30),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.biometricUnlock,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      AppStrings.biometricDescription,
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Text(
                _biometricsEnabled ? AppStrings.enabled : AppStrings.disabled,
                style: TextStyle(
                  color: _biometricsEnabled
                      ? AppColors.cyan
                      : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.icon,
    required this.type,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final SecurityCredentialType type;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border.all(
          color: selected ? AppColors.cyan : AppColors.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
                      type.label,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      type.description,
                      style: const TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: AppColors.cyan),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: onPressed,
              child: Text(selected ? AppStrings.change : AppStrings.select),
            ),
          ),
        ],
      ),
    );
  }
}
