class Transport {
  final String id;
  final String? serviceId;
  final String? sousType;
  final String? typeTransport;
  final String? depart;
  final String? arrivee;
  final String? horaire;
  final String? frequence;
  final int? capacite;
  final String? marque;
  final String? modele;
  final String? optionVtc;
  final double? prix;
  final String? heureDepart;
  final String? heureArrivee;

  Transport({
    required this.id,
    this.serviceId,
    this.sousType,
    this.typeTransport,
    this.depart,
    this.arrivee,
    this.horaire,
    this.frequence,
    this.capacite,
    this.marque,
    this.modele,
    this.optionVtc,
    this.prix,
    this.heureDepart,
    this.heureArrivee,
  });

  factory Transport.fromMap(Map<String, dynamic> map) {
    final sousTypeValue = map['sous_type'] ?? map['type_transport'];
    return Transport(
      id: map['id'] ?? '',
      serviceId: map['service_id'],
      sousType: sousTypeValue,
      typeTransport: map['type_transport'] ?? sousTypeValue,
      depart: map['depart'],
      arrivee: map['arrivee'],
      horaire: map['horaire'],
      frequence: map['frequence'],
      capacite: map['capacite'],
      marque: map['marque'],
      modele: map['modele'],
      optionVtc: map['option_vtc'],
      prix: map['prix']?.toDouble(),
      heureDepart: map['heure_depart'],
      heureArrivee: map['heure_arrivee'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'service_id': serviceId,
      'sous_type': sousType,
      'type_transport': typeTransport,
      'depart': depart,
      'arrivee': arrivee,
      'horaire': horaire,
      'frequence': frequence,
      'capacite': capacite,
      'marque': marque,
      'modele': modele,
      'option_vtc': optionVtc,
      'prix': prix,
      'heure_depart': heureDepart,
      'heure_arrivee': heureArrivee,
    };
  }

  String get displayName => marque != null && modele != null
      ? '$marque $modele'
      : _formatLabel(sousType ?? typeTransport ?? 'Transport');

  String _formatLabel(String value) {
    final formatted = value
        .replaceAll('_', ' ')
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              part.substring(0, 1).toUpperCase() +
              part.substring(1).toLowerCase(),
        )
        .join(' ');
    return formatted.isEmpty ? value : formatted;
  }
}
