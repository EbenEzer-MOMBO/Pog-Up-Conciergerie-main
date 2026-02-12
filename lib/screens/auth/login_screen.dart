// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth_service.dart';
import '../../config/app_theme.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _acceptedConditions = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildGoogleSignInButton(),
                  const SizedBox(height: 12),
                  _buildAppleSignInButton(),
                  const SizedBox(height: 24),
                  _buildConditionsCheckbox(),
                ],
              ),
            ),
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
            width: 150,
            height: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Titre
        Text('Bienvenue !', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'Connectez-vous pour continuer',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
        ),
        const SizedBox(height: 24),
        Lottie.asset(
          'assets/animations/hello.json',
          width: 180,
          height: 180,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  Widget _buildConditionsCheckbox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _acceptedConditions
                    ? AppTheme.primaryRed
                    : Colors.grey[400]!,
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  setState(() {
                    _acceptedConditions = !_acceptedConditions;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _acceptedConditions
                        ? AppTheme.primaryRed
                        : Colors.transparent,
                  ),
                  child: _acceptedConditions
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontFamily: 'Montserrat',
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'J\'ai lu et j\'accepte la '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => _launchUrl(
                        'https://pogup-conciergerie.com/privacy_policy.html',
                      ),
                      child: Text(
                        'politique de confidentialité',
                        style: TextStyle(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: ' et les '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => _launchUrl(
                        'https://pogup-conciergerie.com/terms_of_use.html',
                      ),
                      child: Text(
                        'conditions d\'utilisation',
                        style: TextStyle(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'ouvrir le lien'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  Widget _buildGoogleSignInButton() {
    final bool isButtonEnabled = _acceptedConditions && !_isLoading;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isButtonEnabled ? AppTheme.white : AppTheme.lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isButtonEnabled ? Colors.grey[300]! : Colors.grey[200]!,
        ),
        boxShadow: isButtonEnabled
            ? [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isButtonEnabled ? _loginWithGoogle : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Image.asset(
                  'assets/images/google.png',
                  fit: BoxFit.contain,
                  color: isButtonEnabled ? null : Colors.grey[400],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Continuer avec Google',
                style: TextStyle(
                  color: isButtonEnabled
                      ? AppTheme.anthraciteGray
                      : Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
              if (_isLoading) ...[
                const SizedBox(width: 12),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryRed,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppleSignInButton() {
    final bool isButtonEnabled = _acceptedConditions && !_isLoading;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isButtonEnabled ? Colors.black : AppTheme.lightGray,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isButtonEnabled
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isButtonEnabled ? _loginWithApple : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Image.asset(
                  'assets/images/apple.png',
                  fit: BoxFit.contain,
                  color: isButtonEnabled ? Colors.white : Colors.grey[400],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Continuer avec Apple',
                style: TextStyle(
                  color: isButtonEnabled ? Colors.white : Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loginWithApple() async {
    setState(() => _isLoading = true);

    try {
      await AuthService.signInWithApple(
        onSuccess: (userProfile) {
          if (mounted) {
            if (userProfile.emailConfirmed && userProfile.isProfileComplete()) {
              Navigator.pushReplacement(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: const HomeScreen(),
                ),
              );
            } else {
              Navigator.pushReplacementNamed(
                context,
                '/profile-completion',
                arguments: {
                  'email': userProfile.email,
                  'googleDisplayName': userProfile.displayName,
                },
              );
            }
          }
        },
        onError: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur Apple Sign-In: $error'),
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await AuthService.signInWithGoogle(
        onSuccess: (userProfile) {
          if (mounted) {
            // Vérifier l'état d'authentification
            if (userProfile.emailConfirmed && userProfile.isProfileComplete()) {
              // Utilisateur complètement authentifié
              Navigator.pushReplacement(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: const HomeScreen(),
                ),
              );
            } else if (!userProfile.emailConfirmed) {
              // Email non confirmé - rediriger vers confirmation
              Navigator.pushReplacementNamed(
                context,
                '/email-confirmation',
                arguments: {'email': userProfile.email},
              );
            } else {
              // Profil incomplet - rediriger vers complétion
              Navigator.pushReplacementNamed(
                context,
                '/profile-completion',
                arguments: {
                  'email': userProfile.email,
                  'googleDisplayName': userProfile.displayName,
                },
              );
            }
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
