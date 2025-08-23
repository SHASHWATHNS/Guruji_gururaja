import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/screens/home_screen.dart';
import '../features/horoscope/presentation/screens/horoscope_screen.dart';
import '../features/matchmaking/presentation/screens/alp_matchmaking_screen.dart';
import '../features/panchanga/presentation/screens/panchanga_screen.dart';
import '../features/prashna/presentation/screens/prashna_screen.dart';
import '../features/matching/presentation/screens/horoscope_matching_screen.dart';
import '../features/purchase/presentation/screens/purchase_screen.dart';
import '../features/settings/presentation/screen/settings_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/about/presentation/screens/about_founder_screen.dart';
import '../features/youtube/presentation/screens/youtube_videos_screen.dart';
import '../features/shares/presentation/screens/shares_screen.dart';
import '../features/training/presentation/screens/training_video_screen.dart';
import '../features/transit/presentation/screens/transit_data_screen.dart';
import '../features/numerology/presentation/screens/numerology_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),

      // Stub routes for navigation targets
      GoRoute(path: '/horoscope', builder: (_, __) => const HoroscopeScreen()),
      GoRoute(path: '/alp-matchmaking', builder: (_, __) => const AlpMatchMakingScreen()),
      GoRoute(path: '/panchanga', builder: (_, __) => const PanchangaScreen()),
      GoRoute(path: '/prashna', builder: (_, __) => const PrashnaScreen()),
      GoRoute(path: '/horoscope-matching', builder: (_, __) => const HoroscopeMatchingScreen()),
      GoRoute(path: '/purchase', builder: (_, __) => const PurchaseScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/about-founder', builder: (_, __) => const AboutFounderScreen()),
      GoRoute(path: '/youtube', builder: (_, __) => const YoutubeVideosScreen()),
      GoRoute(path: '/shares', builder: (_, __) => const SharesScreen()),
      GoRoute(path: '/training', builder: (_, __) => const TrainingVideoScreen()),
      GoRoute(path: '/transit', builder: (_, __) => const TransitDataScreen()),
      GoRoute(path: '/numerology', builder: (_, __) => const NumerologyScreen()),
    ],
  );
});

