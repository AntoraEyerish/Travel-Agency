import 'package:flutter/material.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _expandedIndex = -1;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // FAQ data
  final List<Map<String, String>> _faqs = [
    {
      'q': 'How do I make a booking?',
      'a':
          'Browse destinations on the Home or Explore tab, open a place you like, then tap "Book Now". Fill in your travel dates, select the number of guests, and confirm. Your booking will appear immediately in My Bookings.',
    },
    {
      'q': 'Can I cancel a booking?',
      'a':
          'Yes — you can cancel any booking that has a Pending status. Go to My Bookings, find the booking, and tap "Cancel Booking". Once a booking is Confirmed by an admin it can no longer be cancelled through the app; please contact support.',
    },
    {
      'q': 'How do I save a place to favourites?',
      'a':
          'Open any place detail page and tap the bookmark icon in the top-right corner. The icon will turn amber to confirm it is saved. Access all saved places from your Profile > Saved card.',
    },
    {
      'q': 'How do I update my profile photo?',
      'a':
          'Go to Profile > Edit Profile (or tap the edit icon in the AppBar). Choose one of the preset travel avatars or paste a custom image URL into the "Profile Image URL" field, then tap Save Changes.',
    },
    {
      'q': 'I forgot my password. What should I do?',
      'a':
          'Tap "Forgot Password?" on the Login screen. Enter your email address and we will send a reset link. Alternatively, go to Profile > Settings > Change Password to receive a reset email while logged in.',
    },
    {
      'q': 'How do I delete my account?',
      'a':
          'Go to Profile > Settings > Delete Account. You will be asked to confirm your current password before the account is permanently deleted. All your data including bookings, saved places, and profile will be removed.',
    },
    {
      'q': 'Why is my booking still showing as Pending?',
      'a':
          'Bookings are reviewed by our admin team. Once reviewed your status will change to Confirmed or a follow-up will be sent. This typically takes up to 24 hours. Make sure your notifications are enabled in Settings.',
    },
    {
      'q': 'How do I contact support?',
      'a':
          'You can reach our support team at support@wanderway.app or use the Contact Support button below. We respond within 24 hours on business days.',
    },
  ];

  final List<Map<String, dynamic>> _topics = [
    {'icon': Icons.flight_takeoff, 'label': 'Bookings', 'color': Colors.blue},
    {'icon': Icons.bookmark, 'label': 'Saved Places', 'color': Colors.amber},
    {'icon': Icons.account_circle_outlined, 'label': 'Account', 'color': Colors.purple},
    {'icon': Icons.payment_outlined, 'label': 'Payments', 'color': Colors.green},
    {'icon': Icons.notifications_outlined, 'label': 'Notifications', 'color': Colors.orange},
    {'icon': Icons.lock_outline, 'label': 'Security', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filtered => _searchQuery.isEmpty
      ? _faqs
      : _faqs
          .where((f) =>
              f['q']!.toLowerCase().contains(_searchQuery) ||
              f['a']!.toLowerCase().contains(_searchQuery))
          .toList();

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
          'Help Center',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.white38,
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'FAQs'),
            Tab(text: 'Contact Us'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFaqTab(), _buildContactTab()],
      ),
    );
  }

  // ── FAQ Tab ────────────────────────────────────────────────────────────────
  Widget _buildFaqTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Hero banner
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How can we help you?',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Search our FAQs or browse by topic',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.support_agent, color: Colors.white70, size: 48),
            ],
          ),
        ),

        // Search bar
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2642),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search FAQs…',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white38),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white38, size: 18),
                      onPressed: () => _searchCtrl.clear(),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),

        // Topic chips (only shown when not searching)
        if (_searchQuery.isEmpty) ...[
          const Text(
            'BROWSE BY TOPIC',
            style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _topics.map((t) {
              return GestureDetector(
                onTap: () {
                  _searchCtrl.text = t['label'];
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        (t['color'] as Color).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: (t['color'] as Color)
                            .withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(t['icon'] as IconData,
                          color: t['color'] as Color, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        t['label'] as String,
                        style: TextStyle(
                            color: t['color'] as Color,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],

        // FAQ list
        const Text(
          'FREQUENTLY ASKED QUESTIONS',
          style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1),
        ),
        const SizedBox(height: 10),

        if (_filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.search_off, color: Colors.white24, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'No results for "$_searchQuery"',
                    style: const TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

        ..._filtered.asMap().entries.map((e) {
          final i = e.key;
          final faq = e.value;
          final isOpen = _expandedIndex == i;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2642),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOpen
                    ? Colors.blue.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(
                      () => _expandedIndex = isOpen ? -1 : i),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text('Q',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                faq['q']!,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Icon(
                              isOpen
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: Colors.white38,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                      if (isOpen) ...[
                        Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text('A',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  faq['a']!,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      height: 1.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Contact Tab ────────────────────────────────────────────────────────────
  Widget _buildContactTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF1A2642), Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Icon(Icons.support_agent, color: Colors.blue, size: 56),
              SizedBox(height: 12),
              Text(
                'We\'re here to help',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Our support team typically responds\nwithin 24 hours on business days.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),

        _contactCard(
          icon: Icons.email_outlined,
          color: Colors.blue,
          title: 'Email Support',
          subtitle: 'support@wanderway.app',
          caption: 'Response time: 24 hours',
        ),
        _contactCard(
          icon: Icons.chat_bubble_outline_rounded,
          color: Colors.green,
          title: 'Live Chat',
          subtitle: 'Chat with a support agent',
          caption: 'Available Mon–Fri, 9am–6pm',
        ),
        _contactCard(
          icon: Icons.phone_outlined,
          color: Colors.orange,
          title: 'Phone Support',
          subtitle: '+880 1700-000000',
          caption: 'Available Mon–Fri, 9am–5pm',
        ),
        _contactCard(
          icon: Icons.language_outlined,
          color: Colors.purple,
          title: 'Help Portal',
          subtitle: 'help.wanderway.app',
          caption: 'Browse guides & tutorials',
        ),

        const SizedBox(height: 24),
        const Text(
          'SEND A MESSAGE',
          style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1),
        ),
        const SizedBox(height: 12),
        _buildContactForm(),
      ],
    );
  }

  Widget _contactCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String caption,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2642),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        const TextStyle(color: Colors.blue, fontSize: 13)),
                const SizedBox(height: 2),
                Text(caption,
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white24, size: 14),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    final nameCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2642),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _formField('Your Name', nameCtrl, Icons.person_outline),
          const SizedBox(height: 12),
          _formField('Describe your issue…', messageCtrl,
              Icons.message_outlined,
              maxLines: 4),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        '✅ Message sent! We\'ll get back to you within 24h.'),
                    backgroundColor: Colors.green,
                  ),
                );
                nameCtrl.clear();
                messageCtrl.clear();
              },
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Send Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formField(String hint, TextEditingController ctrl, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF0A1628),
        prefixIcon: maxLines == 1
            ? Icon(icon, color: Colors.white38, size: 20)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
