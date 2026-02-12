import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import '../services/services.dart';
import '../config/app_theme.dart';

class UsefulLinksScreen extends StatefulWidget {
  const UsefulLinksScreen({super.key});

  @override
  State<UsefulLinksScreen> createState() => _UsefulLinksScreenState();
}

class _UsefulLinksScreenState extends State<UsefulLinksScreen> {
  List<Map<String, dynamic>> _links = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    try {
      setState(() => _isLoading = true);
      _links = await DatabaseService.getLiensUtiles();
    } catch (e) {
      print('Erreur lors du chargement des liens: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Aucun lien disponible')));
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Impossible d\'ouvrir le lien';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ouverture du lien')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryRed),
            )
          : _links.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadLinks,
                  color: AppTheme.primaryRed,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _links.length,
                    itemBuilder: (context, index) {
                      final link = _links[index];
                      return _buildLinkCard(link);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/liens_utiles.json',
            width: 200,
            height: 200,
          ),
          SizedBox(height: 16),
          Text(
            'Aucun lien disponible pour le moment',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.mediumGray,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Les liens utiles s\'afficheront ici',
            style: TextStyle(fontSize: 16, color: AppTheme.mediumGray),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(Map<String, dynamic> link) {
    final logoUrl = link['logo_url'];

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _launchUrl(link['lien']),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Logo/Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.primaryRed.withValues(alpha: 0.1),
                ),
                child: logoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.business,
                              color: AppTheme.primaryRed,
                              size: 30,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.business,
                        color: AppTheme.primaryRed,
                        size: 30,
                      ),
              ),
              SizedBox(width: 16),
              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link['nom_entreprise'] ?? 'Sans nom',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    if (link['description'] != null) ...[
                      SizedBox(height: 4),
                      Text(
                        link['description'],
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 8),
                    Row(
                      children: [
                        if (link['telephone'] != null) ...[
                          Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            link['telephone'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 12),
                        ],
                        Icon(Icons.link, size: 14, color: AppTheme.primaryRed),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Voir le site',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryRed,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Icône de flèche
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
