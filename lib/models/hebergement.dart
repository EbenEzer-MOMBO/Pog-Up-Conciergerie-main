class Hebergement {
  final String id;
  final String? serviceId;
  final String? sousType;
  final String? localisation;
  final int? capacite;
  final double? prix;
  final String? description;

  Hebergement({
    required this.id,
    this.serviceId,
    this.sousType,
    this.localisation,
    this.capacite,
    this.prix,
    this.description,
  });

  factory Hebergement.fromMap(Map<String, dynamic> map) {
    return Hebergement(
      id: map['id'] ?? '',
      serviceId: map['service_id'],
      sousType: map['sous_type'] ?? map['type'],
      localisation: map['localisation'],
      capacite: map['capacite'],
      prix: map['prix']?.toDouble(),
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'service_id': serviceId,
      'sous_type': sousType,
      'localisation': localisation,
      'capacite': capacite,
      'prix': prix,
      'description': description,
    };
  }

  String get displayName {
    if (sousType == null || sousType!.isEmpty) return 'Hébergement';
    final formatted = sousType!
        .replaceAll('_', ' ')
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              part.substring(0, 1).toUpperCase() +
              part.substring(1).toLowerCase(),
        )
        .join(' ');
    return formatted;
  }
}
