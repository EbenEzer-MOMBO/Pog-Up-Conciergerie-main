import 'package:supabase_flutter/supabase_flutter.dart';
import 'environment.dart';

class SupabaseConfig {
  static late final SupabaseClient _client;
  static bool _initialized = false;

  // URLs et clés
  static const String supabaseUrl = Environment.supabaseUrl;
  static const String supabaseAnonKey = Environment.supabaseAnonKey;

  // Getter pour le client Supabase
  static SupabaseClient get client {
    if (!_initialized) {
      throw Exception(
        'Supabase n\'a pas été initialisé. Appelez SupabaseConfig.initialize() d\'abord.',
      );
    }
    return _client;
  }

  // Getter pour l'utilisateur actuel
  static User? get currentUser => _client.auth.currentUser;

  // Getter pour l'ID de l'utilisateur actuel
  static String? get currentUserId => _client.auth.currentUser?.id;

  // Initialiser Supabase
  static Future<void> initialize() async {
    if (_initialized) return;

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: Environment.enableLogging,
    );

    _client = Supabase.instance.client;
    _initialized = true;
  }

  // Stream d'état d'authentification
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  // Vérifier si l'utilisateur est connecté (synchrone)
  static bool get isAuthenticated => currentUser != null;
  
  // Vérifier si l'utilisateur est connecté de manière asynchrone (avec restauration de session)
  static Future<bool> checkAuthentication() async {
    try {
      // Attendre un peu pour que Supabase restaure la session
      await Future.delayed(const Duration(milliseconds: 300));
      // Vérifier si l'utilisateur est connecté
      return _client.auth.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  // Se déconnecter
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
