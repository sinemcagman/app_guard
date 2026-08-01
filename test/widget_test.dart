import 'package:app_guard/app.dart';
import 'package:app_guard/localization/app_strings.dart';
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
}
