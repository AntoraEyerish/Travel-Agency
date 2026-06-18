import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'booking_history_screen.dart';
import 'admin_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          _isAdmin = doc.data()?['isAdmin'] == true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 100,
        ),
        child: Column(
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 30),
            _buildMenuItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    final displayName = user?.displayName ?? 'Traveler';
    final email = user?.email ?? 'No email';
    final photoURL = user?.photoURL;
    final firstLetter = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'T';

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Cover Photo
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2642),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.landscape,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 40,
                ),
              ),
            ),
            // Profile Photo
            Positioned(
              bottom: -50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0A1628),
                      width: 4,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue[100],
                    backgroundImage: (photoURL != null && photoURL.isNotEmpty)
                        ? NetworkImage(photoURL)
                        : null,
                    child: (photoURL == null || photoURL.isEmpty)
                        ? Text(
                            firstLetter,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        Text(
          displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
        ),
        const SizedBox(height: 20),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('bookings')
              .where('userId', isEqualTo: user?.uid ?? '')
              .snapshots(),
          builder: (context, snapshot) {
            final count = snapshot.data?.docs.length ?? 0;
            return Row(
              children: [
                Expanded(child: _buildStatCard(count.toString(), 'Trips', Icons.flight_takeoff)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('0', 'Places', Icons.place)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('0', 'Points', Icons.star)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2642),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.amber, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    final menuItems = [
      {'icon': Icons.luggage, 'title': 'My Bookings'},
      {'icon': Icons.edit, 'title': 'Edit Profile'},
      {'icon': Icons.settings, 'title': 'Settings'},
      {'icon': Icons.help_outline, 'title': 'Help Center'},
      {'icon': Icons.info_outline, 'title': 'About'},
      if (_isAdmin) {'icon': Icons.admin_panel_settings, 'title': 'Admin Dashboard'},
      {'icon': Icons.logout, 'title': 'Log Out'},
    ];

    return Column(
      children: menuItems
          .map(
            (item) => _buildMenuItem(
              item['icon'] as IconData,
              item['title'] as String,
            ),
          )
          .toList(),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          if (title == 'Log Out') {
            _showLogoutDialog(context);
          } else if (title == 'My Bookings') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingHistoryScreen()));
          } else if (title == 'Admin Dashboard') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title feature coming soon!'),
                backgroundColor: Colors.blue[600],
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2642),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.amber, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.4),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2642),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
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
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
