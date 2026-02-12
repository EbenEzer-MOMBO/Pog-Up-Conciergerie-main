import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
  final String image;
  final Color color;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.image,
    required this.color,
  });

  static List<ServiceCategory> getMainCategories() {
    return [
      ServiceCategory(
        id: 'transport',
        name: 'Transport',
        icon: '🚗',
        description: 'Transport scolaire, location, VTC, bus',
        image: 'assets/images/chauffeur.jpg',
        color: const Color(
          0xFF6C7B7F,
        ).withValues(alpha: 0.3), // Gris foncé très transparent
      ),
      ServiceCategory(
        id: 'hebergement',
        name: 'Hébergement',
        icon: '🏨',
        description: 'Chambres d\'hôtes, hôtels, appartements',
        image: 'assets/images/hebergement.jpg',
        color: const Color(0xFF6C7B7F)
            .withValues(alpha: 0.3), // Noir très transparent
      ),
      ServiceCategory(
        id: 'livraison',
        name: 'Livraison',
        icon: '📦',
        description: 'Livraison express de colis',
        image: 'assets/images/livraison.jpg',
        color: const Color(
          0xFF6C7B7F,
        ).withValues(alpha: 0.3), // Gris bleuté très transparent
      ),
      ServiceCategory(
        id: 'autres',
        name: 'Autres Services',
        icon: '🧹',
        description: 'Ménage, pressing, aide personnelle',
        image: 'assets/images/nettoyage.jpg',
        color: const Color(
          0xFF6C7B7F,
        ).withValues(alpha: 0.3), // Gris bleuté très transparent
      ),
    ];
  }
}
