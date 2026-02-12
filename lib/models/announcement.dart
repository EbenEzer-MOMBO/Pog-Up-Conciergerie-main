class Announcement {
  final String id;
  final String titre;
  final String? description;
  final String? imageUrl;
  final String? lien;
  final DateTime datePublication;
  final DateTime? dateExpiration;

  Announcement({
    required this.id,
    required this.titre,
    this.description,
    this.imageUrl,
    this.lien,
    required this.datePublication,
    this.dateExpiration,
  });

  // Constructeur depuis Map (pour Supabase)
  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'] ?? '',
      titre: map['titre'] ?? '',
      description: map['description'],
      imageUrl: map['image_url'],
      lien: map['lien'],
      datePublication: DateTime.parse(
        map['date_publication'] ?? DateTime.now().toIso8601String(),
      ),
      dateExpiration:
          map['date_expiration'] != null
              ? DateTime.parse(map['date_expiration'])
              : null,
    );
  }

  // Convertir en Map (pour Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'image_url': imageUrl,
      'lien': lien,
      'date_publication': datePublication.toIso8601String(),
      'date_expiration': dateExpiration?.toIso8601String(),
    };
  }

  // Vérifier si l'annonce est active
  bool get isActive {
    if (dateExpiration == null) return true;
    return DateTime.now().isBefore(dateExpiration!);
  }
}
