import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../config/supabase_config.dart';
import '../config/app_theme.dart';

class AnnouncementRequestScreen extends StatefulWidget {
  const AnnouncementRequestScreen({super.key});

  @override
  State<AnnouncementRequestScreen> createState() =>
      _AnnouncementRequestScreenState();
}

class _AnnouncementRequestScreenState extends State<AnnouncementRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomStructureController = TextEditingController();
  final TextEditingController _titreAnnonceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _lienController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nomStructureController.dispose();
    _titreAnnonceController.dispose();
    _descriptionController.dispose();
    _lienController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection de l\'image')),
      );
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Préparer les données de l'annonce
      final annonceData = {
        'utilisateur_id': userId,
        'titre': _titreAnnonceController.text,
        'description': _descriptionController.text,
        'lien': _lienController.text.isNotEmpty ? _lienController.text : null,
        'statut_validation': 'en_attente',
        'date_publication': DateTime.now().toIso8601String(),
      };

      // Insérer l'annonce dans la base de données
      final response = await SupabaseConfig.client
          .from('annonces')
          .insert(annonceData)
          .select()
          .single();

      final annonceId = response['id'];

      // TODO: Upload de l'image vers Supabase Storage si une image est sélectionnée
      // Pour l'instant, on stocke juste les métadonnées

      // Créer aussi une demande pour le suivi
      await SupabaseConfig.client.from('demandes').insert({
        'utilisateur_id': userId,
        'type_service': 'Demande d\'annonce',
        'statut': 'en_attente',
        'details': {
          'nom_structure': _nomStructureController.text,
          'titre_annonce': _titreAnnonceController.text,
          'contact': _contactController.text,
          'email': _emailController.text,
          'annonce_id': annonceId,
        },
        'date_creation': DateTime.now().toIso8601String(),
      });

      if (!mounted) {
        return;
      }

      _formKey.currentState!.reset();
      _nomStructureController.clear();
      _titreAnnonceController.clear();
      _descriptionController.clear();
      _lienController.clear();
      _contactController.clear();
      _emailController.clear();
      setState(() => _selectedImage = null);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Votre annonce a été enregistrée et sera vérifiée par notre équipe. Nous vous répondrons sous 24 heures.',
          ),
          backgroundColor: Colors.green,
        ),
      );
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Créer une Annonce',
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
              _buildInfoCard(),
              SizedBox(height: 24),
              _buildImageSection(),
              SizedBox(height: 24),
              _buildFormFields(),
              SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryRed.withValues(alpha: 0.1),
            AppTheme.primaryRed.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.campaign, color: AppTheme.primaryRed, size: 32),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Partagez votre annonce avec la communauté Pog\'Up!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image/Logo de l\'annonce',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 16),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 2),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Touchez pour ajouter une image',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations de l\'annonce',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _nomStructureController,
          decoration: InputDecoration(
            labelText: 'Nom de la structure *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.business),
          ),
          validator: (value) =>
              value?.isEmpty == true ? 'Champ obligatoire' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _titreAnnonceController,
          decoration: InputDecoration(
            labelText: 'Titre de l\'annonce *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.title),
          ),
          validator: (value) =>
              value?.isEmpty == true ? 'Champ obligatoire' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Description *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            alignLabelWithHint: true,
          ),
          validator: (value) =>
              value?.isEmpty == true ? 'Champ obligatoire' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _lienController,
          decoration: InputDecoration(
            labelText: 'Lien (site web, page Facebook, etc.)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.link),
          ),
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _contactController,
          decoration: InputDecoration(
            labelText: 'Contact téléphonique *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) =>
              value?.isEmpty == true ? 'Champ obligatoire' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty == true) return 'Champ obligatoire';
            if (!value!.contains('@')) return 'Email invalide';
            return null;
          },
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
                'Soumettre l\'annonce',
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
}
