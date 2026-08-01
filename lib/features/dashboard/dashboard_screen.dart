import 'package:flutter/material.dart';

import '../../localization/app_strings.dart';
import '../../models/installed_app.dart';
import '../../services/app_failure.dart';
import '../../services/platform_app_service.dart';
import '../../services/security_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_guard_logo.dart';
import '../lock/lock_screen.dart';
import '../security/security_setup_sheet.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.platformService,
    required this.securityService,
    super.key,
  });

  final PlatformAppGateway platformService;
  final SecurityService securityService;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  List<InstalledApp> _applications = const [];
  final Set<String> _selectedPackages = {};
  AppCategory _category = AppCategory.all;
  bool _loading = true;
  bool _pinnedMode = false;
  int _navigationIndex = 0;
  int _settingsRevision = 0;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApplications() async {
    setState(() => _loading = true);
    try {
      final applications = await widget.platformService.getLaunchableApps();
      if (!mounted) {
        return;
      }
      setState(() {
        _applications = applications;
        _loading = false;
      });
    } on AppFailure catch (failure) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage(failure.message);
    }
  }

  List<InstalledApp> get _filteredApplications {
    final query = _searchController.text.trim().toLowerCase();
    return _applications
        .where((application) {
          final matchesCategory =
              _category == AppCategory.all || application.category == _category;
          final matchesQuery =
              query.isEmpty || application.name.toLowerCase().contains(query);
          return matchesCategory && matchesQuery;
        })
        .toList(growable: false);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _togglePinnedMode() async {
    if (_pinnedMode) {
      await _requestStopPinnedMode();
      return;
    }
    if (_selectedPackages.isEmpty) {
      _showMessage(AppStrings.chooseAtLeastOneApp);
      return;
    }

    try {
      final needsExitPin = !await widget.securityService.hasPin();
      await widget.platformService.startPinnedMode();
      if (!mounted) return;
      setState(() {
        _pinnedMode = true;
        if (needsExitPin) {
          _navigationIndex = 3;
        }
      });
      if (needsExitPin) {
        _showMessage(AppStrings.activateThenSetPin);
        final setup = await SecuritySetupSheet.show(
          context,
          requiredForActivation: true,
        );
        if (setup == null) {
          return;
        }
        await widget.securityService.savePin(
          setup.pin,
          enableBiometrics: setup.enableBiometrics,
        );
        if (mounted) {
          setState(() => _settingsRevision++);
        }
      }
      if (!mounted) return;
      _showMessage(AppStrings.pinnedModeActive);
    } on AppFailure catch (failure) {
      if (mounted) _showMessage(failure.message);
    }
  }

  Future<void> _requestStopPinnedMode() async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.surface,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, _, _) => LockScreen(
        securityService: widget.securityService,
        onUnlocked: () async {
          await widget.platformService.stopPinnedMode();
          if (mounted) {
            setState(() => _pinnedMode = false);
          }
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        },
      ),
    );
  }

  Future<void> _openApp(InstalledApp application) async {
    if (!_pinnedMode || !_selectedPackages.contains(application.packageName)) {
      return;
    }
    try {
      await widget.platformService.launchApp(application.packageName);
    } on AppFailure catch (failure) {
      if (mounted) _showMessage(failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredApplications = _filteredApplications;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: AppColors.surface.withValues(alpha: .96),
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
        titleSpacing: 20,
        title: const Row(
          children: [
            AppGuardLogo(size: 38),
            SizedBox(width: 12),
            Text(
              AppStrings.appName,
              style: TextStyle(
                color: AppColors.cyan,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20, top: 18, bottom: 18),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: .12),
              border: Border.all(color: AppColors.cyan.withValues(alpha: .55)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Icon(
                  _pinnedMode ? Icons.lock : Icons.shield_outlined,
                  size: 16,
                  color: AppColors.cyan,
                ),
                const SizedBox(width: 7),
                Text(
                  _pinnedMode ? AppStrings.active : AppStrings.secure,
                  style: const TextStyle(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _navigationIndex == 3
          ? SettingsScreen(
              key: ValueKey(_settingsRevision),
              securityService: widget.securityService,
              pinnedModeActive: _pinnedMode,
            )
          : RefreshIndicator(
              onRefresh: _loadApplications,
              color: AppColors.cyan,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
                              hintText: AppStrings.searchApps,
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 42,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: AppCategory.values.length - 1,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final category = AppCategory.values[index];
                                final selected = category == _category;
                                return ChoiceChip(
                                  selected: selected,
                                  label: Text(category.label),
                                  onSelected: (_) =>
                                      setState(() => _category = category),
                                  selectedColor: AppColors.cyanBright,
                                  backgroundColor: AppColors.surfaceHigh,
                                  side: BorderSide.none,
                                  labelStyle: TextStyle(
                                    color: selected
                                        ? AppColors.cyanDark
                                        : AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              },
                            ),
                          ),
                          if (_selectedPackages.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              AppStrings.selectedAppCount(
                                _selectedPackages.length,
                              ),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.cyan),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (_loading)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Semantics(
                          label: AppStrings.loadingApplications,
                          child: const CircularProgressIndicator(
                            color: AppColors.cyan,
                          ),
                        ),
                      ),
                    )
                  else if (filteredApplications.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(
                        message: _applications.isEmpty
                            ? AppStrings.noApplications
                            : AppStrings.noMatchingApplications,
                        onReload: _loadApplications,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
                      sliver: SliverList.separated(
                        itemCount: filteredApplications.length + 1,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == filteredApplications.length) {
                            return const _VaultCard();
                          }
                          final application = filteredApplications[index];
                          final selected = _selectedPackages.contains(
                            application.packageName,
                          );
                          return _ApplicationCard(
                            application: application,
                            selected: selected,
                            enabled: !_pinnedMode || selected,
                            onTap: () => _openApp(application),
                            onChanged: _pinnedMode
                                ? null
                                : (value) {
                                    setState(() {
                                      if (value) {
                                        _selectedPackages.add(
                                          application.packageName,
                                        );
                                      } else {
                                        _selectedPackages.remove(
                                          application.packageName,
                                        );
                                      }
                                    });
                                  },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _navigationIndex == 0
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton.icon(
                  onPressed: _togglePinnedMode,
                  icon: Icon(
                    _pinnedMode ? Icons.lock_open : Icons.shield_outlined,
                  ),
                  label: Text(
                    _pinnedMode
                        ? AppStrings.stopPinnedMode
                        : AppStrings.launchPinnedMode,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _pinnedMode
                        ? AppColors.alertDark
                        : AppColors.cyanBright,
                    foregroundColor: _pinnedMode
                        ? AppColors.onSurface
                        : AppColors.cyanDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navigationIndex,
        onDestinationSelected: (index) {
          if (index == 0 || index == 3) {
            setState(() => _navigationIndex = index);
          } else {
            _showMessage(AppStrings.comingSoon);
          }
        },
        backgroundColor: AppColors.surfaceLowest,
        indicatorColor: AppColors.cyan.withValues(alpha: .22),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view, color: AppColors.cyan),
            label: AppStrings.apps,
          ),
          NavigationDestination(
            icon: Icon(Icons.lock_outline),
            label: AppStrings.vault,
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: AppStrings.history,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: AppStrings.settings,
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.application,
    required this.selected,
    required this.enabled,
    required this.onTap,
    required this.onChanged,
  });

  final InstalledApp application;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.appLockSemantics(application.name, selected),
      child: Material(
        color: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected
                ? AppColors.cyan.withValues(alpha: .42)
                : AppColors.outlineVariant,
          ),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: application.iconColor.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: application.iconBytes == null
                      ? Icon(
                          application.icon,
                          color: application.iconColor,
                          size: 29,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            application.iconBytes!,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                            errorBuilder: (_, _, _) => Icon(
                              application.icon,
                              color: application.iconColor,
                              size: 29,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHighest,
                          border: Border.all(color: AppColors.outlineVariant),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          application.category.label,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: selected,
                  onChanged: onChanged,
                  activeTrackColor: AppColors.alertDark,
                  activeThumbColor: Colors.white,
                  inactiveTrackColor: AppColors.surfaceHighest,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VaultCard extends StatelessWidget {
  const _VaultCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceContainer,
            AppColors.cyan.withValues(alpha: .06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cyan.withValues(alpha: .35)),
      ),
      child: const Row(
        children: [
          AppGuardLogo(size: 52),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.privateVault,
                  style: TextStyle(
                    color: AppColors.cyan,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  AppStrings.secureStorage,
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.onReload});
  final String message;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            TextButton.icon(
              onPressed: onReload,
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.reload),
            ),
          ],
        ),
      ),
    );
  }
}
