import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_controller.dart';
import 'pricing/pricing_region_controller.dart';
import 'firebase_options.dart';
import 'pages/event_upload_page.dart';
import 'pages/guest_join_page.dart';
import 'pages/guest_qr_scan_page.dart';
import 'pages/host_dashboard_page.dart';
import 'pages/landing_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/login_page.dart';
import 'pages/sign_up_page.dart';
import 'config/app_brand.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    authController.attachAuthListener();
  } catch (e, stack) {
    debugPrint(
      'Firebase init failed. Run: flutterfire configure\n$e\n$stack',
    );
  }
  try {
    await themeController.load();
  } catch (_) {}
  runApp(const GlamoraApp());
  // IP-based country for NGN vs USD pricing (non-blocking).
  pricingRegionController.detect();
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/host',
      builder: (context, state) => const HostDashboardPage(),
    ),
    GoRoute(
      path: '/join',
      builder: (context, state) => const GuestJoinPage(),
    ),
    GoRoute(
      path: '/join/scan',
      builder: (context, state) => const GuestQrScanPage(),
    ),
    GoRoute(
      path: '/e/:slug',
      builder: (_, state) {
        final slug = state.pathParameters['slug']!;
        return EventUploadPage(slug: slug);
      },
    ),
  ],
);

class GlamoraApp extends StatelessWidget {
  const GlamoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([pricingRegionController, themeController]),
      builder: (context, _) {
        return MaterialApp.router(
          title: AppBrand.displayName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeController.mode,
          routerConfig: _router,
        );
      },
    );
  }
}
