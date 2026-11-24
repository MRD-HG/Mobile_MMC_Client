/// Build-time configuration. Nothing here is a secret.
///
/// Override at build time if needed:
/// ```
/// flutter run --dart-define=MMC_API_BASE_URL=https://staging.example.org/api
/// flutter run --dart-define=MMC_OFFLINE_ONLY=true
/// ```
class AppConfig {
  const AppConfig._();

  static const String websiteUrl = 'https://moroccomicrosoftcommunity.com';

  /// Public read-only API used by the official MMC website.
  static const String apiBaseUrl = String.fromEnvironment(
    'MMC_API_BASE_URL',
    defaultValue: 'https://moroccomicrosoftcommunity.com/api',
  );

  /// Skip the network entirely (demos, tests on a plane...).
  static const bool offlineOnly = bool.fromEnvironment('MMC_OFFLINE_ONLY');
}
