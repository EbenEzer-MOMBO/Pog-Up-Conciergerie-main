import 'package:flutter/material.dart';
import '../services/services.dart';
import '../config/supabase_config.dart';
import '../config/app_theme.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _demandes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDemandes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDemandes() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId != null) {
        _demandes = await DatabaseService.getUserDemandes(userId);
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des demandes: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes Demandes',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.primaryRed),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryRed,
          labelColor: AppTheme.primaryRed,
          unselectedLabelColor: Colors.grey[600],
          tabs: [
            Tab(text: 'Toutes'),
            Tab(text: 'En attente'),
            Tab(text: 'En cours'),
            Tab(text: 'Terminées'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primaryRed))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDemandesList(_demandes),
                _buildDemandesList(
                  _demandes.where((d) => d['statut'] == 'en_attente').toList(),
                ),
                _buildDemandesList(
                  _demandes.where((d) => d['statut'] == 'en_cours').toList(),
                ),
                _buildDemandesList(
                  _demandes.where((d) => d['statut'] == 'termine').toList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/demand'),
        backgroundColor: AppTheme.primaryRed,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Faire une demande',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }

  Widget _buildDemandesList(List<Map<String, dynamic>> demandes) {
    if (demandes.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadDemandes,
      color: AppTheme.primaryRed,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: demandes.length,
        itemBuilder: (context, index) {
          final demande = demandes[index];
          return _buildDemandeCard(demande);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Aucune demande',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Vous n\'avez pas encore fait de demande',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Faire une demande'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pushNamed(context, '/demand'),
          ),
        ],
      ),
    );
  }

  Widget _buildDemandeCard(Map<String, dynamic> demande) {
    final status = demande['statut'];
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);
    final dateCreation = DateTime.parse(demande['date_creation']);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        demande['type_service'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Demandé le ${_formatDate(dateCreation)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Détails de la demande:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                _buildDetailsList(demande),
              ],
            ),
          ),
          if (status == 'en_attente')
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton.icon(
                icon: Icon(Icons.cancel, size: 18),
                label: Text('Annuler la demande'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _cancelDemande(demande),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsList(Map<String, dynamic> demande) {
    final detailsRaw = demande['details'];
    if (detailsRaw is! Map<String, dynamic>) {
      return Text(
        'Aucun détail disponible',
        style: TextStyle(color: Colors.grey[600]),
      );
    }

    final details = detailsRaw;
    final summary = _buildSummaryNote(
      demande['type_service']?.toString() ?? '',
      details,
    );

    if (summary == null) {
      return Text(
        'Aucun détail fourni',
        style: TextStyle(color: Colors.grey[600]),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.sticky_note_2, size: 20, color: AppTheme.primaryRed),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              summary,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _buildSummaryNote(String typeService, Map<String, dynamic> details) {
    String? clean(dynamic value) {
      if (value == null) return null;
      final str = value.toString().trim();
      return str.isEmpty ? null : str;
    }

    String joinParts(List<String> parts) {
      if (parts.isEmpty) return '';
      if (parts.length == 1) return parts.first;
      if (parts.length == 2) {
        return '${parts.first} et ${parts.last}';
      }
      final buffer = StringBuffer();
      for (int i = 0; i < parts.length; i++) {
        if (i == parts.length - 1) {
          buffer.write('et ${parts[i]}');
        } else {
          buffer.write('${parts[i]}, ');
        }
      }
      return buffer.toString();
    }

    final lower = typeService.toLowerCase();
    if (lower.contains('hébergement')) {
      final location = clean(details['localisation']);
      final people = clean(details['nb_personnes']);
      final duration = clean(details['duree']);
      final budget = clean(details['budget']);

      final parts = <String>[];
      if (location != null) parts.add('à $location');
      if (people != null) {
        final plural = people == '1' ? '' : 's';
        parts.add('pour $people personne$plural');
      }
      if (duration != null) parts.add('pendant $duration jours');
      if (budget != null) parts.add('avec un budget de $budget FCFA');

      if (parts.isEmpty) {
        return 'Votre demande d’hébergement a bien été enregistrée.';
      }
      return 'Votre demande d’hébergement a bien été enregistrée. Vous souhaitez un hébergement ${joinParts(parts)}.';
    }

    if (lower.contains('transport')) {
      final depart = clean(details['depart'] ?? details['adresse_depart']);
      final arrivee = clean(details['arrivee'] ?? details['adresse_arrivee']);
      final horaires = clean(details['horaire'] ?? details['horaires']);
      final budget = clean(details['budget']);

      final parts = <String>[];
      if (depart != null && arrivee != null) {
        parts.add('de $depart à $arrivee');
      } else if (depart != null) {
        parts.add('au départ de $depart');
      } else if (arrivee != null) {
        parts.add('vers $arrivee');
      }
      if (horaires != null) parts.add('prévu à $horaires');
      if (budget != null) parts.add('budget estimé : $budget FCFA');

      if (parts.isEmpty) {
        return 'Votre demande de transport a bien été enregistrée.';
      }
      return 'Votre demande de transport a bien été enregistrée. Nous organisons votre trajet ${joinParts(parts)}.';
    }

    if (lower.contains('livraison')) {
      final typeColis = clean(details['type_colis']);
      final depart = clean(details['adresse_depart']);
      final arrivee = clean(details['adresse_arrivee']);
      final poids = clean(details['poids']);
      final budget = clean(details['budget']);

      final parts = <String>[];
      if (typeColis != null) parts.add('pour un colis « $typeColis »');
      if (poids != null) parts.add('poids estimé : $poids');
      if (depart != null && arrivee != null) {
        parts.add('trajet de $depart à $arrivee');
      } else if (depart != null) {
        parts.add('départ depuis $depart');
      } else if (arrivee != null) {
        parts.add('destination $arrivee');
      }
      if (budget != null) parts.add('budget : $budget FCFA');

      if (parts.isEmpty) {
        return 'Votre demande de livraison a bien été enregistrée.';
      }
      return 'Votre demande de livraison a bien été enregistrée. Nous préparons la collecte et la livraison ${joinParts(parts)}.';
    }

    final description = clean(details['description']);
    return description;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'en_attente':
        return Colors.orange;
      case 'en_cours':
        return Colors.blue;
      case 'termine':
        return Colors.green;
      case 'annule':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'en_attente':
        return 'En attente';
      case 'en_cours':
        return 'En cours';
      case 'termine':
        return 'Terminé';
      case 'annule':
        return 'Annulé';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _cancelDemande(Map<String, dynamic> demande) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Annuler la demande'),
        content: Text('Êtes-vous sûr de vouloir annuler cette demande ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Non'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await DatabaseService.deleteDemande(demande['id']);
                await _loadDemandes();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Demande supprimée'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: ${e.toString()}'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(
              'Oui, supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
