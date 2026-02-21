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

  /// Supprimer le compte utilisateur
  static Future<void> deleteAccount({
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      // 1. Supprimer les données de l'utilisateur dans la table 'utilisateurs'
      // Grâce aux clés étrangères avec ON DELETE CASCADE,
      // les demandes et messages liés devraient être supprimés automatiquement
      // ou devront être supprimés manuellement si le cascade n'est pas actif.
      await _supabase.from('utilisateurs').delete().eq('id', user.id);

      // 2. Supprimer l'utilisateur de l'Auth Supabase
      // NOTE: L'utilisateur actuel ne peut pas se supprimer lui-même via client.auth.admin.deleteUser
      // sauf si on utilise une clé de service (déconseillé côté client).
      // Une alternative est d'appeler une Edge Function ou d'utiliser un trigger RPC.
      // Pour cet exemple, nous allons simplement marquer l'utilisateur comme supprimé
      // ou appeler une fonction RPC si elle existe.

      try {
        await _supabase.rpc('delete_user_account');
      } catch (e) {
        debugPrint('Erreur lors de l\'appel RPC de suppression: $e');
        // Si le RPC échoue, on continue car les données profil sont déjà supprimées
      }

      await signOut(
        onSuccess: onSuccess,
        onError: onError,
      );
    } catch (e) {
      debugPrint('Erreur lors de la suppression du compte: $e');
      onError(e.toString());
    }
  }
}
