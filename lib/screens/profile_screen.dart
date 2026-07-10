import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'booking_history_screen.dart';
import 'admin_dashboard_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'saved_places_screen.dart';
import 'help_center_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isAdmin = false;
  Map<String, dynamic>? _firestoreData;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loadingProfile = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (mounted) {
          setState(() {
            _firestoreData = doc.data();
            _isAdmin = doc.data()?['isAdmin'] == true;
            _loadingProfile = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _loadingProfile = false);
      }
    } else {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Resolve display values — prefer Firestore, fall back to Auth
    final displayName = _firestoreData?['displayName'] ??
        _firestoreData?['name'] ??
        user?.displayName ??
        'Traveler';
    final email = user?.email ?? 'No email';
    final phone = _firestoreData?['phone'] ?? '';
    final photoUrl = _firestoreData?['photoUrl'] ?? user?.photoURL ?? '';
    final coverUrl = _firestoreData?['coverUrl'] ?? '';
    final joinedRaw = _firestoreData?['createdAt'] ?? '';
    String joinedFormatted = '';
    try {
      final dt = DateTime.parse(joinedRaw);
      joinedFormatted = 'Member since ${_monthName(dt.month)} ${dt.year}';
    } catch (_) {}
    final firstLetter =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'T';

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2642),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
            ),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()));
              try {
                await FirebaseAuth.instance.currentUser?.reload();
              } catch (_) {}
              _loadProfile();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ─── Hero header (cover + avatar) ───────────────────
                  _buildHeroHeader(
                    displayName: displayName,
                    email: email,
                    phone: phone,
                    photoUrl: photoUrl,
                    coverUrl: coverUrl,
                    joinedFormatted: joinedFormatted,
                    firstLetter: firstLetter,
                    user: user,
                  ),

                  const SizedBox(height: 20),

                  // ─── Menu ────────────────────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildMenuItems(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroHeader({
    required String displayName,
    required String email,
    required String phone,
    required String photoUrl,
    required String coverUrl,
    required String joinedFormatted,
    required String firstLetter,
    required User? user,
  }) {
    return Column(
      children: [
        // ── Cover + Avatar stack ──────────────────────────────────
        SizedBox(
          height: 260,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Cover photo
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2642),
                ),
                child: coverUrl.isNotEmpty
                    ? Image.network(
                        coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _defaultCover(),
                      )
                    : _defaultCover(),
              ),
              // Gradient overlay on cover
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF0A1628).withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
              // Admin badge on cover
              if (_isAdmin)
                Positioned(
                  top: 12,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Admin',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              // Profile avatar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF0A1628), width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 58,
                      backgroundColor: const Color(0xFF1A2642),
                      backgroundImage: photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl.isEmpty
                          ? Text(
                              firstLetter,
                              style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[300]),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Name & email ────────────────────────────────────────
        Text(
          displayName,
          style: const TextStyle(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, color: Colors.white38, size: 14),
            const SizedBox(width: 4),
            Text(
              email,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
        if (phone.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_outlined, color: Colors.white38, size: 14),
              const SizedBox(width: 4),
              Text(
                phone,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ],
        if (joinedFormatted.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Text(
              joinedFormatted,
              style: const TextStyle(
                  color: Colors.blue, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
        ],

        const SizedBox(height: 20),

        // ── Stats row ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .where('userId', isEqualTo: user?.uid ?? '')
                .snapshots(),
            builder: (context, bookingSnap) {
              final docs = bookingSnap.data?.docs ?? [];
              final totalTrips = docs.length;
              final confirmed = docs
                  .where((d) =>
                      (d.data() as Map)['status']?.toString().toLowerCase() ==
                      'confirmed')
                  .length;

              return StreamBuilder<List>(
                stream: FirestoreService()
                    .getUserSavedPlaces(user?.uid ?? '')
                    .map((list) => list),
                builder: (context, savedSnap) {
                  final savedCount = savedSnap.data?.length ?? 0;

                  return Row(
                    children: [
                      Expanded(
                          child: _statCard(
                              '$totalTrips',
                              'Total Trips',
                              Icons.flight_takeoff,
                              Colors.blue,
                              onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const BookingHistoryScreen()),
                                  ))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _statCard(
                              '$confirmed',
                              'Confirmed',
                              Icons.check_circle,
                              Colors.green,
                              onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const BookingHistoryScreen(
                                              statusFilter: 'confirmed',
                                            )),
                                  ))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _statCard(
                              '$savedCount',
                              'Saved',
                              Icons.bookmark,
                              Colors.amber,
                              onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const SavedPlacesScreen()),
                                  ))),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _defaultCover() {
    return Container(
      color: const Color(0xFF0D1B33),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.15,
            child: Image.network(
              'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=800&q=60',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),
          Center(
            child: Icon(Icons.travel_explore,
                color: Colors.white.withValues(alpha: 0.25), size: 60),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    String value,
    String label,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: const Color(0xFF1A2642),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              if (onTap != null) ...[  
                const SizedBox(height: 4),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: color.withValues(alpha: 0.4), size: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    final menuItems = <Map<String, dynamic>>[
      {
        'icon': Icons.luggage_outlined,
        'title': 'My Bookings',
        'subtitle': 'View your trip history',
        'color': Colors.blue,
      },
      {
        'icon': Icons.edit_outlined,
        'title': 'Edit Profile',
        'subtitle': 'Update name, photo & details',
        'color': Colors.purple,
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'Settings',
        'subtitle': 'Notifications, security & more',
        'color': Colors.teal,
      },
      {
        'icon': Icons.help_outline_rounded,
        'title': 'Help Center',
        'subtitle': 'FAQs and support',
        'color': Colors.orange,
      },
      {
        'icon': Icons.info_outline_rounded,
        'title': 'About',
        'subtitle': 'App version and licenses',
        'color': Colors.cyan,
      },
      if (_isAdmin)
        {
          'icon': Icons.admin_panel_settings_outlined,
          'title': 'Admin Dashboard',
          'subtitle': 'Manage bookings & users',
          'color': Colors.amber,
        },
      {
        'icon': Icons.logout_rounded,
        'title': 'Log Out',
        'subtitle': 'Sign out of your account',
        'color': Colors.red,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'ACCOUNT',
            style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1),
          ),
        ),
        ...menuItems.map((item) => _buildMenuItem(
              item['icon'] as IconData,
              item['title'] as String,
              item['subtitle'] as String,
              item['color'] as Color,
            )),
      ],
    );
  }

  Widget _buildMenuItem(
      IconData icon, String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFF1A2642),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            if (title == 'Log Out') {
              _showLogoutDialog(context);
            } else if (title == 'My Bookings') {
              Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const BookingHistoryScreen()));
            } else if (title == 'Admin Dashboard') {
              Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const AdminDashboardScreen()));
            } else if (title == 'Edit Profile') {
              await Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const EditProfileScreen()));
              try {
                await FirebaseAuth.instance.currentUser?.reload();
              } catch (_) {}
              _loadProfile();
            } else if (title == 'Settings') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()));
            } else if (title == 'Help Center') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HelpCenterScreen()));
            } else if (title == 'About') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()));
            }
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withValues(alpha: 0.25),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _monthName(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2642),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                Navigator.of(ctx).pop();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log Out',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
