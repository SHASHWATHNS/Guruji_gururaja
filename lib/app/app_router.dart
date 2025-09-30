// lib/core/router/router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// NEW

// Auth / Splash
import '../../features/auth/auth/presentation/screens/login_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

// App screens
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/matchmaking/presentation/screens/matchmaking_screen.dart';
import '../../features/panchanga/presentation/screens/panchanga_screen.dart';
import '../../features/panchanga/presentation/screens/panchanga_day_screen.dart';     // ← NEW
import '../../features/panchanga/presentation/screens/panchanga_month_screen.dart';   // ← NEW
import '../../features/purchase/presentation/screens/purchase_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/about/presentation/screens/about_founder_screen.dart';
import '../../features/tarot/presentation/models/tarot_card_lite.dart';
import '../../features/tarot/presentation/screens/tarot_quick_detail_screen.dart';
import '../../features/transit/presentation/screens/transit_screen.dart';
import '../../features/youtube/presentation/screens/youtube_videos_screen.dart';
import '../../features/shares/presentation/screens/shares_screen.dart';
import '../../features/training/presentation/screens/training_video_screen.dart';
import '../features/numerology/presentation/screens/numerology_screen.dart';
import '../features/prashna/presentation/screens/prashna_screen.dart';

// If you keep providers here, keep it as Provider<GoRouter>
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/splash',
    routes: [
      // --- Auth flow ---
      GoRoute(path: '/splash', name: 'splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login',  name: 'login',  builder: (_, __) => const LoginScreen()),

      // --- App ---
      GoRoute(path: '/', name: 'home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/alp-matchmaking', name: 'alp-matchmaking', builder: (_, __) => const MatchMakingScreen()),

      // horoscope screens


      // Panchanga hub + subroutes
      GoRoute(path: '/panchanga', name: 'panchanga', builder: (_, __) => const PanchangaScreen()),
      GoRoute(path: '/panchanga/day', name: 'panchanga-day', builder: (_, __) => const PanchangaDayScreen()),
      GoRoute(path: '/panchanga/month', name: 'panchanga-month', builder: (_, __) => const PanchangaMonthScreen()),

      GoRoute(path: '/prashna', name: 'prashna', builder: (_, __) => const JamakkolHome()),
      GoRoute(path: '/purchase', name: 'purchase', builder: (_, __) => const PurchaseScreen()),
      GoRoute(path: '/settings', name: 'settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/about-founder', name: 'about-founder', builder: (_, __) => const AboutFounderScreen()),
      GoRoute(path: '/youtube', name: 'youtube', builder: (_, __) => const YoutubeVideosScreen()),
      GoRoute(path: '/shares', name: 'shares', builder: (_, __) => const SharesScreen()),
      GoRoute(path: '/training', name: 'training', builder: (_, __) => const TrainingVideoScreen()),
      GoRoute(path: '/transit', name: 'transit', builder: (_, __) => const TransitScreen()),
      GoRoute(path: '/numerology', name: 'numerology', builder: (_, __) => const NumerologyScreen()),
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
