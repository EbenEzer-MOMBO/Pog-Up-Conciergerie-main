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
          '/demand': (_) => DemandServiceScreen(),
          '/profile': (_) => UserProfileScreen(),
          '/requests': (_) => MyRequestsScreen(),
          '/privacy-settings': (_) => PrivacySettingsScreen(),
          '/notification-settings': (_) => NotificationSettingsScreen(),
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
