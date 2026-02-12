import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../../services/auth_service.dart';
import '../../widgets/modern_widgets.dart';
import '../../widgets/custom_date_picker.dart';
import '../../config/app_theme.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final String email;
  final String? googleDisplayName;

  const ProfileCompletionScreen({
    super.key,
    required this.email,
    this.googleDisplayName,
  });

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  Country _selectedCountry = Country.parse('GA'); // Gabon par défaut

  String? _selectedGenre;
  DateTime? _selectedDate;
  bool _isLoading = false;

  final List<String> _genres = ['Homme', 'Femme', 'Autre'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    await AuthService.updateUserProfile(
      profileData: {
        'contact': _contactController.text.trim(),
        'date_naissance': _selectedDate?.toIso8601String().split('T')[0],
        'genre': _selectedGenre,
      },
      onSuccess: (updatedProfile) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
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

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (context) => CustomDatePickerDialog(
        initialDate: _selectedDate ?? DateTime(2000),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        title: 'Date de naissance',
      ),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildProfileForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo Pog'Up
        Hero(
          tag: 'logo',
          child: SizedBox(
            width: 120,
            height: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Titre
        Text(
          'Bienvenue !',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Quelques informations pour personnaliser votre expérience',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGray,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildContactField(),
          const SizedBox(height: 20),
          _buildDateField(),
          const SizedBox(height: 20),
          _buildGenreField(),
          const SizedBox(height: 30),
          _buildCompleteButton(),
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
                    borderRadius: BorderRadius.circular(12),
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

  Widget _buildDateField() {
    final bool hasValue = _selectedDate != null;

    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
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
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasValue)
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
                        : 'Date de naissance',
                    style: TextStyle(
                      color:
                          hasValue ? AppTheme.anthraciteGray : Colors.grey[600],
                      fontSize: hasValue ? 14 : 16,
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
              size: 22,
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
        prefixIcon:
            const Icon(Icons.person_outline, color: AppTheme.primaryRed),
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
          borderSide: const BorderSide(color: AppTheme.primaryRed, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      items: _genres
          .map(
            (genre) => DropdownMenuItem(
              value: genre,
              child: Text(
                genre,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedGenre = value),
      style: const TextStyle(
        color: Color(0xFF2C3E50),
        fontSize: 16,
      ),
    );
  }

  Widget _buildCompleteButton() {
    return ModernButton(
      text: 'Compléter le profil',
      onPressed: _isLoading ? null : _completeProfile,
      isLoading: _isLoading,
      icon: Icons.check_circle,
      height: 56,
    );
  }
}
