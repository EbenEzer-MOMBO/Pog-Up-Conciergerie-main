class Livraison {
  final String id;
  final String? serviceId;
  final String? sousType;
  final String? adresseDepart;
  final String? adresseArrivee;
  final String? typeColis;
  final double? poids;
  final String? instructions;

  Livraison({
    required this.id,
    this.serviceId,
    this.sousType,
    this.adresseDepart,
    this.adresseArrivee,
    this.typeColis,
    this.poids,
    this.instructions,
  });

  factory Livraison.fromMap(Map<String, dynamic> map) {
    return Livraison(
      id: map['id'] ?? '',
      serviceId: map['service_id'],
      sousType: map['sous_type'],
      adresseDepart: map['adresse_depart'],
      adresseArrivee: map['adresse_arrivee'],
      typeColis: map['type_colis'],
      poids: map['poids']?.toDouble(),
      instructions: map['instructions'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'service_id': serviceId,
      'sous_type': sousType,
      'adresse_depart': adresseDepart,
      'adresse_arrivee': adresseArrivee,
      'type_colis': typeColis,
      'poids': poids,
      'instructions': instructions,
    };
  }

  String get displayName {
    if (sousType == null || sousType!.isEmpty) return 'Livraison';
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
    return 'Livraison $formatted';
  }
}
