import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/screens/landing_screen.dart';
import 'package:project/screens/auth_screen.dart';
import 'package:project/screens/dashboard_screen.dart';
import 'package:project/screens/verification_wizard_screen.dart';
import 'package:project/screens/verification_progress_screen.dart';
import 'package:project/screens/certificate_screen.dart';
import 'package:project/screens/qr_verify_screen.dart';
import 'package:project/screens/settings_screen.dart';
import 'package:project/screens/help_screen.dart';
import 'package:project/screens/analytics_screen.dart';
import 'package:project/screens/profile_screen.dart';
import 'package:project/screens/notifications_screen.dart';
import 'package:project/screens/security_screen.dart';
import 'package:project/screens/features_screen.dart';
import 'package:project/screens/how_it_works_screen.dart';
import 'package:project/screens/docs_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.landing,
    routes: [
      GoRoute(
        path: AppRoutes.landing,
        name: 'landing',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LandingScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.auth,
        name: 'auth',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const AuthScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const DashboardScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.verify,
        name: 'verify',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const VerificationWizardScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.progress}/:id',
        name: 'progress',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CustomTransitionPage(
            child: VerificationProgressScreen(verificationId: id),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.certificate}/:id',
        name: 'certificate',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CustomTransitionPage(
            child: CertificateScreen(certificateId: id),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.qrVerify,
        name: 'qr-verify',
        pageBuilder: (context, state) {
          final certificateId = state.uri.queryParameters['id'];
          return CustomTransitionPage(
            child: QrVerifyScreen(certificateId: certificateId),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SettingsScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.help,
        name: 'help',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const HelpScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        name: 'analytics',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const AnalyticsScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ProfileScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const NotificationsScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.security,
        name: 'security',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SecurityScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.features,
        name: 'features',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const FeaturesScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.howItWorks,
        name: 'how-it-works',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const HowItWorksScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.docs,
        name: 'docs',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const DocsScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
    ],
  );
  
  static Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
    );
  }
  
  static Widget _slideUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }
}

class AppRoutes {
  static const String landing = '/';
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  static const String verify = '/verify';
  static const String progress = '/progress';
  static const String certificate = '/certificate';
  static const String qrVerify = '/qr-verify';
  static const String settings = '/settings';
  static const String help = '/help';
  static const String analytics = '/analytics';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String security = '/security';
  static const String features = '/features';
  static const String howItWorks = '/how-it-works';
  static const String docs = '/docs';
}
