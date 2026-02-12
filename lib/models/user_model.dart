class UserModel {
  final String id;
  final String prenom;
  final String nom;
  final String? dateNaissance;
  final String? genre;
  final String contact;
  final String email;
  final String role;
  final DateTime createdAt;
  final String? displayName; // Pour Google Sign-In
  final bool emailConfirmed; // Email confirmé
  final bool profileComplete; // Profil complet
  final DateTime? updatedAt; // Date de dernière mise à jour

  UserModel({
    required this.id,
    required this.prenom,
    required this.nom,
    this.dateNaissance,
    this.genre,
    required this.contact,
    required this.email,
    required this.role,
    required this.createdAt,
    this.displayName,
    this.emailConfirmed = false,
    this.profileComplete = false,
    this.updatedAt,
  });

  // Constructeur depuis Map (pour Supabase)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      prenom: map['prenom'] ?? '',
      nom: map['nom'] ?? '',
      dateNaissance: map['date_naissance'],
      genre: map['genre'],
      contact: map['contact'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      displayName: map['display_name'],
      emailConfirmed: map['email_confirmed'] ?? false,
      profileComplete: map['profile_complete'] ?? false,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  // Convertir en Map (pour Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prenom': prenom,
      'nom': nom,
      'date_naissance': dateNaissance,
      'genre': genre,
      'contact': contact,
      'email': email,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'display_name': displayName,
      'email_confirmed': emailConfirmed,
      'profile_complete': profileComplete,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Nom complet
  String get nomComplet => '$prenom $nom';

  // Vérifier si c'est un admin
  bool get isAdmin => role == 'admin' || role == 'super_admin';

  // Vérifier si le profil est complet
  bool isProfileComplete() {
    return prenom.isNotEmpty &&
        nom.isNotEmpty &&
        contact.isNotEmpty &&
        dateNaissance != null &&
        genre != null;
  }

  // Vérifier si l'utilisateur peut accéder à l'application
  bool get canAccessApp => emailConfirmed && profileComplete;
}
