import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../config/supabase_config.dart';
import '../config/app_theme.dart';

class PartnerRequestScreen extends StatefulWidget {
  const PartnerRequestScreen({super.key});

  @override
  State<PartnerRequestScreen> createState() => _PartnerRequestScreenState();
}

class _PartnerRequestScreenState extends State<PartnerRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomStructureController = TextEditingController();
  final TextEditingController _activiteController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  List<PlatformFile> _selectedFiles = [];

  @override
  void dispose() {
    _nomStructureController.dispose();
    _activiteController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.files;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection des fichiers')),
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

      // Préparer les données de la demande
      final demandeData = {
        'utilisateur_id': userId,
        'type_service': 'Demande de partenariat',
        'statut': 'en_attente',
        'details': {
          'nom_structure': _nomStructureController.text,
          'activite': _activiteController.text,
          'contact': _contactController.text,
          'email': _emailController.text,
          'description': _descriptionController.text,
          'nb_documents': _selectedFiles.length,
        },
        'date_creation': DateTime.now().toIso8601String(),
      };

      // Insérer la demande dans la base de données
      await SupabaseConfig.client.from('demandes').insert(demandeData);

      // TODO: Upload des fichiers vers Supabase Storage
      // Pour l'instant, on stocke juste les métadonnées

      if (!mounted) {
        return;
      }

      _formKey.currentState!.reset();
      _nomStructureController.clear();
      _activiteController.clear();
      _contactController.clear();
      _emailController.clear();
      _descriptionController.clear();
      setState(() => _selectedFiles = []);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Votre demande de partenariat a été enregistrée avec succès. Nous vous répondrons sous 24 heures.',
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
          'Devenir Partenaire',
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
              _buildFormFields(),
              SizedBox(height: 24),
              _buildDocumentsSection(),
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
        color: AppTheme.primaryRed.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.handshake, color: AppTheme.primaryRed, size: 32),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Rejoignez notre réseau de partenaires et développez votre activité avec Pog\'Up!',
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

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations de votre structure',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 12),
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
          controller: _activiteController,
          decoration: InputDecoration(
            labelText: 'Secteur d\'activité *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.work),
          ),
          validator: (value) =>
              value?.isEmpty == true ? 'Champ obligatoire' : null,
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
            labelText: 'Email professionnel *',
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
        SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Présentation de votre activité *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            alignLabelWithHint: true,
          ),
          validator: (value) =>
              value?.isEmpty == true ? 'Champ obligatoire' : null,
        ),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents justificatifs',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Joignez vos documents (Registre de commerce, statuts, etc.)',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _pickFiles,
          icon: Icon(Icons.attach_file),
          label: Text('Ajouter des documents'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryRed,
            side: BorderSide(color: AppTheme.primaryRed),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (_selectedFiles.isNotEmpty) ...[
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedFiles.length} document(s) sélectionné(s):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                ...List.generate(_selectedFiles.length, (index) {
                  final file = _selectedFiles[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.insert_drive_file, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            file.name,
                            style: TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 16),
                          onPressed: () {
                            setState(() {
                              _selectedFiles.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
      ),
    );
  }
}
