// lib/core/config/app_config.dart
import 'package:flutter/foundation.dart';

/// Global config shared across features.
class AppConfig {
  const AppConfig._();

  /// Base for all json.freeastrologyapi.com endpoints.
  static const String astroBaseUrl = 'https://json.freeastrologyapi.com';

  /// Optional dev fallback for local testing ONLY.
  /// You can fill this while developing and keep it empty when you commit.
  static const String _devFallbackKey = '';

  /// Unified accessor:
  /// - Uses `--dart-define=ASTRO_API_KEY=...` when provided
  /// - In release builds, the env var is REQUIRED (throws if missing)
  /// - In debug/profile, falls back to `_devFallbackKey`
  static String get astroApiKey {
    const envKey = String.fromEnvironment('ASTRO_API_KEY');
    if (envKey.isNotEmpty) return envKey;

    if (kReleaseMode) {
      throw StateError(
        'ASTRO_API_KEY is missing. For release/prod builds, pass it via:\n'
            '  flutter build apk --dart-define=ASTRO_API_KEY=YOUR_REAL_KEY\n'
            '  flutter build ios --dart-define=ASTRO_API_KEY=YOUR_REAL_KEY',
      );
    }

    if (_devFallbackKey.isEmpty) {
      debugPrint(
        '[AppConfig] Warning: No ASTRO_API_KEY provided; using empty dev key. '
            'Set `_devFallbackKey` for local testing or run with --dart-define.',
      );
    }
    return _devFallbackKey;
  }

  /// Common request config sent to all Panchanga endpoints.
  static Map<String, dynamic> defaultConfig() => const {
    'observation_point': 'topocentric',
    'ayanamsha': 'lahiri',
  };
}
// flutter run --dart-define=ASTRO_BASE_URL=https://json.freeastrologyapi.com --dart-define=ASTRO_API_KEY=Gn8Fe7i5YiOy87nmWxU19aycrUNs3Ug42u1dVC8f
