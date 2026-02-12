// lib/services/apple_auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

class AppleAuthService {
  /// Connexion avec Apple
  static Future<UserModel?> signInWithApple() async {
    try {
      debugPrint('Démarrage de l\'authentification Apple...');

      if (kIsWeb) {
        debugPrint(
            'Détection plateforme Web: Utilisation d\'OAuth Supabase...');
        await SupabaseConfig.client.auth.signInWithOAuth(
          OAuthProvider.apple,
          redirectTo: kIsWeb ? Uri.base.origin : 'my-app-scheme://callback',
        );
        // Sur le web, signInWithOAuth redirige la page, donc le code après ne sera pas exécuté immédiatement
        return null;
      }

      final rawNonce = SupabaseConfig.client.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('Token ID Apple manquant');
      }

      debugPrint('Tokens Apple obtenus, authentification avec Supabase...');

      final AuthResponse response =
          await SupabaseConfig.client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      if (response.user == null) {
        throw Exception('Échec de l\'authentification Supabase');
      }

      debugPrint('Authentification Supabase réussie: ${response.user!.email}');

      final userProfile = await _createOrUpdateUserProfile(
        response.user!,
        credential,
      );

      return userProfile;
    } catch (e) {
      debugPrint('Erreur lors de la connexion Apple: $e');
      rethrow;
    }
  }

  /// Création ou mise à jour du profil utilisateur
  static Future<UserModel> _createOrUpdateUserProfile(
    User supabaseUser,
    AuthorizationCredentialAppleID appleCredential,
  ) async {
    try {
      // Vérification si l'utilisateur existe déjà
      final existingProfile = await SupabaseConfig.client
          .from('utilisateurs')
          .select()
          .eq('id', supabaseUser.id)
          .maybeSingle();

      final now = DateTime.now();

      // Apple ne renvoie le nom et l'email que lors de la TOUTE PREMIÈRE connexion
      String email = appleCredential.email ?? supabaseUser.email ?? '';
      String prenom = appleCredential.givenName ?? '';
      String nom = appleCredential.familyName ?? '';

      final userProfile = UserModel(
        id: supabaseUser.id,
        email: email,
        prenom: prenom,
        nom: nom,
        contact: '',
        role: 'user',
        createdAt: now,
        updatedAt: now,
        dateNaissance: null,
        genre: null,
        displayName: prenom.isNotEmpty ? '$prenom $nom' : null,
        emailConfirmed: true,
        profileComplete: false,
      );

      if (existingProfile == null) {
        // Création d'un nouveau profil
        await SupabaseConfig.client
            .from('utilisateurs')
            .insert(userProfile.toMap());
      } else {
        // Mise à jour si nous avons reçu de nouvelles infos (rare avec Apple après la 1ère fois)
        final Map<String, dynamic> updatedData = {
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (prenom.isNotEmpty) updatedData['prenom'] = prenom;
        if (nom.isNotEmpty) updatedData['nom'] = nom;
        if (email.isNotEmpty) updatedData['email'] = email;

        await SupabaseConfig.client
            .from('utilisateurs')
            .update(updatedData)
            .eq('id', supabaseUser.id);
      }

      // Récupérer le profil complet depuis la base de données
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
}
