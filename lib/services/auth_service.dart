// lib/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';
import 'google_auth_service.dart';
import 'apple_auth_service.dart';
import 'fcm_service.dart';

enum AppAuthState { unauthenticated, profileIncomplete, authenticated }

/// Service d'authentification simplifié
class AuthService {
  static final SupabaseClient _supabase = SupabaseConfig.client;

  /// Connexion avec Google - Version simplifiée
  static Future<void> signInWithGoogle({
    required Function(UserModel) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final userProfile = await GoogleAuthService.signInWithGoogle();
      if (userProfile != null) {
        await FCMService.ensureTokenForCurrentUser();
        onSuccess(userProfile);
      } else {
        throw Exception('Échec de la connexion Google');
      }
    } catch (e) {
      debugPrint('Erreur lors du connexion Google: $e');
      onError(e.toString());
    }
  }

  /// Connexion avec Apple
  static Future<void> signInWithApple({
    required Function(UserModel) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final userProfile = await AppleAuthService.signInWithApple();
      if (userProfile != null) {
        await FCMService.ensureTokenForCurrentUser();
        onSuccess(userProfile);
      } else if (!kIsWeb) {
        throw Exception('Échec de la connexion Apple');
      }
    } catch (e) {
      debugPrint('Erreur lors du connexion Apple: $e');
      onError(e.toString());
    }
  }

  /// Mise à jour du profil utilisateur
  static Future<void> updateUserProfile({
    required Map<String, dynamic> profileData,
    required Function(UserModel updatedProfile) onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      await _supabase.from('utilisateurs').update({
        ...profileData,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      final updatedProfile = await getCurrentUserProfile();
      if (updatedProfile == null) {
        throw Exception('Impossible de récupérer le profil mis à jour');
      }

      onSuccess(updatedProfile);
    } catch (e) {
      debugPrint('Erreur updateUserProfile: $e');
      onError(e.toString());
    }
  }

  /// Déconnexion
  static Future<void> signOut({
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      await FCMService.clearFCMToken();
      await GoogleAuthService.signOut();
      onSuccess();
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
      onError(e.toString());
    }
  }

  /// Récupérer le profil utilisateur actuel
  static Future<UserModel?> getCurrentUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('utilisateurs')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromMap(response);
    } catch (e) {
      debugPrint('Erreur lors du récupération du profil: $e');
      return null;
    }
  }

  /// Vérifier si l'utilisateur est connecté
  static bool get isLoggedIn => _supabase.auth.currentUser != null;

  /// Obtenir l'utilisateur actuel
  static User? get currentUser => _supabase.auth.currentUser;

  /// Obtenir l'état d'authentification
  static Future<AppAuthState> getAuthState() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return AppAuthState.unauthenticated;
      }

      final profile = await getCurrentUserProfile();
      if (profile == null) {
        return AppAuthState.unauthenticated;
      }

      if (!profile.canAccessApp) {
        return AppAuthState.profileIncomplete;
      }

      return AppAuthState.authenticated;
    } catch (e) {
      debugPrint(
        'Erreur lors de la vérification de l\'état d\'authentification: $e',
      );
      return AppAuthState.unauthenticated;
    }
  }
}
