import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _version = '1.0.0';
  static const String _build   = '2026.06';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2642),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── App logo & version ─────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF246AFE), Color(0xFF1A2EDE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF246AFE).withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.travel_explore,
                        color: Colors.white, size: 54),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'WanderWay',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your smart travel companion',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Version $_version  •  Build $_build',
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Mission ────────────────────────────────────────────────────
          _sectionHeader('OUR MISSION'),
          Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2642),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
            ),
            child: const Text(
              'WanderWay is built to make travel planning effortless and inspiring. '
              'We connect travellers with the world\'s best hotels, restaurants, cafes, '
              'and hidden gems — all in one beautifully designed app. '
              'Whether you\'re planning a weekend getaway or a round-the-world adventure, '
              'WanderWay has you covered.',
              style: TextStyle(
                  color: Colors.white70, fontSize: 14, height: 1.7),
            ),
          ),

          // ── Key features ──────────────────────────────────────────────
          _sectionHeader('KEY FEATURES'),
          _featureRow(Icons.search_rounded, Colors.blue, 'Smart Search',
              'Find places by name, category, or location instantly.'),
          _featureRow(Icons.bookmark_outlined, Colors.amber, 'Save Places',
              'Bookmark your favourite destinations for quick access.'),
          _featureRow(Icons.luggage_outlined, Colors.green, 'Easy Booking',
              'Book hotels, restaurants and more in just a few taps.'),
          _featureRow(Icons.notifications_outlined, Colors.orange, 'Real-time Updates',
              'Get instant notifications when your booking status changes.'),
          _featureRow(Icons.admin_panel_settings_outlined, Colors.purple, 'Admin Tools',
              'Powerful dashboard for managing bookings and users.'),

          const SizedBox(height: 20),

          // ── App info ──────────────────────────────────────────────────
          _sectionHeader('APP INFORMATION'),
          _infoRow('Version', _version),
          _infoRow('Build', _build),
          _infoRow('Platform', 'Flutter (Android, iOS, Web)'),
          _infoRow('Backend', 'Firebase (Auth, Firestore, Storage)'),
          _infoRow('Developer', 'WanderWay Team'),
          _infoRow('Contact', 'support@wanderway.app'),
          _infoRow('Website', 'www.wanderway.app'),

          const SizedBox(height: 20),

          // ── Legal ─────────────────────────────────────────────────────
          _sectionHeader('LEGAL'),
          _legalTile(context, Icons.shield_outlined, Colors.teal,
              'Privacy Policy', _privacyText),
          _legalTile(context, Icons.gavel_outlined, Colors.blue,
              'Terms of Service', _termsText),
          _legalTile(context, Icons.article_outlined, Colors.purple,
              'Open Source Licenses', _licensesText),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Text(
          title,
          style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2),
        ),
      );

  Widget _featureRow(
      IconData icon, Color color, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2642),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2642),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 13))),
          Expanded(
              flex: 3,
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _legalTile(BuildContext context, IconData icon, Color color,
      String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2642),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            color: Colors.white24, size: 14),
        onTap: () => _showLegalDialog(context, title, content),
      ),
    );
  }

  void _showLegalDialog(
      BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2642),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: Text(content,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 13, height: 1.6)),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Legal text ─────────────────────────────────────────────────────────────

  static const String _privacyText = '''
WanderWay Privacy Policy
Last updated: June 2026

1. Information We Collect
We collect information you provide directly to us, such as when you create an account, make a booking, or contact support. This includes your name, email address, phone number, and profile photo.

2. How We Use Your Information
We use the information we collect to:
• Provide, maintain, and improve our services
• Process bookings and send confirmations
• Send notifications and updates (if enabled)
• Respond to your questions and support requests

3. Data Storage
Your data is stored securely using Google Firebase. We do not sell your personal information to third parties.

4. Your Rights
You may access, update, or delete your account data at any time through the app settings. To request full data deletion, contact support@wanderway.app.

5. Contact
For privacy-related questions, contact: privacy@wanderway.app
''';

  static const String _termsText = '''
WanderWay Terms of Service
Last updated: June 2026

1. Acceptance of Terms
By using WanderWay, you agree to these Terms of Service. If you disagree, please do not use the app.

2. Use of Service
You must be at least 18 years old to use this service. You are responsible for maintaining the confidentiality of your account credentials.

3. Bookings
Bookings made through WanderWay are subject to confirmation by our admin team. We reserve the right to cancel bookings that violate our policies.

4. Prohibited Conduct
You agree not to:
• Use the service for any illegal purpose
• Submit false or misleading information
• Attempt to gain unauthorized access to any part of the service

5. Disclaimer
WanderWay is provided "as is". We make no warranties about the accuracy or reliability of the content.

6. Contact
For terms-related questions, contact: legal@wanderway.app
''';

  static const String _licensesText = '''
WanderWay uses the following open-source packages:

Flutter SDK — BSD 3-Clause License
© Google LLC

firebase_auth — Apache 2.0 License
© Google LLC

cloud_firestore — Apache 2.0 License
© Google LLC

firebase_storage — Apache 2.0 License
© Google LLC

image_picker — BSD 3-Clause License
© Flutter Community

shared_preferences — BSD 3-Clause License
© Flutter Community

http — BSD 3-Clause License
© Dart Team

intl — BSD 3-Clause License
© Dart Team

smooth_page_indicator — MIT License
© ANTORA'S TEAM

Full license texts are available at:
https://pub.dev/packages/<package-name>/license
''';
}
