import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:lottie/lottie.dart';
import '../config/app_theme.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  static const String _whatsappChannelUrl =
      'https://whatsapp.com/channel/0029Vaw7oLo89innP0dCdk0l';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/whatsapp.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryRed.withValues(alpha: 0.1),
                        AppTheme.goldYellow.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    Icons.campaign_outlined,
                    size: 88,
                    color: AppTheme.primaryRed.withValues(alpha: 0.5),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            Text(
              'Suivez nos actualités, bons plans et événements en rejoignant la chaîne officielle Pog\'Up sur WhatsApp.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Montserrat',
                    color: AppTheme.mediumGray,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 36),
            _buildWhatsappButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsappButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRed.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _openWhatsappChannel,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Rejoindre la chaîne WhatsApp',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsappChannel() async {
    final bool launched = await launchUrlString(
      _whatsappChannelUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir la chaîne WhatsApp.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
