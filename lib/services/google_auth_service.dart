// lib/services/google_auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

class GoogleAuthService {
  // Instance GoogleSignIn pour API 6.x - SANS serverClientId pour éviter les problèmes de nonce
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Connexion avec Google - API 6.x compatible
  static Future<UserModel?> signInWithGoogle() async {
    try {
      debugPrint('Démarrage de l\'authentification Google...');

      // API google_sign_in 6.x - utilise signIn() au lieu de authenticate()
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('Connexion Google annulée par l\'utilisateur');
        return null;
      }

      debugPrint('Utilisateur Google authentifié: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Token ID Google manquant');
      }

      debugPrint('Tokens Google obtenus, authentification avec Supabase...');

      // Authentification avec Supabase SANS serverClientId ni nonce
      // L'idToken de Google natif ne contient pas de nonce
      final AuthResponse response =
          await SupabaseConfig.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw Exception('Échec de l\'authentification Supabase');
      }

      debugPrint('Authentification Supabase réussie: ${response.user!.email}');

      final userProfile = await _createOrUpdateUserProfile(
        response.user!,
        googleUser,
      );

      return userProfile;
    } catch (e) {
      debugPrint('Erreur lors de la connexion Google: $e');
      rethrow;
    }
  }

  /// Création ou mise à jour du profil utilisateur
  static Future<UserModel> _createOrUpdateUserProfile(
    User supabaseUser,
    GoogleSignInAccount googleUser,
  ) async {
    try {
      // Vérification si l'utilisateur existe déjà
      final existingProfile = await SupabaseConfig.client
          .from('utilisateurs')
          .select()
          .eq('id', supabaseUser.id)
          .maybeSingle();

      final now = DateTime.now();
      final userProfile = UserModel(
        id: supabaseUser.id,
        email: googleUser.email,
        prenom: googleUser.displayName?.split(' ').first ?? '',
        nom: googleUser.displayName?.split(' ').skip(1).join(' ') ?? '',
        contact: '',
        role: 'user',
        createdAt: now,
        updatedAt: now,
        dateNaissance: null,
        genre: null,
        displayName: googleUser.displayName,
        emailConfirmed: true, // Google confirme automatiquement l'email
        profileComplete: false, // Profil à compléter
      );

      if (existingProfile == null) {
        // Création d'un nouveau profil
        await SupabaseConfig.client
            .from('utilisateurs')
            .insert(userProfile.toMap());
      } else {
        // Mise à jour du profil existant avec les données Google
        final updatedData = {
          'email': googleUser.email,
          'prenom': googleUser.displayName?.split(' ').first ??
              existingProfile['prenom'],
          'nom': googleUser.displayName?.split(' ').skip(1).join(' ') ??
              existingProfile['nom'],
          'updated_at': DateTime.now().toIso8601String(),
        };

        await SupabaseConfig.client
            .from('utilisateurs')
            .update(updatedData)
            .eq('id', supabaseUser.id);
      }

      // Récupérer le profil depuis la base de données
      final savedProfile = await SupabaseConfig.client
          .from('utilisateurs')
          .select()
          .eq('id', supabaseUser.id)
          .single();

      return UserModel.fromMap(savedProfile);
    } catch (e) {
      debugPrint('Erreur lors de la création/mise à jour du profil: $e');
      rethrow;
    }
  }

  /// Déconnexion Google
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await SupabaseConfig.client.auth.signOut();
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion Google: $e');
      rethrow;
    }
  }
}
