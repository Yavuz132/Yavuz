import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/matches/screens/matches_screen.dart';
import '../../features/matches/screens/match_detail_screen.dart';
import '../../features/reports/screens/premium_report_screen.dart';
import '../../features/reports/screens/unlocked_reports_screen.dart';
import '../../features/credits/screens/credits_screen.dart';
import '../../features/subscriptions/screens/subscription_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/matches', builder: (_, __) => const MatchesScreen()),
    GoRoute(path: '/match/:id', builder: (_, state) => MatchDetailScreen(matchId: int.parse(state.pathParameters['id']!))),
    GoRoute(path: '/report/:matchId', builder: (_, state) => PremiumReportScreen(matchId: int.parse(state.pathParameters['matchId']!))),
    GoRoute(path: '/unlocked-reports', builder: (_, __) => const UnlockedReportsScreen()),
    GoRoute(path: '/credits', builder: (_, __) => const CreditsScreen()),
    GoRoute(path: '/subscription', builder: (_, __) => const SubscriptionScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  ],
);
