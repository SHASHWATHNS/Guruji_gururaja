import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// NEW
import '../features/horoscope/presentation/screens/horoscope_form_screen.dart';

import '../features/auth/auth/presentation/screens/login_screen.dart';
import '../features/numerology/presentation/screens/numerology_form_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

// Existing (unchanged)...
import '../features/home/presentation/screens/home_screen.dart';
import '../features/matchmaking/presentation/screens/matchmaking_screen.dart';
import '../features/panchanga/presentation/screens/panchanga_screen.dart';
import '../features/prashna/presentation/screens/prashna_screen.dart';
import '../features/purchase/presentation/screens/purchase_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/about/presentation/screens/about_founder_screen.dart';
import '../features/tarot/presentation/models/tarot_card_lite.dart';
import '../features/tarot/presentation/screens/tarot_quick_detail_screen.dart';
import '../features/tarot/presentation/screens/tarot_quick_grid_screen.dart';
import '../features/transit/presentation/screens/transit_screen.dart';
import '../features/youtube/presentation/screens/youtube_videos_screen.dart';
import '../features/shares/presentation/screens/shares_screen.dart';
import '../features/training/presentation/screens/training_video_screen.dart';
import '../features/numerology/presentation/screens/numerology_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true, // helpful while switching UI
    initialLocation: '/splash',
    routes: [
      // --- Auth flow ---
      GoRoute(path: '/splash', name: 'splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login',  name: 'login',  builder: (_, __) => const LoginScreen()), // <— changed

      // --- App ---
      GoRoute(path: '/', name: 'home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/horoscope', name: 'horoscope', builder: (_, __) => const HoroscopeFormScreen()),
      GoRoute(path: '/alp-matchmaking', name: 'alp-matchmaking', builder: (_, __) => const MatchMakingScreen()),
      GoRoute(path: '/panchanga', name: 'panchanga', builder: (_, __) => const PanchangaScreen()),
      GoRoute(path: '/prashna', name: 'prashna', builder: (_, __) => const PrashnaScreen()),
      GoRoute(path: '/purchase', name: 'purchase', builder: (_, __) => const PurchaseScreen()),
      GoRoute(path: '/settings', name: 'settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/about-founder', name: 'about-founder', builder: (_, __) => const AboutFounderScreen()),
      GoRoute(path: '/youtube', name: 'youtube', builder: (_, __) => const YoutubeVideosScreen()),
      GoRoute(path: '/shares', name: 'shares', builder: (_, __) => const SharesScreen()),
      GoRoute(path: '/training', name: 'training', builder: (_, __) => const TrainingVideoScreen()),
      GoRoute(path: '/transit', name: 'transit', builder: (_, __) => const TransitScreen()),
      GoRoute(path: '/numerology', name: 'numerology', builder: (_, __) => const NumerologyScreen()),
      GoRoute(path: '/tarot', name: 'tarot-grid', builder: (_, __) => const TarotQuickGridScreen()),
      GoRoute(
        path: '/numerology-form',
        builder: (_, __) => const NumerologyFormScreen(),
      ),
      GoRoute(
        path: '/tarot/detail',
        name: 'tarot-detail',
        builder: (context, state) {
          final card = state.extra as TarotCardLite;
          return TarotQuickDetailScreen(card: card);
        },
      ),
    ],
  );
});
