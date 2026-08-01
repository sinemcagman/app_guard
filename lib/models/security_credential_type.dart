import '../localization/app_strings.dart';

enum SecurityCredentialType {
  numericPin(
    'numeric_pin',
    AppStrings.numericPin,
    AppStrings.numericPinDescription,
  ),
  pattern('pattern', AppStrings.patternLock, AppStrings.patternLockDescription),
  textPassword(
    'text_password',
    AppStrings.textPassword,
    AppStrings.textPasswordDescription,
  );

  const SecurityCredentialType(this.storageValue, this.label, this.description);

  final String storageValue;
  final String label;
  final String description;

  static SecurityCredentialType fromStorage(String? value) => values.firstWhere(
    (type) => type.storageValue == value,
    orElse: () => numericPin,
  );
}
