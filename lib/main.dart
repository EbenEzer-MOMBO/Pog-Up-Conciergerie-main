import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'config/app_theme.dart';
import 'config/supabase_config.dart';
import 'firebase_options.dart';
import 'screens/get_started_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/auth_screens.dart';
import 'screens/auth/profile_completion_screen.dart';
import 'screens/home_screen.dart';
import 'screens/demand_service_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/my_requests_screen.dart';
import 'screens/settings/privacy_settings_screen.dart';
import 'screens/settings/notification_settings_screen.dart';
import 'services/fcm_service.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

// Handler pour les messages en background (doit être top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Message reçu en background
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialiser le handler de messages en background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialiser Supabase
  await SupabaseConfig.initialize();

  // Initialiser FCM
  await FCMService.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Routes accessibles sans authentification
  static const _publicRoutes = {
    '/',
    '/get-started',
    '/splash',
    '/login',
    '/profile-completion',
    '/home',
  };

  @override
  Widget build(BuildContext c) => MaterialApp(
        title: 'My Pog\'Up',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (_) => const LaunchDecider(),
          '/get-started': (_) => const GetStartedScreen(),
          '/splash': (_) => const SplashScreen(),
          '/login': (_) => LoginScreen(),
          '/profile-completion': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            return ProfileCompletionScreen(
              email: args['email'],
              googleDisplayName: args['googleDisplayName'],
            );
          },
          '/home': (_) => HomeScreen(),
        },
        onGenerateRoute: (settings) {
          // Vérification d'authentification pour les routes protégées
          if (!_publicRoutes.contains(settings.name)) {
            final isLoggedIn = SupabaseConfig.currentUser != null;
            if (!isLoggedIn) {
              // Rediriger vers la page de connexion
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => LoginScreen(),
              );
            }
          }

          // Construction des routes protégées
          switch (settings.name) {
            case '/demand':
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => DemandServiceScreen(),
              );
            case '/profile':
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => UserProfileScreen(),
              );
            case '/requests':
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => MyRequestsScreen(),
              );
            case '/privacy-settings':
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => PrivacySettingsScreen(),
              );
            case '/notification-settings':
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => NotificationSettingsScreen(),
              );
            default:
              // Route inconnue — renvoyer vers l'accueil
              return MaterialPageRoute(
                builder: (_) => const LaunchDecider(),
              );
          }
        },
      );
}

class LaunchDecider extends StatefulWidget {
  const LaunchDecider({super.key});

  @override
  State<LaunchDecider> createState() => _LaunchDeciderState();
}

class _LaunchDeciderState extends State<LaunchDecider> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  Future<void> _redirect() async {
    // Demander l'autorisation de suivi publicitaire (Apple Requirement)
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      debugPrint('Erreur lors de la demande de suivi: $e');
    }

    // Attendre que Supabase restaure la session si elle existe
    try {
      // Utiliser la méthode asynchrone qui force la restauration de session
      final bool isAuthenticated = await SupabaseConfig.checkAuthentication();

      if (!mounted) return;

      final target = isAuthenticated ? '/home' : '/get-started';
      Navigator.pushReplacementNamed(context, target);
    } catch (e) {
      // En cas d'erreur, rediriger vers get-started
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/get-started');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppTheme.primaryRed),
      ),
    );
  }
}
