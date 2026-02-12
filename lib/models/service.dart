class Service {
  final String id;
  final String typeService;
  final String? titre;
  final String? description;
  final double? prixEstimatif;
  final DateTime createdAt;

  Service({
    required this.id,
    required this.typeService,
    this.titre,
    this.description,
    this.prixEstimatif,
    required this.createdAt,
  });

  // Constructeur depuis Map (pour Supabase)
  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] ?? '',
      typeService: map['type_service'] ?? '',
      titre: map['titre'],
      description: map['description'],
      prixEstimatif: map['prix_estimatif']?.toDouble(),
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // Convertir en Map (pour Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type_service': typeService,
      'titre': titre,
      'description': description,
      'prix_estimatif': prixEstimatif,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Nom d'affichage
  String get displayName => titre ?? typeService;
}
