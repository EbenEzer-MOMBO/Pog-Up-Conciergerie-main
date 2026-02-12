import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Espace vide en haut pour pousser le contenu vers le bas
              const Spacer(),
              // Image
              Container(
                width: double.infinity,
                height: 320, // Taille augmentée
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(
                    'assets/images/get_started.png',
                    fit: BoxFit.contain, // Affiche toute l'image
                  ),
                ),
              ),
              // Contenu textuel et boutons
              Column(
                children: [
                  Text(
                    'Trouvez le service parfait',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      color: AppTheme.anthraciteGray,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Confiez-nous vos tâches du quotidien et profitez d\'une conciergerie moderne à portée de main.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Montserrat',
                      color: AppTheme.mediumGray,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/splash'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Commencer'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/splash'),
                    child: const Text('J\'ai déjà un compte'),
                  ),
                  const SizedBox(height: 40), // Espacement en bas
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
