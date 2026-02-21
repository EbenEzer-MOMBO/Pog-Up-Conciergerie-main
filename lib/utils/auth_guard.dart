// lib/utils/auth_guard.dart
//
// Utilitaire centralisé de gestion des accès.
// Toutes les actions nécessitant une authentification passent par ce guard.

import 'package:flutter/material.dart';
import '../config/supabase_config.dart';
import '../config/app_theme.dart';

class AuthGuard {
  /// Vérifie que l'utilisateur est authentifié avant d'exécuter [action].
  ///
  /// Si l'utilisateur est connecté, [action] est exécutée immédiatement.
  /// Sinon, un bottom sheet est affiché proposant de se connecter.
  ///
  /// Retourne `true` si l'utilisateur était connecté, `false` sinon.
  static Future<bool> requireAuth(
    BuildContext context, {
    VoidCallback? action,
    String? featureName,
  }) async {
    final isLoggedIn = SupabaseConfig.currentUser != null;

    if (isLoggedIn) {
      action?.call();
      return true;
    }

    // Utilisateur non connecté → afficher le bottom sheet
    if (context.mounted) {
      await _showLoginPromptSheet(context, featureName: featureName);
    }
    return false;
  }

  /// Affiche un bottom sheet invitant l'utilisateur à se connecter.
  static Future<void> _showLoginPromptSheet(
    BuildContext context, {
    String? featureName,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _AuthPromptSheet(featureName: featureName),
    );
  }
}

/// Bottom sheet affiché aux utilisateurs invités qui tentent d'accéder
/// à une fonctionnalité nécessitant une authentification.
class _AuthPromptSheet extends StatelessWidget {
  final String? featureName;

  const _AuthPromptSheet({this.featureName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poignée de glissement
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Icône
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 36,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 20),

            // Titre
            Text(
              'Connexion requise',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                color: AppTheme.anthraciteGray,
              ),
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              featureName != null
                  ? 'Connectez-vous pour accéder à "$featureName".'
                  : 'Connectez-vous pour accéder à cette fonctionnalité et profiter de tous nos services.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Bouton Se connecter
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Se connecter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Bouton Annuler
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Continuer en tant qu\'invité',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
