import 'package:absensi_mobile/core/utils/navigation.dart';
import 'package:absensi_mobile/feature/auth/presentation/screen/login.screen.dart';
import 'package:absensi_mobile/feature/launch/splash.screen.dart';
import 'package:absensi_mobile/feature/home/presentation/screen/home.screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/navigasi',
      builder: (context, state) {
        dynamic data = state.extra;
        return NavigationPage(data: data);
      },
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
  ],
);
