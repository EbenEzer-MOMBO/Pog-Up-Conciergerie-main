import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../config/app_theme.dart';

class HebergementDetailScreen extends StatefulWidget {
  final ServiceCategory category;

  const HebergementDetailScreen({super.key, required this.category});

  @override
  State<HebergementDetailScreen> createState() =>
      _HebergementDetailScreenState();
}

class _HebergementDetailScreenState extends State<HebergementDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _allHebergements = [];
  List<Map<String, dynamic>> _chambresHote = [];
  List<Map<String, dynamic>> _hotels = [];
  List<Map<String, dynamic>> _appartements = [];

  Color get _primaryColor => AppTheme.primaryRed;
  Color get _primaryColorSoft => _primaryColor.withValues(alpha: 0.1);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHebergements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHebergements() async {
    try {
      setState(() => _isLoading = true);

      // Charger tous les hébergements
      _allHebergements = await DatabaseService.getHebergements();

      _chambresHote = [];
      _hotels = [];
      _appartements = [];

      for (final hebergement in _allHebergements) {
        final rawSousType =
            (hebergement['sous_type'] ?? hebergement['type'] ?? '')
                .toString()
                .trim()
                .toLowerCase();

        switch (rawSousType) {
          case 'chambres_hotes':
          case 'chambre_hote':
          case 'chambre':
            _chambresHote.add(hebergement);
            break;
          case 'appartements':
          case 'appartement':
          case 'studio':
            _appartements.add(hebergement);
            break;
          case 'hotels':
          case 'hotel':
            _hotels.add(hebergement);
            break;
          default:
            final normalized = _normalizeHebergementText(hebergement);
            if (_matchesKeywords(
              normalized,
              const ['chambre', 'hote', 'hôte', 'guest house', 'maison'],
            )) {
              _chambresHote.add(hebergement);
            } else if (_matchesKeywords(
              normalized,
              const ['appartement', 'studio', 'loft', 'residence'],
            )) {
              _appartements.add(hebergement);
            } else if (_matchesKeywords(
              normalized,
              const ['hotel', 'hôtel', 'resort', 'auberge'],
            )) {
              _hotels.add(hebergement);
            } else {
              _hotels.add(hebergement);
            }
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des hébergements: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _normalizeText(String? value) {
    if (value == null) return '';
    final lower = value.toLowerCase();
    return lower
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _normalizeHebergementText(Map<String, dynamic> hebergement) {
    final service = hebergement['service'] as Map<String, dynamic>?;
    final buffer = StringBuffer();

    buffer
      ..write(_normalizeText(hebergement['sous_type']))
      ..write(' ')
      ..write(_normalizeText(hebergement['type']))
      ..write(' ')
      ..write(_normalizeText(hebergement['description']))
      ..write(' ')
      ..write(_normalizeText(service?['titre']))
      ..write(' ')
      ..write(_normalizeText(service?['description']));

    return buffer.toString();
  }

  bool _matchesKeywords(String normalizedText, List<String> keywords) {
    for (final keyword in keywords) {
      final normalizedKeyword = _normalizeText(keyword);
      if (normalizedText.contains(normalizedKeyword)) {
        return true;
      }
    }
    return false;
  }

  String _resolveHebergementLabel(Map<String, dynamic> hebergement) {
    final rawSousType =
        (hebergement['sous_type'] ?? hebergement['type'])?.toString().trim();
    if (rawSousType != null && rawSousType.isNotEmpty) {
      switch (rawSousType.toLowerCase()) {
        case 'chambres_hotes':
        case 'chambre_hote':
        case 'chambre':
          return 'Chambre d\'hôte';
        case 'hotels':
        case 'hotel':
          return 'Hôtel';
        case 'appartements':
        case 'appartement':
        case 'studio':
          return 'Appartement';
      }
    }

    final normalized = _normalizeHebergementText(hebergement);
    if (_matchesKeywords(normalized, const ['chambre', 'hote', 'hôte'])) {
      return 'Chambre d\'hôte';
    }
    if (_matchesKeywords(normalized, const ['appartement', 'studio', 'loft'])) {
      return 'Appartement';
    }
    if (_matchesKeywords(normalized, const ['hotel', 'hôtel', 'auberge'])) {
      return 'Hôtel';
    }

    return 'Hébergement';
  }

  String? _stringValue(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  String? _formatPrice(dynamic value) {
    if (value == null) return null;
    if (value is num) {
      if (value == value.roundToDouble()) {
        return value.toStringAsFixed(0);
      }
      return value.toStringAsFixed(2);
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      final sanitized = trimmed.replaceAll(' ', '');
      final parsed = num.tryParse(sanitized);
      if (parsed != null) {
        if (parsed == parsed.roundToDouble()) {
          return parsed.toStringAsFixed(0);
        }
        return parsed.toStringAsFixed(2);
      }
      return trimmed;
    }
    return null;
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _primaryColor,
          labelColor: _primaryColor,
          unselectedLabelColor: Colors.grey[600],
          tabs: [
            Tab(text: 'Chambres d\'hôte'),
            Tab(text: 'Hôtels'),
            Tab(text: 'Appartements'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryRed,
              ), // Rouge PogUp
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildChambresHote(),
                _buildHotels(),
                _buildAppartements(),
              ],
            ),
    );
  }

  Widget _buildChambresHote() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 16),
          ..._buildChambresHoteList(),
        ],
      ),
    );
  }

  Widget _buildHotels() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 16),
          ..._buildHotelsList(),
        ],
      ),
    );
  }

  Widget _buildAppartements() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 16),
          ..._buildAppartementsList(),
        ],
      ),
    );
  }

  List<Widget> _buildChambresHoteList() {
    if (_chambresHote.isEmpty) {
      return [
        _buildEmptyState('Aucune chambre d\'hôte disponible pour le moment')
      ];
    }

    return _chambresHote
        .map(
          (chambre) => _buildHebergementCard(
            chambre,
            subCategory: 'Chambres d\'hôte',
          ),
        )
        .toList();
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
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
                'assets/icons/hebergement.png',
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
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHotelsList() {
    if (_hotels.isEmpty) {
      return [_buildEmptyState('Aucun hôtel disponible pour le moment')];
    }

    return _hotels
        .map(
          (hotel) => _buildHebergementCard(
            hotel,
            subCategory: 'Hôtels',
          ),
        )
        .toList();
  }

  List<Widget> _buildAppartementsList() {
    if (_appartements.isEmpty) {
      return [_buildEmptyState('Aucun appartement disponible pour le moment')];
    }

    return _appartements
        .map(
          (appart) => _buildHebergementCard(
            appart,
            subCategory: 'Appartements',
          ),
        )
        .toList();
  }

  Widget _buildHebergementCard(
    Map<String, dynamic> hebergement, {
    required String subCategory,
  }) {
    final accentColor = _primaryColor;
    final service = hebergement['service'] as Map<String, dynamic>?;
    final serviceTitle = _stringValue(service?['titre']);
    final serviceDescription = _stringValue(service?['description']);
    final imageUrl = _stringValue(service?['image_url']) ?? '';
    final localisation = _stringValue(hebergement['localisation']);
    final capacityText = _stringValue(hebergement['capacite']);
    final hebergementDescription = _stringValue(hebergement['description']);
    final description =
        hebergementDescription != null && hebergementDescription.isNotEmpty
            ? hebergementDescription
            : serviceDescription;
    final descriptionText = description;
    final label = _resolveHebergementLabel(hebergement);
    final title = serviceTitle?.isNotEmpty == true ? serviceTitle! : label;
    final price = _formatPrice(hebergement['prix']) ??
        _formatPrice(service?['prix_estimatif']);
    final Map<String, dynamic> demandDetails = {
      'id': hebergement['id'],
    };
    final dynamic rawPrice =
        hebergement['prix'] ?? (service?['prix_estimatif']);
    if (rawPrice != null) {
      demandDetails['prix'] = rawPrice;
    }
    if (hebergement['sous_type'] != null) {
      demandDetails['sous_type'] = hebergement['sous_type'];
    }
    if (descriptionText != null && descriptionText.isNotEmpty) {
      demandDetails['description'] = descriptionText;
    }
    if (localisation != null) {
      demandDetails['localisation'] = localisation;
    }
    if (capacityText != null) {
      demandDetails['capacite'] = capacityText;
    }
    if (serviceTitle != null && serviceTitle.isNotEmpty) {
      demandDetails['service_title'] = serviceTitle;
    }
    if (imageUrl.isNotEmpty) {
      demandDetails['image_url'] = imageUrl;
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
        border: Border.all(color: _primaryColor.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: Center(
                          child: Image.asset(
                            'assets/icons/hebergement.png',
                            height: 80,
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/icons/hebergement.png',
                      height: 80,
                    ),
                  ),
                ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    if (price != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryColorSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'À partir de $price FCFA',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                if (descriptionText != null && descriptionText.isNotEmpty) ...[
                  SizedBox(height: 10),
                  Text(
                    descriptionText,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
                SizedBox(height: 12),
                Row(
                  children: [
                    if (localisation != null) ...[
                      Icon(Icons.location_on,
                          color: Colors.grey[600], size: 16),
                      SizedBox(width: 8),
                      Text(
                        localisation,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      SizedBox(width: 16),
                    ],
                    if (capacityText != null) ...[
                      Icon(Icons.people, color: Colors.grey[600], size: 16),
                      SizedBox(width: 8),
                      Text(
                        '$capacityText personnes',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showDetails(
                          hebergement,
                          subCategory,
                          demandDetails,
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: accentColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Détails',
                          style: TextStyle(color: accentColor),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _navigateToDemand(
                          subCategory: subCategory,
                          serviceLabel: title,
                          serviceDetails: demandDetails,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Réserver',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(
    Map<String, dynamic> hebergement,
    String subCategory,
    Map<String, dynamic> demandDetails,
  ) {
    final service = hebergement['service'] as Map<String, dynamic>?;
    final title = (service?['titre'] as String?)?.trim() ??
        _resolveHebergementLabel(hebergement);
    final descriptionRaw =
        ((hebergement['description'] as String?)?.trim().isNotEmpty == true)
            ? (hebergement['description'] as String).trim()
            : (service?['description'] as String?)?.trim();
    final descriptionText = descriptionRaw;
    final localisation =
        (hebergement['localisation'] as String?)?.trim().isNotEmpty == true
            ? (hebergement['localisation'] as String).trim()
            : null;
    final capacityRaw = hebergement['capacite'];
    final capacityText =
        capacityRaw == null || capacityRaw.toString().trim().isEmpty
            ? null
            : capacityRaw.toString().trim();
    final price = _formatPrice(hebergement['prix']) ??
        _formatPrice(service?['prix_estimatif']);
    final includedServices = hebergement['services'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    if (price != null) ...[
                      SizedBox(height: 8),
                      Text(
                        'À partir de $price FCFA',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                    if (descriptionText != null &&
                        descriptionText.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Text(
                        descriptionText,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                    if (localisation != null || capacityText != null) ...[
                      SizedBox(height: 16),
                      if (localisation != null)
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Expanded(child: Text(localisation)),
                          ],
                        ),
                      if (capacityText != null) ...[
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.people, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text('$capacityText personnes'),
                          ],
                        ),
                      ],
                    ],
                    if (includedServices is List &&
                        includedServices.isNotEmpty) ...[
                      SizedBox(height: 20),
                      Text(
                        'Services inclus',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...includedServices.map<Widget>((serviceItem) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                color: Colors.green,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(serviceItem.toString()),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToDemand(
                            subCategory: subCategory,
                            serviceLabel: title,
                            serviceDetails: demandDetails,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Réserver maintenant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDemand({
    required String subCategory,
    required String serviceLabel,
    Map<String, dynamic>? serviceDetails,
  }) {
    Navigator.pushNamed(
      context,
      '/demand',
      arguments: {
        'categoryId': 'hebergement',
        'subCategory': subCategory,
        'serviceLabel': serviceLabel,
        if (serviceDetails != null) 'serviceDetails': serviceDetails,
      },
    );
  }
}
