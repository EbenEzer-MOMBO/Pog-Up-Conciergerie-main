class LienUtile {
  final String id;
  final String nomEntreprise;
  final String? description;
  final String? logoUrl;
  final String lien;
  final String? categorie;
  final String? telephone;
  final String? email;
  final bool actif;
  final int ordre;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LienUtile({
    required this.id,
    required this.nomEntreprise,
    this.description,
    this.logoUrl,
    required this.lien,
    this.categorie,
    this.telephone,
    this.email,
    this.actif = true,
    this.ordre = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory LienUtile.fromMap(Map<String, dynamic> map) {
    return LienUtile(
      id: map['id'] ?? '',
      nomEntreprise: map['nom_entreprise'] ?? '',
      description: map['description'],
      logoUrl: map['logo_url'],
      lien: map['lien'] ?? '',
      categorie: map['categorie'],
      telephone: map['telephone'],
      email: map['email'],
      actif: map['actif'] ?? true,
      ordre: map['ordre'] ?? 0,
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom_entreprise': nomEntreprise,
      'description': description,
      'logo_url': logoUrl,
      'lien': lien,
      'categorie': categorie,
      'telephone': telephone,
      'email': email,
      'actif': actif,
      'ordre': ordre,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
