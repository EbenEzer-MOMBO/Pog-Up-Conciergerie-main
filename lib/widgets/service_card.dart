import 'package:flutter/material.dart';
import '../models/service.dart';
import '../screens/service_detail_screen.dart';

class ServiceCard extends StatefulWidget {
  final Service service;

  const ServiceCard({super.key, required this.service});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(service: widget.service),
          ),
        );
      },
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: widget.service.id,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.withValues(alpha: 0.8),
                          Colors.orange.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getServiceIcon(widget.service.typeService),
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    child: Text(
                      widget.service.displayName,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(String typeService) {
    switch (typeService.toLowerCase()) {
      case 'transport':
        return Icons.directions_car;
      case 'hébergement':
      case 'hebergement':
        return Icons.hotel;
      case 'restauration':
        return Icons.restaurant;
      case 'nettoyage':
        return Icons.cleaning_services;
      case 'spa':
        return Icons.spa;
      case 'chauffeur':
        return Icons.person;
      case 'courses':
        return Icons.shopping_cart;
      case 'déménagement':
      case 'demenagement':
        return Icons.local_shipping;
      case 'événement':
      case 'evenement':
        return Icons.event;
      case 'assistance':
        return Icons.support_agent;
      case 'urgences':
        return Icons.emergency;
      case 'administratif':
        return Icons.description;
      case 'temps':
        return Icons.access_time;
      case 'frais':
        return Icons.payment;
      case 'livraison':
        return Icons.delivery_dining;
      default:
        return Icons.build;
    }
  }
}
