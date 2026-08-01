import 'package:app_guard/app.dart';
import 'package:app_guard/features/dashboard/dashboard_screen.dart';
import 'package:app_guard/features/lock/lock_screen.dart';
import 'package:app_guard/features/settings/settings_screen.dart';
import 'package:app_guard/localization/app_strings.dart';
import 'package:app_guard/models/installed_app.dart';
import 'package:app_guard/models/security_credential_type.dart';
import 'package:app_guard/services/platform_app_service.dart';
import 'package:app_guard/services/security_service.dart';
import 'package:app_guard/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ana ekran tasarıma uygun Türkçe içerikle açılır', (
    tester,
  ) async {
    await tester.pumpWidget(const AppGuardApp());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.searchApps), findsOneWidget);
    expect(find.text(AppStrings.allApps), findsOneWidget);
    expect(find.text(AppStrings.launchPinnedMode), findsOneWidget);
    expect(find.text(AppStrings.apps), findsOneWidget);
  });

  testWidgets('uygulama araması sonuç listesini filtreler', (tester) async {
    await tester.pumpWidget(const AppGuardApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), AppStrings.phone);
    await tester.pump();

    expect(find.text(AppStrings.phone), findsWidgets);
    expect(find.text('WhatsApp'), findsNothing);
  });

  testWidgets('görünen arayüzde İngilizce sistem metni bulunmaz', (
    tester,
  ) async {
    await tester.pumpWidget(const AppGuardApp());
    await tester.pumpAndSettle();

    const forbiddenTexts = [
      'Search apps',
      'All Apps',
      'Launch in Pinned Mode',
      'Settings',
      'History',
      'Secure',
      'No applications found',
    ];

    for (final text in forbiddenTexts) {
      expect(
        find.text(text),
        findsNothing,
        reason: 'İngilizce metin bulundu: $text',
      );
    }
  });

  testWidgets('etkinleştirmeden sonra zorunlu çıkış PIN\'i kurulumu açılır', (
    tester,
  ) async {
    final platformService = _FakePlatformAppGateway();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: DashboardScreen(
          platformService: platformService,
          securityService: SecurityService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch).first);
    await tester.pump();
    await tester.tap(find.text(AppStrings.launchPinnedMode));
    await tester.pumpAndSettle();

    expect(platformService.startCount, 1);
    expect(find.text(AppStrings.chooseExitMethod), findsOneWidget);
    expect(find.text(AppStrings.numericPin), findsWidgets);
    expect(find.text(AppStrings.patternLock), findsWidgets);
    expect(find.text(AppStrings.textPassword), findsWidgets);
    expect(find.text(AppStrings.cancel), findsNothing);
  });

  test('Ana PIN düz metin tutulmaz ve doğru PIN doğrulanır', () async {
    final securityService = SecurityService();
    await securityService.savePin('1234', enableBiometrics: false);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('master_pin_hash'), isNot('1234'));
    expect(await securityService.verifyPin('1234'), isTrue);
    expect(await securityService.verifyPin('4321'), isFalse);
  });

  test('desen ve metin parola türleri saklanıp doğrulanır', () async {
    final securityService = SecurityService();
    await securityService.saveCredential(
      '0-1-4-7',
      type: SecurityCredentialType.pattern,
      enableBiometrics: false,
    );
    expect(
      await securityService.credentialType(),
      SecurityCredentialType.pattern,
    );
    expect(await securityService.verifyCredential('0-1-4-7'), isTrue);

    await securityService.saveCredential(
      'güvenli parola',
      type: SecurityCredentialType.textPassword,
      enableBiometrics: false,
    );
    expect(
      await securityService.credentialType(),
      SecurityCredentialType.textPassword,
    );
    expect(await securityService.verifyCredential('güvenli parola'), isTrue);
  });

  testWidgets('kilit ekranı doğru Ana PIN ile açılır', (tester) async {
    final securityService = SecurityService();
    await securityService.savePin('1234', enableBiometrics: false);
    var unlocked = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: LockScreen(
          securityService: securityService,
          onUnlocked: () async => unlocked = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final digit in ['1', '2', '3', '4']) {
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 100));

    expect(unlocked, isTrue);
  });

  testWidgets('Ayarlar sekmesi oturum kapalıyken üç çıkış yöntemini seçtirir', (
    tester,
  ) async {
    await tester.pumpWidget(const AppGuardApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(NavigationDestination, AppStrings.settings),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.securitySettings), findsOneWidget);
    expect(find.text(AppStrings.numericPin), findsOneWidget);
    expect(find.text(AppStrings.patternLock), findsOneWidget);
    expect(find.text(AppStrings.textPassword), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, AppStrings.select).first,
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('Ayarlar kısmından sayısal PIN kurulumu açılır', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: SettingsScreen(securityService: SecurityService()),
      ),
    );
    await tester.pumpAndSettle();

    final numericSelect = find
        .widgetWithText(FilledButton, AppStrings.select)
        .first;
    await tester.ensureVisible(numericSelect);
    await tester.tap(numericSelect);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.setSecurityMethod), findsOneWidget);
  });

  testWidgets('Ayarlar kısmından desen kurulumu açılır', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: SettingsScreen(securityService: SecurityService()),
      ),
    );
    await tester.pumpAndSettle();

    final patternSelect = find
        .widgetWithText(FilledButton, AppStrings.select)
        .at(1);
    await tester.ensureVisible(patternSelect);
    await tester.tap(patternSelect);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.createPattern), findsOneWidget);
    expect(find.text(AppStrings.drawPattern), findsOneWidget);
  });

  testWidgets('Ayarlar kısmından metin parola kurulumu açılır', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: SettingsScreen(securityService: SecurityService()),
      ),
    );
    await tester.pumpAndSettle();

    final passwordSelect = find
        .widgetWithText(FilledButton, AppStrings.select)
        .at(2);
    await tester.ensureVisible(passwordSelect);
    await tester.tap(passwordSelect);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.createTextPassword), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('ayarlı çıkış yöntemi değiştirilmeden önce doğrulanır', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await SecurityService().savePin('1234', enableBiometrics: false);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: SettingsScreen(securityService: SecurityService()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(AppStrings.change));
    await tester.tap(find.text(AppStrings.change));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.verifyExitMethod), findsOneWidget);
    expect(find.text(AppStrings.verifyExitMethodDescription), findsOneWidget);
  });
}

class _FakePlatformAppGateway implements PlatformAppGateway {
  int startCount = 0;

  @override
  Future<List<InstalledApp>> getLaunchableApps() async => demoApplications;

  @override
  Future<void> launchApp(String packageName) async {}

  @override
  Future<void> startPinnedMode() async {
    startCount++;
  }

  @override
  Future<void> stopPinnedMode() async {}
}
