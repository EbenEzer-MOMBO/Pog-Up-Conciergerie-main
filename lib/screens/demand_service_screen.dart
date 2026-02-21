import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../config/supabase_config.dart';
import 'services/hebergement_detail_screen.dart';
import 'services/livraison_detail_screen.dart';
import 'services/transport_detail_screen.dart';
import '../config/app_theme.dart';
import '../utils/auth_guard.dart';

class DemandServiceScreen extends StatefulWidget {
  const DemandServiceScreen({super.key});

  @override
  State<DemandServiceScreen> createState() => _DemandServiceScreenState();
}

class _DemandServiceScreenState extends State<DemandServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDateTime;

  ServiceCategory? _selectedCategory;
  String? _selectedSubCategory;
  final Map<String, dynamic> _formData = {};
  bool _isLoading = false;
  Map<String, dynamic>? _selectedServiceDetails;
  String? _selectedServiceLabel;
  String? _initialSubCategoryFromArgs;
  bool _routeInitialized = false;
  static const Color _primaryColor = AppTheme.primaryRed;

  // Données spécifiques par catégorie
  final Map<String, List<String>> _subCategories = {
    'transport': ['Transport scolaire', 'Location véhicule', 'VTC', 'Bus'],
    'hebergement': ['Chambre d\'hôte', 'Hôtel', 'Appartement'],
    'livraison': ['Alimentaire', 'Fragile', 'Paquets', 'Documents', 'Tous'],
    'autres': ['Ménage', 'Pressing', 'Aide personnelle', 'Autre'],
  };

  @override
  void initState() {
    super.initState();
    // Vérifier l'authentification dès l'ouverture de l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (SupabaseConfig.currentUser == null) {
        // Fermer cet écran et afficher le prompt de connexion
        Navigator.pop(context);
        AuthGuard.requireAuth(
          context,
          featureName: 'Demander un service',
        );
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _budgetController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  int? _extractMinimumPrice() {
    if (_selectedServiceDetails == null) return null;

    final details = _selectedServiceDetails!;
    final dynamic rawService = details['service'];
    final serviceMap = rawService is Map<String, dynamic> ? rawService : null;

    final priceValue = details.containsKey('prix')
        ? details['prix']
        : serviceMap?['prix_estimatif'];

    if (priceValue == null) return null;

    if (priceValue is int) return priceValue;
    if (priceValue is double) return priceValue.toInt();
    if (priceValue is String) {
      return int.tryParse(priceValue.replaceAll(RegExp(r'[^0-9]'), ''));
    }
    return null;
  }

  void _showCupertinoDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Annuler',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Text(
                    'Sélectionner date et heure',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Valider',
                      style: TextStyle(color: _primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: _selectedDateTime ?? DateTime.now(),
                use24hFormat: true,
                onDateTimeChanged: (date) {
                  setState(() {
                    _selectedDateTime = date;
                    final day = date.day.toString().padLeft(2, '0');
                    final month = date.month.toString().padLeft(2, '0');
                    final year = date.year;
                    final hour = date.hour.toString().padLeft(2, '0');
                    final minute = date.minute.toString().padLeft(2, '0');
                    _dateController.text = "$day/$month/$year $hour:$minute";
                    _formData['horaire'] = _dateController.text;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeInitialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final categoryId = args['categoryId'] as String?;
      final subCategory = args['subCategory'] as String?;
      final serviceLabel = args['serviceLabel'] as String?;
      final serviceDetails = args['serviceDetails'] as Map<String, dynamic>?;
      final description = args['description'] as String?;
      final budgetArg = (args['budget'] ??
              serviceDetails?['budget'] ??
              serviceDetails?['Budget'])
          ?.toString();

      ServiceCategory? category;
      if (categoryId != null) {
        final matching = ServiceCategory.getMainCategories()
            .where((item) => item.id == categoryId)
            .toList();
        if (matching.isNotEmpty) {
          category = matching.first;
        }
      }

      setState(() {
        if (category != null) {
          _selectedCategory = category;
        }
        _selectedSubCategory = subCategory ?? _selectedSubCategory;
        _initialSubCategoryFromArgs = _selectedSubCategory;
        _selectedServiceLabel = serviceLabel;
        _selectedServiceDetails = serviceDetails;
        if (serviceLabel != null && serviceLabel.isNotEmpty) {
          _formData['serviceSelection'] = serviceLabel;
        }
        if (budgetArg != null && budgetArg.isNotEmpty) {
          _budgetController.text = budgetArg;
          _formData['budget'] = budgetArg;
        }
      });

      final descriptionText = description ?? serviceLabel;
      if (descriptionText != null &&
          descriptionText.isNotEmpty &&
          _descriptionController.text.isEmpty) {
        _descriptionController.text = descriptionText;
      }
    }

    _routeInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Demander un Service',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.primaryRed),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategorySelection(),
              SizedBox(height: 24),
              if (_selectedCategory != null) ...[
                _buildSubCategorySelection(),
                if (_selectedServiceLabel != null) ...[
                  SizedBox(height: 16),
                  _buildSelectedServiceSummary(),
                ],
                SizedBox(height: 24),
                _buildSpecificFields(),
                SizedBox(height: 24),
                _buildBudgetField(),
                SizedBox(height: 24),
                _buildDescriptionField(),
                SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de service',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: ServiceCategory.getMainCategories().length,
          itemBuilder: (context, index) {
            final category = ServiceCategory.getMainCategories()[index];
            final isSelected = _selectedCategory?.id == category.id;
            final shouldNavigate = category.id == 'transport' ||
                category.id == 'hebergement' ||
                category.id == 'livraison';

            return GestureDetector(
              onTap: () {
                final bool isSameCategory =
                    _selectedCategory?.id == category.id;
                setState(() {
                  _selectedCategory = category;
                  _selectedSubCategory = null;
                  _formData.clear();
                  if (!isSameCategory) {
                    _selectedServiceDetails = null;
                    _selectedServiceLabel = null;
                    _initialSubCategoryFromArgs = null;
                  }
                });
                if (shouldNavigate) {
                  _navigateToCategoryDetails(category);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? _primaryColor : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? _primaryColor : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 8),
                    Text(
                      category.icon,
                      style: TextStyle(
                        fontSize: 20,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _navigateToCategoryDetails(ServiceCategory category) {
    Widget? screen;
    switch (category.id) {
      case 'transport':
        screen = TransportDetailScreen(category: category);
        break;
      case 'hebergement':
        screen = HebergementDetailScreen(category: category);
        break;
      case 'livraison':
        screen = LivraisonDetailScreen(category: category);
        break;
      default:
        screen = null;
    }

    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
    }
  }

  Widget _buildSubCategorySelection() {
    final subCategories = _subCategories[_selectedCategory!.id] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sous-catégorie',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 12),
        ...subCategories.map((subCategory) {
          final isSelected = _selectedSubCategory == subCategory;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected ? _primaryColor.withValues(alpha: 0.08) : null,
              border: Border.all(
                color: isSelected ? _primaryColor : Colors.grey[300]!,
              ),
            ),
            child: RadioListTile<String>(
              title: Text(
                subCategory,
                style: TextStyle(
                  color: isSelected ? _primaryColor : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              value: subCategory,
              groupValue: _selectedSubCategory,
              activeColor: _primaryColor,
              selected: isSelected,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              onChanged: (value) {
                setState(() {
                  _selectedSubCategory = value;
                  if (_initialSubCategoryFromArgs != null &&
                      value != _initialSubCategoryFromArgs) {
                    _selectedServiceDetails = null;
                    _selectedServiceLabel = null;
                    _formData.remove('serviceSelection');
                    _initialSubCategoryFromArgs = null;
                  }
                  if (value != 'Transport scolaire') {
                    _formData.remove('depart');
                    _formData.remove('arrivee');
                    _formData.remove('nb_enfants');
                  }
                });
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSelectedServiceSummary() {
    if (_selectedServiceLabel == null) {
      return SizedBox.shrink();
    }

    final details = _selectedServiceDetails;
    final dynamic rawService = details != null ? details['service'] : null;
    final serviceMap = rawService is Map<String, dynamic> ? rawService : null;

    final description = _stringValue(serviceMap?['description']) ??
        _stringValue(details?['description']);
    final priceValue = details != null && details.containsKey('prix')
        ? details['prix']
        : serviceMap?['prix_estimatif'];
    final priceText = _formatPriceValue(priceValue);
    final localisation = _stringValue(details?['localisation']) ??
        _stringValue(serviceMap?['localisation']);
    final depart = _stringValue(details?['depart']) ??
        _stringValue(details?['point_depart']);
    final arrivee = _stringValue(details?['arrivee']) ??
        _stringValue(details?['point_arrivee']);
    final horaires =
        _stringValue(details?['horaire']) ?? _stringValue(details?['horaires']);
    final capacity = _stringValue(details?['nb_personnes']) ??
        _stringValue(details?['nb_enfants']) ??
        _stringValue(details?['capacite']);
    final marque = _stringValue(details?['marque']);
    final modele = _stringValue(details?['modele']);
    final optionVtc = _stringValue(details?['option_vtc']);
    final budget = _stringValue(details?['budget']);
    final sousType = _stringValue(details?['sous_type']);
    final typeColis = _stringValue(details?['type_colis']);
    final poids = _stringValue(details?['poids']);
    final instructions = _stringValue(details?['instructions']);

    final List<Widget> infoRows = [];

    void addInfo(IconData icon, String label) {
      infoRows.add(SizedBox(height: infoRows.isEmpty ? 16 : 8));
      infoRows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.grey[600], size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    if (localisation != null) {
      addInfo(Icons.location_on, 'Localisation : $localisation');
    }
    final vehicleParts = <String>[];
    if (marque != null) vehicleParts.add(marque);
    if (modele != null) vehicleParts.add(modele);
    if (vehicleParts.isNotEmpty) {
      addInfo(Icons.directions_car, 'Véhicule : ${vehicleParts.join(' ')}');
    }
    if (optionVtc != null) {
      addInfo(Icons.local_taxi, 'Option : $optionVtc');
    }
    if (budget != null) {
      addInfo(Icons.account_balance_wallet, 'Budget : $budget FCFA');
    }
    if (sousType != null) {
      addInfo(Icons.category, 'Sous-type : ${_formatLabel(sousType)}');
    }
    if (depart != null) {
      addInfo(Icons.flag, 'Départ : $depart');
    }
    if (arrivee != null) {
      addInfo(Icons.place, 'Arrivée : $arrivee');
    }
    if (horaires != null) {
      addInfo(Icons.schedule, 'Horaires : $horaires');
    }
    if (capacity != null) {
      addInfo(Icons.people, 'Capacité : $capacity');
    }
    if (typeColis != null) {
      addInfo(Icons.inventory_2, 'Type de colis : $typeColis');
    }
    if (poids != null) {
      addInfo(Icons.scale, 'Poids : $poids');
    }
    if (instructions != null) {
      addInfo(Icons.note_alt, 'Instructions : $instructions');
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedServiceLabel!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          if (priceText != null) ...[
            SizedBox(height: 8),
            Text(
              'À partir de $priceText FCFA',
              style: TextStyle(
                color: AppTheme.primaryRed,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
          if (description != null) ...[
            SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
          ...infoRows,
        ],
      ),
    );
  }

  String? _stringValue(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  String? _formatPriceValue(dynamic value) {
    if (value == null) return null;
    if (value is num) {
      if (value == value.roundToDouble()) {
        return value.toStringAsFixed(0);
      }
      return value.toStringAsFixed(2);
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      final normalized =
          trimmed.replaceAll(RegExp(r'fcfa', caseSensitive: false), '').trim();
      final sanitized = normalized.replaceAll(' ', '');
      final parsed = num.tryParse(sanitized.replaceAll(',', '.'));
      if (parsed != null) {
        return parsed == parsed.roundToDouble()
            ? parsed.toStringAsFixed(0)
            : parsed.toStringAsFixed(2);
      }
      return trimmed;
    }
    return value.toString();
  }

  String _formatLabel(String value) {
    final parts = value
        .toString()
        .replaceAll('_', ' ')
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              part.substring(0, 1).toUpperCase() +
              part.substring(1).toLowerCase(),
        )
        .toList();
    return parts.isEmpty ? value : parts.join(' ');
  }

  Widget _buildSpecificFields() {
    if (_selectedCategory == null || _selectedSubCategory == null) {
      return SizedBox.shrink();
    }

    switch (_selectedCategory!.id) {
      case 'transport':
        return _buildTransportFields();
      case 'hebergement':
        return _buildHebergementFields();
      case 'livraison':
        return _buildLivraisonFields();
      default:
        return _buildGenericFields();
    }
  }

  Widget _buildTransportFields() {
    final bool isSchoolTransport = _selectedSubCategory == 'Transport scolaire';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détails du transport',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 12),
        if (isSchoolTransport) ...[
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Lieu de départ',
              border: OutlineInputBorder(),
            ),
            onSaved: (value) => _formData['depart'] = value,
            validator: (value) =>
                value?.isEmpty == true ? 'Champ requis' : null,
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Lieu d\'arrivée',
              border: OutlineInputBorder(),
            ),
            onSaved: (value) => _formData['arrivee'] = value,
            validator: (value) =>
                value?.isEmpty == true ? 'Champ requis' : null,
          ),
          SizedBox(height: 16),
        ],
        InkWell(
          onTap: _showCupertinoDatePicker,
          child: IgnorePointer(
            child: TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Date et heure souhaitée',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Champ requis' : null,
            ),
          ),
        ),
        if (isSchoolTransport) ...[
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Nombre d\'enfants',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onSaved: (value) => _formData['nb_enfants'] = value,
          ),
        ],
      ],
    );
  }

  Widget _buildHebergementFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détails de l\'hébergement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 12),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Localisation souhaitée',
            border: OutlineInputBorder(),
          ),
          onSaved: (value) => _formData['localisation'] = value,
          validator: (value) => value?.isEmpty == true ? 'Champ requis' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Nombre de personnes',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _formData['nb_personnes'] = value,
          validator: (value) => value?.isEmpty == true ? 'Champ requis' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Durée du séjour',
            border: OutlineInputBorder(),
          ),
          onSaved: (value) => _formData['duree'] = value,
          validator: (value) => value?.isEmpty == true ? 'Champ requis' : null,
        ),
      ],
    );
  }

  Widget _buildLivraisonFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détails de la livraison',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 12),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Adresse de départ',
            border: OutlineInputBorder(),
          ),
          onSaved: (value) => _formData['adresse_depart'] = value,
          validator: (value) => value?.isEmpty == true ? 'Champ requis' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Adresse d\'arrivée',
            border: OutlineInputBorder(),
          ),
          onSaved: (value) => _formData['adresse_arrivee'] = value,
          validator: (value) => value?.isEmpty == true ? 'Champ requis' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Type de colis',
            border: OutlineInputBorder(),
          ),
          onSaved: (value) => _formData['type_colis'] = value,
          validator: (value) => value?.isEmpty == true ? 'Champ requis' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Poids estimé (kg)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => _formData['poids'] = value,
        ),
      ],
    );
  }

  Widget _buildGenericFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détails du service',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 12),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Type de service spécifique',
            border: OutlineInputBorder(),
          ),
          onSaved: (value) => _formData['type_specifique'] = value,
          validator: (value) => value?.isEmpty == true ? 'Champ requis' : null,
        ),
      ],
    );
  }

  Widget _buildBudgetField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget estimé',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 12),
        TextFormField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Budget disponible (FCFA)',
            border: OutlineInputBorder(),
          ),
          onSaved: (value) => _formData['budget'] = value?.trim(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description détaillée',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Décrivez votre demande en détail...',
            border: OutlineInputBorder(),
          ),
          onSaved: (value) => _formData['description'] = value,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                'Envoyer la demande',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate() ||
        _selectedCategory == null ||
        _selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs requis')),
      );
      return;
    }

    _formKey.currentState!.save();
    if (_selectedCategory?.id != 'transport' ||
        _selectedSubCategory != 'Transport scolaire') {
      _formData.remove('depart');
      _formData.remove('arrivee');
      _formData.remove('nb_enfants');
    }

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        // Ne devrait pas arriver grâce à la garde dans initState,
        // mais on protège le cas limite par sécurité
        setState(() => _isLoading = false);
        if (mounted) {
          Navigator.pop(context);
          AuthGuard.requireAuth(context, featureName: 'Demander un service');
        }
        return;
      }

      if (_selectedServiceLabel != null && _selectedServiceLabel!.isNotEmpty) {
        _formData['serviceSelection'] = _selectedServiceLabel;
      }
      if (_selectedServiceDetails != null &&
          _selectedServiceDetails!.isNotEmpty) {
        _formData['serviceDetails'] = _selectedServiceDetails;
      }
      final budgetValue = _budgetController.text.trim();
      if (budgetValue.isNotEmpty) {
        _formData['budget'] = budgetValue;
      } else {
        _formData.remove('budget');
      }
      if (_selectedCategory!.id == 'livraison' &&
          !_formData.containsKey('sous_type') &&
          _selectedSubCategory != null) {
        _formData['sous_type'] = _selectedSubCategory!.toLowerCase().replaceAll(
              ' ',
              '_',
            );
      }

      // Validation du budget
      final minPrice = _extractMinimumPrice();
      final budgetText = _budgetController.text.trim().replaceAll(
            RegExp(r'[^0-9]'),
            '',
          );
      final userBudgetValue = int.tryParse(budgetText);

      if (minPrice != null &&
          userBudgetValue != null &&
          userBudgetValue < minPrice) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Le budget estimatif ne peut pas être inférieur au prix minimum du service ($minPrice FCFA)',
            ),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      await DatabaseService.createDemande(
        typeService: '${_selectedCategory!.name} - $_selectedSubCategory',
        userId: userId,
        details: _formData,
      );

      _budgetController.clear();
      _descriptionController.clear();
      _dateController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Demande envoyée avec succès. Nous vous répondrons sous 24 heures.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Redirection vers la page des demandes
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/requests');
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
