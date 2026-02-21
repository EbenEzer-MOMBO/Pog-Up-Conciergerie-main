import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../services/services.dart';
import '../config/supabase_config.dart';
import '../screens/announcement_screen.dart';
import '../screens/useful_links_screen.dart';
import '../screens/partner_request_screen.dart';
import '../screens/announcement_request_screen.dart';
import 'services/transport_detail_screen.dart';
import 'services/hebergement_detail_screen.dart';
import 'services/livraison_detail_screen.dart';
import '../config/app_theme.dart';
import '../utils/auth_guard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  List<ServiceCategory> categories = [];
  List<Announcement> announcements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);

      // Charger les catégories principales
      categories = ServiceCategory.getMainCategories();

      // Charger les annonces depuis Supabase
      announcements = await DatabaseService.getAnnouncements();
    } catch (e) {
      debugPrint('Erreur lors du chargement des données: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    // L'onglet Profil (index 3) est réservé aux utilisateurs connectés
    if (index == 3) {
      AuthGuard.requireAuth(
        context,
        featureName: 'Profil',
        action: () => setState(() => _selectedIndex = index),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomeContent() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primaryRed,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            SizedBox(height: 20),
            _buildAnnouncementsSection(),
            SizedBox(height: 24),
            _buildCategoriesSection(),
            SizedBox(height: 24),
            _buildQuickActionsSection(),
            SizedBox(height: 100), // Espace pour le bouton flottant
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsSection() {
    if (announcements.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Annonces',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
            TextButton(
              onPressed: () => _onItemTapped(1), // Aller aux annonces
              child: Text(
                'Voir tout',
                style: TextStyle(
                  color: AppTheme.primaryRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return AnnouncementCard(
                announcement: announcement,
                onTap: () => _onAnnouncementTap(announcement),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nos Services',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryCard(
              category: category,
              onTap: () => _onCategoryTap(category),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions Rapides',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        if (SupabaseConfig.currentUser != null) ...[
          SizedBox(height: 16),
          _buildMyRequestsCard(),
        ],
      ],
    );
  }

  Widget _buildMyRequestsCard() {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.5,
        child: GestureDetector(
          onTap: _navigateToMyRequests,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -10,
                  left: -10,
                  right: -10,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/icons/mes_demandes.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Mes Demandes',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Méthodes de navigation
  void _onCategoryTap(ServiceCategory category) {
    switch (category.id) {
      case 'transport':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransportDetailScreen(category: category),
          ),
        );
        break;
      case 'hebergement':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HebergementDetailScreen(category: category),
          ),
        );
        break;
      case 'livraison':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LivraisonDetailScreen(category: category),
          ),
        );
        break;
      case 'autres':
        _showOtherServicesSheet();
        break;
    }
  }

  void _onAnnouncementTap(Announcement announcement) {
    if (announcement.lien != null) {
      // TODO: Ouvrir le lien
    }
  }

  void _navigateToMyRequests() {
    AuthGuard.requireAuth(
      context,
      featureName: 'Mes demandes',
      action: () => Navigator.pushNamed(context, '/requests'),
    );
  }

  void _navigateToProfile() {
    AuthGuard.requireAuth(
      context,
      featureName: 'Mon profil',
      action: () => Navigator.pushNamed(context, '/profile'),
    );
  }

  void _navigateToDemandScreen() {
    AuthGuard.requireAuth(
      context,
      featureName: 'Demander un service',
      action: () => Navigator.pushNamed(context, '/demand'),
    );
  }

  void _showQuickActionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Actions Rapides',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.handshake,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                    title: Text(
                      'Devenir Partenaire',
                      style: TextStyle(fontFamily: 'Montserrat'),
                    ),
                    subtitle: Text('Rejoignez notre réseau'),
                    onTap: () {
                      Navigator.pop(context);
                      AuthGuard.requireAuth(
                        context,
                        featureName: 'Devenir Partenaire',
                        action: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PartnerRequestScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.campaign, color: AppTheme.primaryRed),
                    ),
                    title: Text(
                      'Créer une Annonce',
                      style: TextStyle(fontFamily: 'Montserrat'),
                    ),
                    subtitle: Text('Publiez votre annonce'),
                    onTap: () {
                      Navigator.pop(context);
                      AuthGuard.requireAuth(
                        context,
                        featureName: 'Créer une Annonce',
                        action: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnnouncementRequestScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOtherServicesSheet() {
    final otherServices = [
      {
        'label': 'Ménage',
        'icon': Icons.cleaning_services_outlined,
        'description':
            'Entretien, nettoyage et remise en ordre de votre espace.',
      },
      {
        'label': 'Pressing',
        'icon': Icons.local_laundry_service_outlined,
        'description': 'Collecte, nettoyage et livraison de vos textiles.',
      },
      {
        'label': 'Aide personnelle',
        'icon': Icons.health_and_safety_outlined,
        'description': 'Services d’assistance pour vos besoins du quotidien.',
      },
      {
        'label': 'Autre',
        'icon': Icons.more_horiz,
        'description': 'Décrivez-nous votre besoin spécifique.',
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Autres services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey[700]),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Choisissez un service pour faire votre demande instantanément.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(height: 20),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 360),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: otherServices.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final service = otherServices[index];
                      return Material(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              '/demand',
                              arguments: {
                                'categoryId': 'autres',
                                'subCategory': service['label'],
                                'serviceLabel': service['label'],
                                'description': service['description'],
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryRed
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    service['icon'] as IconData,
                                    color: AppTheme.primaryRed,
                                    size: 26,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service['label'] as String,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        service['description'] as String,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 18,
                                  color: Colors.grey[500],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    // Cette méthode n'est appelée que si l'utilisateur est authentifié
    // (la garde dans _onItemTapped empêche les invités d'atteindre cet onglet)
    return FutureBuilder<UserModel?>(
      future: AuthService.getCurrentUserProfile(),
      builder: (context, snapshot) {
        String displayName = 'Compte utilisateur';
        String email = 'Non disponible';
        String initials = 'U';

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          email = user.email;

          // Prioriser prénom + nom de la table utilisateurs si remplis
          if (user.prenom.isNotEmpty && user.nom.isNotEmpty) {
            displayName = '${user.prenom} ${user.nom}';
          } else if (user.prenom.isNotEmpty) {
            displayName = user.prenom;
          } else if (user.nom.isNotEmpty) {
            displayName = user.nom;
          } else {
            // Fallback sur display_name seulement si prénom et nom sont vides
            displayName = user.displayName ?? email;
          }

          // Calculer les initiales
          if (user.prenom.isNotEmpty && user.nom.isNotEmpty) {
            initials = '${user.prenom[0]}${user.nom[0]}'.toUpperCase();
          } else if (user.prenom.isNotEmpty) {
            initials = user.prenom[0].toUpperCase();
          } else if (user.nom.isNotEmpty) {
            initials = user.nom[0].toUpperCase();
          } else if (displayName.isNotEmpty) {
            initials = displayName[0].toUpperCase();
          }
        } else {
          // Fallback si pas de profil : utiliser les métadonnées Supabase
          final supabaseUser = SupabaseConfig.currentUser;
          if (supabaseUser != null) {
            final Map<String, dynamic> metadata =
                Map<String, dynamic>.from(supabaseUser.userMetadata ?? {});
            final rawName = metadata['full_name'] ??
                metadata['name'] ??
                metadata['display_name'];
            email = supabaseUser.email ?? 'Compte utilisateur';
            displayName = rawName is String && rawName.trim().isNotEmpty
                ? rawName.trim()
                : email;
            final initialsSource =
                displayName.trim().isNotEmpty ? displayName : email;
            initials = initialsSource.trim().isNotEmpty
                ? initialsSource.trim()[0].toUpperCase()
                : 'U';
          }
        }

        return Container(
          color: Color(0xFFF5F6F8),
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              _buildProfileHeader(displayName, email, initials),
              SizedBox(height: 24),
              _buildProfileMenuCard(
                icon: Icons.person_outline,
                title: 'Mes informations',
                subtitle:
                    'Consultez et mettez à jour vos informations personnelles.',
                onTap: _navigateToProfile,
              ),
              _buildProfileMenuCard(
                icon: Icons.lock_outline,
                title: 'Confidentialité',
                subtitle:
                    'Gérez vos paramètres de sécurité et de confidentialité.',
                onTap: () => Navigator.pushNamed(context, '/privacy-settings'),
              ),
              _buildProfileMenuCard(
                icon: Icons.notifications_active_outlined,
                title: 'Notifications',
                subtitle:
                    'Choisissez comment et quand vous souhaitez être averti.',
                onTap: () =>
                    Navigator.pushNamed(context, '/notification-settings'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(String name, String email, String initials) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryRed,
            AppTheme.goldYellow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRed.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Votre espace personnel centralise vos actions et réglages.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.03),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: AppTheme.primaryRed, size: 26),
                ),
                SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8F9FA)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Titre "Pog'Up!" + "Conciergerie" avec menu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'My Pog\'',
                                    style:
                                        TextStyle(color: AppTheme.primaryRed),
                                  ),
                                  TextSpan(
                                    text: 'Up!',
                                    style: TextStyle(
                                        color: AppTheme.anthraciteGray),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFFC300),
                                    Color(0xFFFFB300),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFFFC300)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'CONCIERGERIE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Menu button
                      IconButton(
                        onPressed: _showQuickActionsMenu,
                        icon: Icon(Icons.menu, size: 24),
                        color: AppTheme.primaryRed,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'à votre écoute, à votre service',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _selectedIndex == 0
          ? _buildHomeContent()
          : _selectedIndex == 1
              ? AnnouncementScreen()
              : _selectedIndex == 2
                  ? UsefulLinksScreen()
                  : _buildProfileTab(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.primaryRed,
          unselectedItemColor: Colors.grey[500],
          selectedLabelStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 24),
              activeIcon: Icon(Icons.home_rounded, size: 24),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined, size: 24),
              activeIcon: Icon(Icons.campaign_rounded, size: 24),
              label: 'Annonces',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.link_outlined, size: 24),
              activeIcon: Icon(Icons.link_rounded, size: 24),
              label: 'Liens Utiles',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 24),
              activeIcon: Icon(Icons.person_rounded, size: 24),
              label: 'Profil',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToDemandScreen,
        backgroundColor: AppTheme.primaryRed,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Demander',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Color(0xFFF8F9FA)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryRed.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un service...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            padding: EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              color: AppTheme.primaryRed,
              size: 22,
            ),
          ),
          suffixIcon: Container(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.tune_rounded, color: Colors.grey[400], size: 20),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
