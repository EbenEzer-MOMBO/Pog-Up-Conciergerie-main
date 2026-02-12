import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../config/app_theme.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _privateModeEnabled = false;
  bool _twoFactorEnabled = true;
  bool _autoLogoutEnabled = true;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = await AuthService.getCurrentUserProfile();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _openDeleteAccountPage() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de charger les informations utilisateur'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Construire l'URL avec les paramètres de l'utilisateur
    final baseUrl = 'http://pogup-conciergerie.com/delete_account.html';
    final params = {
      'email': _currentUser!.email,
      'prenom': _currentUser!.prenom,
      'nom': _currentUser!.nom,
      'userId': _currentUser!.id,
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    final url = uri.toString();

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'ouvrir la page de suppression'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confidentialité',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.primaryRed),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader(
            title: 'Paramètres de confidentialité',
            icon: Icons.privacy_tip_outlined,
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            title: 'Mode privé',
            subtitle: 'Masquez votre profil aux autres utilisateurs',
            value: _privateModeEnabled,
            onChanged: (value) {
              setState(() {
                _privateModeEnabled = value;
              });
              // TODO: Save to backend
            },
          ),
          _buildSwitchTile(
            title: 'Authentification à deux facteurs',
            subtitle: 'Ajoutez une couche de sécurité supplémentaire',
            value: _twoFactorEnabled,
            onChanged: (value) {
              setState(() {
                _twoFactorEnabled = value;
              });
              // TODO: Save to backend
            },
          ),
          _buildSwitchTile(
            title: 'Déconnexion automatique',
            subtitle: 'Déconnectez-vous automatiquement après inactivité',
            value: _autoLogoutEnabled,
            onChanged: (value) {
              setState(() {
                _autoLogoutEnabled = value;
              });
              // TODO: Save to backend
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(
            title: 'Gestion des données',
            icon: Icons.storage,
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            title: 'Historique des activités',
            subtitle: 'Consultez les actions récentes liées à votre compte',
            icon: Icons.history_toggle_off,
            onTap: () {},
          ),
          _buildActionTile(
            title: 'Télécharger mes données',
            subtitle: 'Recevez une copie complète de vos informations',
            icon: Icons.download_outlined,
            onTap: () {},
          ),
          _buildActionTile(
            title: 'Supprimer mon compte',
            subtitle: 'Démarrez la procédure de suppression définitive',
            icon: Icons.delete_outline,
            highlight: true,
            onTap: _openDeleteAccountPage,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryRed, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryRed,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    bool highlight = false,
    required VoidCallback onTap,
  }) {
    final Color accentColor =
        highlight ? AppTheme.primaryRed : AppTheme.primaryRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accentColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
            color: highlight ? accentColor : const Color(0xFF2C3E50),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey[400],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
