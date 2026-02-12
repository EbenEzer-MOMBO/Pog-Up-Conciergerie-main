import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/service.dart';
import '../models/announcement.dart';
import '../models/transport.dart';
import '../models/hebergement.dart';
import '../models/livraison.dart';

class DatabaseService {
  static final SupabaseClient _supabase = SupabaseConfig.client;

  // ==========================
  // SERVICES
  // ==========================

  // Récupérer tous les services
  static Future<List<Service>> getServices() async {
    try {
      final response = await _supabase
          .from('services')
          .select('*')
          .order('created_at', ascending: false);

      return (response as List).map((data) => Service.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des services: $e');
    }
  }

  // Récupérer les services par type
  static Future<List<Service>> getServicesByType(String typeService) async {
    try {
      final response = await _supabase
          .from('services')
          .select('*')
          .eq('type_service', typeService)
          .order('created_at', ascending: false);

      return (response as List).map((data) => Service.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des services: $e');
    }
  }

  // Récupérer un service par ID
  static Future<Service?> getServiceById(String id) async {
    try {
      final response =
          await _supabase.from('services').select('*').eq('id', id).single();

      return Service.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  // ==========================
  // TRANSPORTS
  // ==========================

  // Récupérer tous les transports
  static Future<List<Map<String, dynamic>>> getTransports({
    String? type,
  }) async {
    try {
      var query = _supabase.from('transports').select('''
            *,
            service:services(*)
          ''');

      if (type != null) {
        query = query.eq('sous_type', type);
      }

      final response = await query
          .order('sous_type', ascending: true, nullsFirst: true)
          .order('id', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des transports: $e');
    }
  }

  // Récupérer un transport par ID
  static Future<Transport?> getTransportById(String id) async {
    try {
      final response =
          await _supabase.from('transports').select('*').eq('id', id).single();

      return Transport.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  // ==========================
  // HÉBERGEMENTS
  // ==========================

  // Récupérer tous les hébergements
  static Future<List<Map<String, dynamic>>> getHebergements({
    String? type,
  }) async {
    try {
      var query = _supabase.from('hebergements').select('''
            *,
            service:services(*)
          ''');

      if (type != null) {
        query = query.eq('sous_type', type);
      }

      final response = await query
          .order('sous_type', ascending: true, nullsFirst: true)
          .order('id', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des hébergements: $e');
    }
  }

  // Récupérer un hébergement par ID
  static Future<Hebergement?> getHebergementById(String id) async {
    try {
      final response = await _supabase
          .from('hebergements')
          .select('*')
          .eq('id', id)
          .single();

      return Hebergement.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  // ==========================
  // LIVRAISONS
  // ==========================

  // Récupérer toutes les livraisons
  static Future<List<Map<String, dynamic>>> getLivraisons() async {
    try {
      final response = await _supabase
          .from('livraisons')
          .select('''
            *,
            service:services(*)
          ''')
          .order('sous_type', ascending: true, nullsFirst: true)
          .order('id', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des livraisons: $e');
    }
  }

  // Récupérer une livraison par ID
  static Future<Livraison?> getLivraisonById(String id) async {
    try {
      final response =
          await _supabase.from('livraisons').select('*').eq('id', id).single();

      return Livraison.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  // ==========================
  // ANNONCES
  // ==========================

  // Récupérer toutes les annonces actives
  static Future<List<Announcement>> getAnnouncements() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('annonces')
          .select('*')
          .or('date_expiration.is.null,date_expiration.gt.$now')
          .order('date_publication', ascending: false);

      return (response as List)
          .map((data) => Announcement.fromMap(data))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des annonces: $e');
    }
  }

  // ==========================
  // LIENS UTILES
  // ==========================

  // Récupérer tous les liens utiles actifs
  static Future<List<Map<String, dynamic>>> getLiensUtiles({
    String? categorie,
  }) async {
    try {
      var query = _supabase.from('liens_utiles').select('*').eq('actif', true);

      if (categorie != null) {
        query = query.eq('categorie', categorie);
      }

      final response = await query.order('ordre', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des liens utiles: $e');
    }
  }

  // Récupérer un lien utile par ID
  static Future<Map<String, dynamic>?> getLienUtileById(String id) async {
    try {
      final response = await _supabase
          .from('liens_utiles')
          .select('*')
          .eq('id', id)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // ==========================
  // DEMANDES
  // ==========================

  // Créer une nouvelle demande
  static Future<void> createDemande({
    required String typeService,
    required String userId,
    Map<String, dynamic>? details,
  }) async {
    try {
      await _supabase.from('demandes').insert({
        'utilisateur_id': userId,
        'type_service': typeService,
        'statut': 'en_attente',
        'details': details,
      });
    } catch (e) {
      throw Exception('Erreur lors de la création de la demande: $e');
    }
  }

  // Récupérer les demandes d'un utilisateur
  static Future<List<Map<String, dynamic>>> getUserDemandes(
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from('demandes')
          .select('*')
          .eq('utilisateur_id', userId)
          .order('date_creation', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des demandes: $e');
    }
  }

  // Mettre à jour le statut d'une demande
  static Future<void> updateDemandeStatus(
    String demandeId,
    String status,
  ) async {
    try {
      await _supabase
          .from('demandes')
          .update({'statut': status}).eq('id', demandeId);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  static Future<void> deleteDemande(String demandeId) async {
    try {
      await _supabase.from('demandes').delete().eq('id', demandeId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la demande: $e');
    }
  }

  // ==========================
  // MESSAGES
  // ==========================

  // Envoyer un message
  static Future<void> sendMessage({
    required String demandeId,
    required String emetteurId,
    required String contenu,
  }) async {
    try {
      await _supabase.from('messages').insert({
        'demande_id': demandeId,
        'emetteur': emetteurId,
        'contenu': contenu,
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du message: $e');
    }
  }

  // Récupérer les messages d'une demande
  static Future<List<Map<String, dynamic>>> getDemandeMessages(
    String demandeId,
  ) async {
    try {
      final response = await _supabase.from('messages').select('''
            *,
            emetteur:utilisateurs(prenom, nom)
          ''').eq('demande_id', demandeId).order('date_envoi', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages: $e');
    }
  }

  // ==========================
  // NOTIFICATIONS
  // ==========================

  // Récupérer les notifications d'un utilisateur
  static Future<List<Map<String, dynamic>>> getUserNotifications(
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('utilisateur_id', userId)
          .order('date_envoi', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des notifications: $e');
    }
  }

  // Marquer une notification comme lue
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'statut': 'lu'}).eq('id', notificationId);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la notification: $e');
    }
  }
}
