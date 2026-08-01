import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/dashboard/dashboard_screen.dart';
import 'features/lock/lock_screen.dart';
import 'localization/app_strings.dart';
import 'services/platform_app_service.dart';
import 'services/security_service.dart';
import 'theme/app_theme.dart';

class AppGuardApp extends StatefulWidget {
  const AppGuardApp({super.key});

  @override
  State<AppGuardApp> createState() => _AppGuardAppState();
}

class _AppGuardAppState extends State<AppGuardApp> {
  final _platformService = PlatformAppService.instance;
  final _securityService = SecurityService();
  StreamSubscription<PlatformEvent>? _eventSubscription;
  bool _showLockScreen = false;

  @override
  void initState() {
    super.initState();
    _eventSubscription = _platformService.events.listen((event) {
      if (event == PlatformEvent.unauthorizedExit && mounted) {
        setState(() => _showLockScreen = true);
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.dark,
      home: Stack(
        children: [
          DashboardScreen(
            platformService: _platformService,
            securityService: _securityService,
          ),
          if (_showLockScreen)
            Positioned.fill(
              child: LockScreen(
                securityService: _securityService,
                onUnlocked: () async {
                  await _platformService.stopPinnedMode();
                  if (mounted) setState(() => _showLockScreen = false);
                },
              ),
            ),
        ],
      ),
    );
  }
}
