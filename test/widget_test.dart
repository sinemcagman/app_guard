import 'package:app_guard/app.dart';
import 'package:app_guard/features/lock/lock_screen.dart';
import 'package:app_guard/localization/app_strings.dart';
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

  testWidgets('uygulama seçilince güvenlik kurulumu açılır', (tester) async {
    await tester.pumpWidget(const AppGuardApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch).first);
    await tester.pump();
    await tester.tap(find.text(AppStrings.launchPinnedMode));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.setSecurityMethod), findsOneWidget);
    expect(find.text(AppStrings.enableBiometricUnlock), findsOneWidget);
    expect(find.text(AppStrings.cancelAndReturn), findsOneWidget);
  });

  test('Ana PIN düz metin tutulmaz ve doğru PIN doğrulanır', () async {
    final securityService = SecurityService();
    await securityService.savePin('1234', enableBiometrics: false);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('master_pin_hash'), isNot('1234'));
    expect(await securityService.verifyPin('1234'), isTrue);
    expect(await securityService.verifyPin('4321'), isFalse);
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

    for (final digit in ['1', '2', '3', '4']) {
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 100));

    expect(unlocked, isTrue);
  });

  testWidgets('Ayarlar sekmesi çıkış PIN\'i belirleme akışını açar', (
    tester,
  ) async {
    await tester.pumpWidget(const AppGuardApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(NavigationDestination, AppStrings.settings),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.securitySettings), findsOneWidget);
    expect(find.text(AppStrings.notConfigured), findsOneWidget);
    await tester.tap(find.text(AppStrings.setExitPin));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.setSecurityMethod), findsOneWidget);
  });

  testWidgets('ayarlı çıkış PIN\'i değiştirilmeden önce doğrulanır', (
    tester,
  ) async {
    await SecurityService().savePin('1234', enableBiometrics: false);
    await tester.pumpWidget(const AppGuardApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(NavigationDestination, AppStrings.settings),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.changeExitPin));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.currentExitPin), findsOneWidget);
    expect(find.text(AppStrings.currentExitPinDescription), findsOneWidget);
  });
}
