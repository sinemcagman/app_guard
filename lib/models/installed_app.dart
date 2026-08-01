import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../localization/app_strings.dart';

enum AppCategory {
  all(AppStrings.allApps),
  social(AppStrings.social),
  system(AppStrings.system),
  media(AppStrings.media),
  utility(AppStrings.utility),
  other(AppStrings.other);

  const AppCategory(this.label);
  final String label;

  static AppCategory fromPlatform(String? value) => switch (value) {
    'social' => social,
    'system' => system,
    'media' => media,
    'utility' => utility,
    _ => other,
  };
}

class InstalledApp {
  const InstalledApp({
    required this.name,
    required this.packageName,
    required this.category,
    required this.icon,
    required this.iconColor,
    this.iconBytes,
  });

  final String name;
  final String packageName;
  final AppCategory category;
  final IconData icon;
  final Color iconColor;
  final Uint8List? iconBytes;

  factory InstalledApp.fromPlatform(Map<Object?, Object?> data) {
    final category = AppCategory.fromPlatform(data['category'] as String?);
    final encodedIcon = data['icon'] as String?;
    return InstalledApp(
      name: data['name'] as String? ?? AppStrings.other,
      packageName: data['packageName'] as String? ?? '',
      category: category,
      icon: iconFor(category),
      iconColor: colorFor(category),
      iconBytes: encodedIcon == null || encodedIcon.isEmpty
          ? null
          : base64Decode(encodedIcon),
    );
  }

  static IconData iconFor(AppCategory category) => switch (category) {
    AppCategory.social => Icons.forum_outlined,
    AppCategory.system => Icons.settings_outlined,
    AppCategory.media => Icons.perm_media_outlined,
    AppCategory.utility => Icons.build_outlined,
    _ => Icons.apps_outlined,
  };

  static Color colorFor(AppCategory category) => switch (category) {
    AppCategory.social => const Color(0xFF34E477),
    AppCategory.media => const Color(0xFFFF3845),
    AppCategory.system => const Color(0xFF9BA8AA),
    AppCategory.utility => const Color(0xFFFFC857),
    _ => const Color(0xFF00DBE9),
  };
}

const demoApplications = [
  InstalledApp(
    name: AppStrings.phone,
    packageName: 'com.android.dialer',
    category: AppCategory.system,
    icon: Icons.call_outlined,
    iconColor: Color(0xFF00DBE9),
  ),
  InstalledApp(
    name: 'WhatsApp',
    packageName: 'com.whatsapp',
    category: AppCategory.social,
    icon: Icons.chat_bubble_outline,
    iconColor: Color(0xFF34E477),
  ),
  InstalledApp(
    name: AppStrings.photos,
    packageName: 'com.google.android.apps.photos',
    category: AppCategory.media,
    icon: Icons.photo_library_outlined,
    iconColor: Color(0xFF00DBE9),
  ),
  InstalledApp(
    name: 'YouTube',
    packageName: 'com.google.android.youtube',
    category: AppCategory.media,
    icon: Icons.play_circle_outline,
    iconColor: Color(0xFFFF2430),
  ),
  InstalledApp(
    name: AppStrings.settings,
    packageName: 'com.android.settings',
    category: AppCategory.system,
    icon: Icons.settings_outlined,
    iconColor: Color(0xFF9BA8AA),
  ),
];
