import 'package:flutter/material.dart';

typedef TransportRequestCallback = void Function(
  String subCategory,
  String serviceLabel,
  Map<String, dynamic> serviceDetails,
);

class TransportEmptyState extends StatelessWidget {
  const TransportEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.5;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(minHeight: height, minWidth: double.infinity),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/transport.png',
              height: 88,
            ),
            const SizedBox(height: 16),
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
    );
  }
}

class TransportServiceImage extends StatelessWidget {
  const TransportServiceImage({
    super.key,
    required this.imageUrl,
    required this.fallbackIcon,
    required this.primaryColor,
    this.height = 200,
    this.borderRadius,
  });

  final String? imageUrl;
  final IconData fallbackIcon;
  final double height;
  final BorderRadius? borderRadius;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: radius,
        ),
        child: Center(
          child: Image.asset(
            'assets/icons/transport.png',
            height: 72,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        imageUrl!,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          final expectedBytes = loadingProgress.expectedTotalBytes;
          final loadedBytes = loadingProgress.cumulativeBytesLoaded;
          return Container(
            height: height,
            width: double.infinity,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                value:
                    expectedBytes != null ? loadedBytes / expectedBytes : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: radius,
            ),
            child: Center(
              child: Image.asset(
                'assets/icons/transport.png',
                height: 72,
              ),
            ),
          );
        },
      ),
    );
  }
}

class SchoolTransportCard extends StatelessWidget {
  const SchoolTransportCard({
    super.key,
    required this.transport,
    required this.primaryColor,
    required this.onRequest,
  });

  final Map<String, dynamic> transport;
  final Color primaryColor;
  final TransportRequestCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final service = transport['service'] as Map<String, dynamic>?;
    final serviceTitle = _stringValue(service?['titre']);
    final serviceDescription = _stringValue(service?['description']);
    final transportDescription = _stringValue(transport['description']);
    final description = serviceDescription ?? transportDescription;
    final price = _formatPrice(transport['prix']) ??
        _formatPrice(service?['prix_estimatif']);
    final imageUrl = _extractImageUrl(service, transport);
    final capacityText = _stringValue(transport['capacite']);
    final depart =
        _stringValue(transport['point_depart'] ?? transport['depart']);
    final arrivee =
        _stringValue(transport['point_arrivee'] ?? transport['arrivee']);
    final horaires = _stringValue(transport['horaires']);
    final typeTransport =
        _stringValue(transport['sous_type'] ?? transport['type_transport']);
    final heureDepart = _stringValue(transport['heure_depart']);
    final heureArrivee = _stringValue(transport['heure_arrivee']);
    final title = serviceTitle?.isNotEmpty == true
        ? serviceTitle!
        : (typeTransport?.isNotEmpty == true
            ? typeTransport!
            : 'Transport scolaire');
    final details = _baseDemandDetails(transport, service);
    _addIfPresent(details, 'description', description);
    _addIfPresent(details, 'capacite', capacityText);
    _addIfPresent(details, 'point_depart', depart);
    _addIfPresent(details, 'point_arrivee', arrivee);
    _addIfPresent(details, 'horaires', horaires);
    _addIfPresent(details, 'heure_depart', heureDepart);
    _addIfPresent(details, 'heure_arrivee', heureArrivee);
    final primarySoft = primaryColor.withValues(alpha: 0.12);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: primarySoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TransportServiceImage(
            imageUrl: imageUrl,
            fallbackIcon: Icons.directions_bus,
            height: 180,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            primaryColor: primaryColor,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    if (price != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primarySoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'À partir de $price FCFA',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
                if (depart != null || arrivee != null) ...[
                  const SizedBox(height: 12),
                  if (depart != null && depart.isNotEmpty)
                    Text(
                      'Départ : $depart',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  if (arrivee != null && arrivee.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Arrivée : $arrivee',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
                if (horaires != null && horaires.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Horaires : $horaires',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
                if (heureDepart != null || heureArrivee != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    [
                      if (heureDepart != null) 'Départ : $heureDepart',
                      if (heureArrivee != null) 'Arrivée : $heureArrivee',
                    ].join(' • '),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
                if (capacityText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$capacityText enfants',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => onRequest(
                      'Transport scolaire',
                      title,
                      details,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Demander ce service',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VehicleTransportCard extends StatelessWidget {
  const VehicleTransportCard({
    super.key,
    required this.transport,
    required this.primaryColor,
    required this.onRequest,
  });

  final Map<String, dynamic> transport;
  final Color primaryColor;
  final TransportRequestCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final service = transport['service'] as Map<String, dynamic>?;
    final imageUrl = _extractImageUrl(service, transport);
    final serviceTitle = _stringValue(service?['titre']);
    final serviceDescription = _stringValue(service?['description']);
    final serviceEstimPrice = _formatPrice(service?['prix_estimatif']);
    final marque = _stringValue(transport['marque']) ?? '';
    final modele = _stringValue(transport['modele']) ?? '';
    final transportDescription = _stringValue(transport['description']);
    final capacityText = _stringValue(transport['capacite']);
    final titleParts = [
      if (marque.isNotEmpty) marque,
      if (modele.isNotEmpty) modele,
    ];
    final title = titleParts.isNotEmpty
        ? titleParts.join(' ')
        : serviceTitle ?? 'Service de transport';
    final price = _formatPrice(transport['prix']) ?? serviceEstimPrice;
    final description = serviceDescription?.isNotEmpty == true
        ? serviceDescription
        : transportDescription;
    final details = _baseDemandDetails(transport, service);
    _addIfPresent(details, 'description', description);
    _addIfPresent(details, 'capacite', capacityText);
    _addIfPresent(details, 'marque', marque);
    _addIfPresent(details, 'modele', modele);
    final primarySoft = primaryColor.withValues(alpha: 0.12);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: primarySoft),
      ),
      child: Column(
        children: [
          TransportServiceImage(
            imageUrl: imageUrl,
            fallbackIcon: Icons.directions_car,
            height: 200,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            primaryColor: primaryColor,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    if (price != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primarySoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'À partir de $price FCFA',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (capacityText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$capacityText places',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => onRequest(
                      'Location véhicule',
                      title,
                      details,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Réserver',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VTCTransportCard extends StatelessWidget {
  const VTCTransportCard({
    super.key,
    required this.transport,
    required this.primaryColor,
    required this.onRequest,
  });

  final Map<String, dynamic> transport;
  final Color primaryColor;
  final TransportRequestCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final service = transport['service'] as Map<String, dynamic>?;
    final serviceTitle = _stringValue(service?['titre']);
    final serviceDescription = _stringValue(service?['description']);
    final titleRaw = _stringValue(transport['option_vtc']);
    final title = titleRaw?.isNotEmpty == true
        ? titleRaw!
        : serviceTitle ?? 'Service VTC';
    final price = _formatPrice(transport['prix']) ??
        _formatPrice(service?['prix_estimatif']);
    final subtitle = serviceDescription?.isNotEmpty == true
        ? serviceDescription!
        : 'Service de transport avec chauffeur';
    final imageUrl = _extractImageUrl(service, transport);
    final details = _baseDemandDetails(transport, service);
    _addIfPresent(details, 'description', subtitle);
    _addIfPresent(details, 'option_vtc', title);
    final gradientStart = primaryColor;
    final gradientEnd = primaryColor.withValues(alpha: 0.85);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border:
            Border.all(color: primaryColor.withValues(alpha: 0.12), width: 1),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SizedBox(
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TransportServiceImage(
                    imageUrl: imageUrl,
                    fallbackIcon: Icons.airport_shuttle_rounded,
                    height: 200,
                    borderRadius: BorderRadius.zero,
                    primaryColor: primaryColor,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 15,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (price != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.12),
                          primaryColor.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'À partir de $price FCFA',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [gradientStart, gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => onRequest('VTC', title, details),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Réserver maintenant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BusTransportCard extends StatelessWidget {
  const BusTransportCard({
    super.key,
    required this.transport,
    required this.primaryColor,
    required this.onRequest,
  });

  final Map<String, dynamic> transport;
  final Color primaryColor;
  final TransportRequestCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final service = transport['service'] as Map<String, dynamic>?;
    final serviceTitle = _stringValue(service?['titre']);
    final serviceDescription = _stringValue(service?['description']);
    final price = _formatPrice(transport['prix']) ??
        _formatPrice(service?['prix_estimatif']);
    final imageUrl = _extractImageUrl(service, transport);
    final details = _baseDemandDetails(transport, service);
    _addIfPresent(details, 'description', serviceDescription);
    _addIfPresent(details, 'capacite', transport['capacite']);
    _addIfPresent(details, 'horaires', transport['frequence']);
    final primarySoft = primaryColor.withValues(alpha: 0.12);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: primarySoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TransportServiceImage(
            imageUrl: imageUrl,
            fallbackIcon: Icons.directions_bus,
            height: 180,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            primaryColor: primaryColor,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        serviceTitle ?? 'Service de Bus',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    if (price != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primarySoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'À partir de $price FCFA',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                if (serviceDescription != null &&
                    serviceDescription.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    serviceDescription,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
                if (transport['capacite'] != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '${transport['capacite']} places',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
                if (transport['frequence'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    transport['frequence'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => onRequest(
                      'Bus',
                      serviceTitle ?? 'Service de Bus',
                      details,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Réserver',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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

String? _stringValue(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

String? _extractImageUrl(
  Map<String, dynamic>? service,
  Map<String, dynamic> transport,
) {
  final candidates = [
    service?['image_url'],
    service?['image'],
    service?['photo'],
    transport['image_url'],
    transport['image'],
    transport['photo'],
  ];

  for (final candidate in candidates) {
    if (candidate is String) {
      final trimmed = candidate.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
  }
  return null;
}

Map<String, dynamic> _baseDemandDetails(
  Map<String, dynamic> transport,
  Map<String, dynamic>? service,
) {
  final details = <String, dynamic>{};
  _addIfPresent(details, 'id', transport['id']);
  _addIfPresent(
      details, 'prix', transport['prix'] ?? service?['prix_estimatif']);
  _addIfPresent(details, 'sous_type', transport['sous_type']);
  _addIfPresent(details, 'service_title', service?['titre']);
  _addIfPresent(details, 'image_url', _extractImageUrl(service, transport));
  return details;
}

void _addIfPresent(Map<String, dynamic> target, String key, dynamic value) {
  if (value == null) return;
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    target[key] = trimmed;
    return;
  }
  target[key] = value;
}
