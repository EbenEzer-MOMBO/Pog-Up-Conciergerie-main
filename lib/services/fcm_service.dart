import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../config/supabase_config.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _lastKnownToken;

  // Initialiser FCM et demander les permissions
  static Future<void> initialize() async {
    try {
      // Demander les permissions pour les notifications
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Récupérer le token FCM
        String? token = await getToken();
        if (token != null) {
          await saveFCMToken(token);
        }

        // Écouter les changements de token
        _messaging.onTokenRefresh.listen((newToken) {
          saveFCMToken(newToken);
        });

        // Gérer les messages en foreground
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Gérer les messages en background
        FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation FCM: $e');
    }
  }

  // Récupérer le token FCM
  static Future<String?> getToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        _lastKnownToken = token;
      }
      return token;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du token FCM: $e');
      return null;
    }
  }

  // Sauvegarder le token FCM dans la base de données
  static Future<void> saveFCMToken(String token) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      _lastKnownToken = token;
      if (userId == null) {
        return;
      }

      await SupabaseConfig.client.from('utilisateurs').update({
        'fcm_id': token,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du token FCM: $e');
    }
  }

  // Sauvegarder le token pour l'utilisateur actuel s'il existe déjà
  static Future<void> ensureTokenForCurrentUser() async {
    try {
      final token = _lastKnownToken ?? await getToken();
      if (token == null) {
        return;
      }
      await saveFCMToken(token);
    } catch (e) {
      debugPrint('Erreur lors de l\'association du token FCM: $e');
    }
  }

  // Supprimer le token FCM lors de la déconnexion
  static Future<void> clearFCMToken() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return;

      await SupabaseConfig.client.from('utilisateurs').update({
        'fcm_id': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      await _messaging.deleteToken();
      _lastKnownToken = null;
    } catch (e) {
      debugPrint('Erreur lors de la suppression du token FCM: $e');
    }
  }

  // Gérer les messages en foreground (app ouverte)
  static void _handleForegroundMessage(RemoteMessage message) {
    // TODO: Afficher une notification locale
  }

  // Gérer les messages en background (app en arrière-plan)
  static void _handleBackgroundMessage(RemoteMessage message) {
    // TODO: Navigation vers l'écran approprié
  }

  // S'abonner à un topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      debugPrint('Erreur lors de l\'abonnement au topic: $e');
    }
  }

  // Se désabonner d'un topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      debugPrint('Erreur lors du désabonnement du topic: $e');
    }
  }
}

// Handler pour les messages en background (doit être top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Message reçu en background
}
