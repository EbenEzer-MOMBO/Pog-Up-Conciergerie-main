import 'package:flutter/material.dart';
import '../services/services.dart';
import '../models/models.dart';
import '../widgets/custom_date_picker.dart';
import '../config/app_theme.dart';
import 'package:country_picker/country_picker.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;
  bool _isEditing = false;

  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  Country _selectedCountry = Country.parse('GA'); // Gabon par défaut

  String? _selectedGenre;
  DateTime? _selectedDate;

  final List<String> _genres = ['Homme', 'Femme', 'Autre'];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await AuthService.getCurrentUserProfile();
      if (user != null) {
        setState(() {
          _user = user;
          _contactController.text = user.contact;
          _emailController.text = user.email;
          _selectedGenre = user.genre;
          _selectedDate = user.dateNaissance != null
              ? DateTime.parse(user.dateNaissance!)
              : null;
          // TODO: Extract country from contact or set default
        });
      }
    } catch (e) {
      print('Erreur lors du chargement du profil: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_user != null) {
      await AuthService.updateUserProfile(
        profileData: {
          'contact': _contactController.text.trim(),
          'email': _emailController.text.trim(),
          'date_naissance': _selectedDate?.toIso8601String().split('T')[0],
          'genre': _selectedGenre,
        },
        onSuccess: (updatedProfile) {
          if (mounted) {
            setState(() {
              _user = updatedProfile;
              _isEditing = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profil mis à jour avec succès !'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        onError: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur: $error'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (context) => CustomDatePickerDialog(
        initialDate: _selectedDate ?? DateTime(2000),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        title: 'Modifier votre date de naissance',
      ),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _logout() async {
    if (!mounted) {
      return;
    }

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Déconnexion',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
            ),
            child: Text(
              'Déconnexion',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      // Capturer les références nécessaires avant l'opération asynchrone
      final navigator = Navigator.of(context, rootNavigator: true);

      // Utiliser un Completer pour gérer la déconnexion de manière synchrone
      String? errorMessage;

      await AuthService.signOut(
        onSuccess: () {
          // succès silencieux
        },
        onError: (error) {
          errorMessage = error;
        },
      );

      // Vérifier si le widget est toujours monté avant d'utiliser le contexte
      if (!mounted) {
        return;
      }

      if (errorMessage != null) {
        // Afficher l'erreur si nécessaire
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion: $errorMessage'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // Navigation vers la page de connexion
        navigator.pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Profil',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppTheme.primaryRed),
        ),
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryRed),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Profil',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppTheme.primaryRed),
        ),
        body: Center(child: Text('Erreur lors du chargement du profil')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mon Profil',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.primaryRed),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            )
          else ...[
            IconButton(
              icon: Icon(Icons.check, color: Colors.green),
              onPressed: _updateProfile,
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.orange),
              onPressed: () => setState(() => _isEditing = false),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(),
            SizedBox(height: 32),
            _isEditing ? _buildEditForm() : _buildProfileInfo(),
            SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppTheme.primaryRed.withValues(alpha: 0.1),
          child: Icon(
            Icons.person,
            size: 30,
            color: AppTheme.primaryRed,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _user!.email,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF2C3E50),
                ),
              ),
              SizedBox(height: 4),
              Text(
                _user!.contact.isNotEmpty
                    ? _user!.contact
                    : 'Téléphone non renseigné',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        _buildInfoItem('Email', _user!.email, Icons.email_outlined),
        SizedBox(height: 16),
        _buildInfoItem('Téléphone', _user!.contact, Icons.phone_outlined),
        SizedBox(height: 16),
        _buildInfoItem(
          'Date de naissance',
          _selectedDate != null
              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
              : 'Non renseignée',
          Icons.calendar_today_outlined,
        ),
        SizedBox(height: 16),
        _buildInfoItem(
            'Genre', _selectedGenre ?? 'Non renseigné', Icons.person_outlined),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryRed, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildContactField(),
          SizedBox(height: 16),
          _buildFormField(
            'Email',
            _emailController,
            Icons.email_outlined,
            enabled: false,
          ),
          SizedBox(height: 16),
          _buildDateField(),
          SizedBox(height: 16),
          _buildGenreField(),
        ],
      ),
    );
  }

  Widget _buildContactField() {
    return Row(
      children: [
        // Sélecteur de pays
        InkWell(
          onTap: () {
            showCountryPicker(
              context: context,
              countryListTheme: CountryListThemeData(
                backgroundColor: Colors.white,
                searchTextStyle: const TextStyle(fontSize: 16),
                inputDecoration: InputDecoration(
                  labelText: 'Rechercher un pays',
                  hintText: 'Rechercher...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              onSelect: (Country country) {
                setState(() {
                  _selectedCountry = country;
                });
              },
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Text(
                  _selectedCountry.flagEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '+${_selectedCountry.phoneCode}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Champ de téléphone
        Expanded(
          child: TextFormField(
            controller: _contactController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Numéro de téléphone',
              hintText: '74 00 12 00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppTheme.primaryRed, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veuillez saisir votre numéro de téléphone';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryRed),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryRed, width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est requis';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    final bool hasValue = _selectedDate != null;

    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? AppTheme.primaryRed.withValues(alpha: 0.3)
                : Colors.grey[300]!,
            width: hasValue ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: hasValue ? AppTheme.primaryRed : Colors.grey[600],
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date de naissance',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    hasValue
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Sélectionner une date',
                    style: TextStyle(
                      color: hasValue ? Color(0xFF2C3E50) : Colors.grey[600],
                      fontSize: 14,
                      fontWeight:
                          hasValue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hasValue ? Icons.check_circle : Icons.arrow_drop_down,
              color: hasValue ? AppTheme.primaryRed : Colors.grey[500],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreField() {
    return DropdownButtonFormField<String>(
      value: _selectedGenre,
      decoration: InputDecoration(
        labelText: 'Genre',
        prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryRed),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryRed, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      items: _genres
          .map(
            (genre) => DropdownMenuItem(
              value: genre,
              child: Text(
                genre,
                style: TextStyle(fontSize: 16),
              ),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedGenre = value),
      style: TextStyle(
        color: Color(0xFF2C3E50),
        fontSize: 16,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(Icons.logout, color: Colors.white),
            label: Text(
              'Se déconnecter',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _logout,
          ),
        ),
      ],
    );
  }
}
