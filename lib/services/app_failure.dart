import '../localization/app_strings.dart';

class AppFailure implements Exception {
  const AppFailure(this.message);
  final String message;

  factory AppFailure.fromCode(String? code) => switch (code) {
    'APP_NOT_FOUND' => const AppFailure(AppStrings.appNotFound),
    'PINNING_NOT_PERMITTED' => const AppFailure(AppStrings.pinningNotPermitted),
    'LOCK_TASK_FAILED' => const AppFailure(AppStrings.pinnedModeFailed),
    'UNSUPPORTED_PLATFORM' => const AppFailure(AppStrings.unsupportedPlatform),
    _ => const AppFailure(AppStrings.unexpectedError),
  };
}
