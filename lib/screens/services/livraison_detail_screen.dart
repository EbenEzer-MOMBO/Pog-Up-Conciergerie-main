import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../config/app_theme.dart';

class LivraisonDetailScreen extends StatefulWidget {
  final ServiceCategory category;

  const LivraisonDetailScreen({super.key, required this.category});

  @override
  State<LivraisonDetailScreen> createState() => _LivraisonDetailScreenState();
}

class _LivraisonDetailScreenState extends State<LivraisonDetailScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _livraisons = [];

  @override
  void initState() {
    super.initState();
    _loadLivraisons();
  }

  Future<void> _loadLivraisons() async {
    try {
      setState(() => _isLoading = true);

      final records = await DatabaseService.getLivraisons();

      // Réinitialiser
      _livraisons = [];

      for (final livraison in records) {
        _livraisons.add(livraison);
      }
    } catch (e) {
      print('Erreur lors du chargement des livraisons: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.name,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.primaryRed),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryRed),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_livraisons.isEmpty) {
      return _buildEmptyState('Aucune livraison disponible pour le moment');
    }

    return RefreshIndicator(
      onRefresh: _loadLivraisons,
      color: AppTheme.primaryRed,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          children: _livraisons
              .map((livraison) => _buildLivraisonCard(livraison))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return RefreshIndicator(
      onRefresh: _loadLivraisons,
      color: AppTheme.primaryRed,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.5,
            minWidth: double.infinity,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/livraison.png',
                height: 88,
              ),
              SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: 'Montserrat',
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLivraisonCard(Map<String, dynamic> livraison) {
    final service = livraison['service'] as Map<String, dynamic>?;
    final imageUrl = _stringValue(service?['image_url']) ?? '';
    final serviceTitle = _stringValue(service?['titre']);
    final serviceDescription = _stringValue(service?['description']);
    final description =
        serviceDescription ?? _stringValue(livraison['instructions']);
    final depart = _stringValue(livraison['adresse_depart']);
    final arrivee = _stringValue(livraison['adresse_arrivee']);
    final typeColis = _stringValue(livraison['type_colis']);
    final poids = _stringValue(livraison['poids']);
    final priceText = _formatPrice(
          livraison['prix'],
        ) ??
        _formatPrice(service?['prix_estimatif']);

    final Map<String, dynamic> cardDetails = {
      'id': livraison['id'],
      'sous_type': 'tous',
      'service_title': serviceTitle ?? 'Livraison Tous',
      'description': description ??
          'Une prestation polyvalente pour tout type de livraison à la demande.',
      'adresse_depart': depart,
      'adresse_arrivee': arrivee,
      'type_colis': typeColis,
      'poids': poids,
      'instructions': _stringValue(livraison['instructions']),
    };

    if (livraison['prix'] != null) {
      cardDetails['prix'] = livraison['prix'];
    } else if (service?['prix_estimatif'] != null) {
      cardDetails['prix'] = service?['prix_estimatif'];
    }

    if (service != null) {
      cardDetails['service'] = service;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              ),
            )
          else
            _buildImagePlaceholder(),
          Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        serviceTitle ?? 'Livraison Tous',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          color: AppTheme.anthraciteGray,
                        ),
                      ),
                    ),
                    if (priceText != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'À partir de $priceText FCFA',
                          style: TextStyle(
                            color: AppTheme.primaryRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  description ??
                      'Une prestation polyvalente pour tout type de livraison à la demande.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 14),
                if (depart != null || arrivee != null) ...[
                  _buildInfoRow(
                    icon: Icons.alt_route,
                    label: [
                      if (depart != null) 'Départ: $depart',
                      if (arrivee != null) 'Arrivée: $arrivee',
                    ].join(' • '),
                  ),
                  SizedBox(height: 10),
                ],
                if (typeColis != null) ...[
                  _buildInfoRow(
                    icon: Icons.inventory_2,
                    label: 'Type de colis: $typeColis',
                  ),
                  SizedBox(height: 10),
                ],
                if (poids != null) ...[
                  _buildInfoRow(
                    icon: Icons.scale,
                    label: 'Poids estimé: $poids',
                  ),
                  SizedBox(height: 10),
                ],
                _buildRequestButton(cardDetails),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppTheme.primaryRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Image.asset(
          'assets/icons/livraison.png',
          height: 80,
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestButton(Map<String, dynamic>? details) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _navigateToDemand(details),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryRed,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Demander ce service',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }

  void _navigateToDemand(Map<String, dynamic>? details) {
    final arguments = {
      'categoryId': 'livraison',
      'subCategory': 'Tous',
      'serviceLabel': 'Livraison Tous',
      'serviceDetails': {
        'sous_type': 'tous',
        'service_title': 'Livraison Tous',
        'description':
            'Une prestation polyvalente pour tout type de livraison à la demande.',
        if (details != null) ...details,
      },
    };

    Navigator.pushNamed(
      context,
      '/demand',
      arguments: arguments,
    );
  }

  String? _stringValue(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  String? _formatPrice(dynamic value) {
    if (value == null) return null;
    if (value is num) {
      return value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(2);
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      final normalized = trimmed.replaceAll(RegExp(r'(?i)fcfa'), '').trim();
      final sanitized = normalized.replaceAll(' ', '');
      final withoutThousands = sanitized.replaceAll('.', '');
      final unifiedDecimal = withoutThousands.replaceAll(',', '.');
      final parsed = num.tryParse(unifiedDecimal);
      if (parsed != null) {
        return parsed == parsed.roundToDouble()
            ? parsed.toStringAsFixed(0)
            : parsed.toStringAsFixed(2);
      }
      return normalized.isEmpty ? null : normalized;
    }
    return value.toString();
  }
}
