import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/transport/transport_cards.dart';
import '../../config/app_theme.dart';

class TransportDetailScreen extends StatefulWidget {
  final ServiceCategory category;

  const TransportDetailScreen({super.key, required this.category});

  @override
  State<TransportDetailScreen> createState() => _TransportDetailScreenState();
}

class _TransportDetailScreenState extends State<TransportDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _allTransports = [];
  List<Map<String, dynamic>> _locationTransports = [];
  List<Map<String, dynamic>> _vtcTransports = [];
  List<Map<String, dynamic>> _busTransports = [];
  List<Map<String, dynamic>> _schoolTransports = [];

  Color get _primaryColor => AppTheme.primaryRed;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTransportServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTransportServices() async {
    try {
      setState(() => _isLoading = true);

      // Charger tous les transports
      _allTransports = await DatabaseService.getTransports();

      _locationTransports = [];
      _vtcTransports = [];
      _busTransports = [];
      _schoolTransports = [];

      for (final transport in _allTransports) {
        final rawSousType =
            (transport['sous_type'] ?? transport['type_transport'] ?? '')
                .toString()
                .trim()
                .toLowerCase();

        switch (rawSousType) {
          case 'scolaire':
            _schoolTransports.add(transport);
            break;
          case 'vtc':
            _vtcTransports.add(transport);
            break;
          case 'bus':
            _busTransports.add(transport);
            break;
          case 'location':
            _locationTransports.add(transport);
            break;
          default:
            final normalizedText = _normalizeTransportText(transport);
            if (_matchesKeywords(
              normalizedText,
              const [
                'scolaire',
                'transport scolaire',
                'ecole',
                'college',
                'lycee',
                'ramassage scolaire'
              ],
            )) {
              _schoolTransports.add(transport);
            } else if (_matchesKeywords(
              normalizedText,
              const ['vtc', 'chauffeur prive'],
            )) {
              _vtcTransports.add(transport);
            } else if (_matchesKeywords(
              normalizedText,
              const ['bus', 'navette', 'minibus', 'coaster'],
            )) {
              _busTransports.add(transport);
            } else {
              _locationTransports.add(transport);
            }
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des services: $e');
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

  String _normalizeTransportText(Map<String, dynamic> transport) {
    final service = transport['service'] as Map<String, dynamic>?;
    final buffer = StringBuffer();

    buffer
      ..write(_normalizeText(transport['sous_type']))
      ..write(' ')
      ..write(_normalizeText(transport['type_transport']))
      ..write(' ')
      ..write(_normalizeText(transport['option_vtc']))
      ..write(' ')
      ..write(_normalizeText(transport['marque']))
      ..write(' ')
      ..write(_normalizeText(transport['modele']))
      ..write(' ')
      ..write(_normalizeText(service?['titre']))
      ..write(' ')
      ..write(_normalizeText(service?['description']));

    return buffer.toString();
  }

  bool _matchesKeywords(String normalizedText, List<String> keywords) {
    for (final keyword in keywords) {
      if (normalizedText.contains(keyword)) {
        return true;
      }
    }
    return false;
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
            Tab(text: 'Scolaire'),
            Tab(text: 'Location'),
            Tab(text: 'VTC'),
            Tab(text: 'Bus'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryRed),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTransportScolaire(),
                _buildLocationVehicule(),
                _buildVTC(),
                _buildBus(),
              ],
            ),
    );
  }

  Widget _buildTransportScolaire() {
    if (_schoolTransports.isEmpty) {
      return const TransportEmptyState(
        message: 'Aucun transport scolaire disponible pour le moment',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _schoolTransports
            .map(
              (transport) => SchoolTransportCard(
                transport: transport,
                primaryColor: _primaryColor,
                onRequest: _handleRequest,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildLocationVehicule() {
    if (_locationTransports.isEmpty) {
      return const TransportEmptyState(
        message: 'Aucun véhicule disponible pour le moment',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          ..._locationTransports.map(
            (transport) => VehicleTransportCard(
              transport: transport,
              primaryColor: _primaryColor,
              onRequest: _handleRequest,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVTC() {
    if (_vtcTransports.isEmpty) {
      return const TransportEmptyState(
        message: 'Aucun service VTC disponible pour le moment',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          ..._vtcTransports.map(
            (transport) => VTCTransportCard(
              transport: transport,
              primaryColor: _primaryColor,
              onRequest: _handleRequest,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBus() {
    if (_busTransports.isEmpty) {
      return const TransportEmptyState(
        message: 'Aucun service de bus disponible pour le moment',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          ..._busTransports.map(
            (transport) => BusTransportCard(
              transport: transport,
              primaryColor: _primaryColor,
              onRequest: _handleRequest,
            ),
          ),
        ],
      ),
    );
  }

  void _handleRequest(
    String subCategory,
    String serviceLabel,
    Map<String, dynamic> serviceDetails,
  ) {
    _navigateToDemand(
      subCategory: subCategory,
      serviceLabel: serviceLabel,
      serviceDetails: serviceDetails,
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
        'categoryId': 'transport',
        'subCategory': subCategory,
        'serviceLabel': serviceLabel,
        if (serviceDetails != null) 'serviceDetails': serviceDetails,
      },
    );
  }
}
