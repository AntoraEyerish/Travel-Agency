import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// AdminDashboardScreen - Item 9: Admin Panel
//
// FEATURES:
// - Stats cards: total bookings, revenue, users, pending
// - Full bookings list with status update capability
// - Admin can confirm or cancel any booking
// - Color-coded status badges
// - Real-time Firestore stream

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> get _bookingsStream =>
      FirebaseFirestore.instance.collection('bookings').orderBy('createdAt', descending: true).snapshots();

  Stream<QuerySnapshot> get _usersStream =>
      FirebaseFirestore.instance.collection('users').snapshots();

  Future<void> _updateBookingStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(docId).update({'status': newStatus});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking status updated to $newStatus'),
            backgroundColor: newStatus == 'Confirmed' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update booking status: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

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
          'Admin Dashboard',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Overview & Bookings'),
            Tab(text: 'Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsTab(),
          _buildUsersTab(),
        ],
      ),
    );
  }

  Widget _buildBookingsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _bookingsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        }

        final allDocs = snapshot.data?.docs ?? [];

        int pending = 0, confirmed = 0;
        double totalRevenue = 0;
        for (final doc in allDocs) {
          final d = doc.data() as Map<String, dynamic>;
          final s = (d['status'] ?? 'Pending').toString().toLowerCase();
          if (s == 'pending') { pending++; }
          else if (s == 'confirmed') {
            confirmed++;
            totalRevenue += (d['totalPrice'] ?? 0).toDouble();
          }
        }

        final filteredDocs = _filterStatus == 'All'
            ? allDocs
            : allDocs.where((d) {
                final data = d.data() as Map<String, dynamic>;
                return (data['status'] ?? 'Pending').toString().toLowerCase() ==
                    _filterStatus.toLowerCase();
              }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Stats row ---
              Row(
                children: [
                  _statCard('Total', allDocs.length.toString(), Icons.list_alt, Colors.blue),
                  const SizedBox(width: 10),
                  _statCard('Pending', pending.toString(), Icons.hourglass_top, Colors.orange),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _statCard('Confirmed', confirmed.toString(), Icons.check_circle, Colors.green),
                  const SizedBox(width: 10),
                  _statCard('Revenue', '\$${totalRevenue.toStringAsFixed(0)}', Icons.attach_money, Colors.amber),
                ],
              ),

              const SizedBox(height: 24),

              // --- Filter chips ---
              Row(
                children: [
                  const Text(
                    'Bookings',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ...['All', 'Pending', 'Confirmed', 'Cancelled'].map(
                    (s) => GestureDetector(
                      onTap: () => setState(() => _filterStatus = s),
                      child: Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _filterStatus == s ? Colors.blue : const Color(0xFF1A2642),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            color: _filterStatus == s ? Colors.white : Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (filteredDocs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2642),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'No $_filterStatus bookings',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ),
                )
              else
                ...filteredDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'Pending';
                  final statusColor = _statusColor(status);
                  final placeName = data['placeName'] ?? 'Unknown';
                  final userEmail = data['userEmail'] ?? '';
                  final userName = data['userName'] ?? '';
                  final checkIn = data['checkIn'] ?? '';
                  final checkOut = data['checkOut'] ?? '';
                  final guests = data['guests'] ?? 1;
                  final totalPrice = (data['totalPrice'] ?? 0).toDouble();
                  final createdAt = data['createdAt'] ?? '';
                  String formattedDate = '';
                  try {
                    formattedDate = DateFormat('MMM d, yyyy HH:mm').format(DateTime.parse(createdAt));
                  } catch (_) {}

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2642),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  placeName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.blue, size: 14),
                              const SizedBox(width: 4),
                              Text('$userName ($userEmail)', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _miniChip(Icons.calendar_today, '$checkIn → $checkOut'),
                              const SizedBox(width: 10),
                              _miniChip(Icons.people, '$guests guests'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Action buttons
                              if (status == 'Pending')
                                Row(
                                  children: [
                                    _actionButton('Confirm', Colors.green, () => _updateBookingStatus(doc.id, 'Confirmed')),
                                    const SizedBox(width: 8),
                                    _actionButton('Cancel', Colors.red, () => _updateBookingStatus(doc.id, 'Cancelled')),
                                  ],
                                )
                              else if (status == 'Confirmed')
                                _actionButton('Cancel', Colors.red, () => _updateBookingStatus(doc.id, 'Cancelled')),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(formattedDate, style: const TextStyle(color: Colors.white24, fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Text('No users found', style: TextStyle(color: Colors.white54)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final name = data['name'] ?? data['displayName'] ?? 'Unknown';
            final email = data['email'] ?? '';
            final isAdmin = data['isAdmin'] == true;
            final createdAt = data['createdAt'] ?? '';
            String formattedDate = '';
            try {
              formattedDate = DateFormat('MMM d, yyyy').format(DateTime.parse(createdAt));
            } catch (_) {}

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2642),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.withValues(alpha: 0.2),
                    radius: 22,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              name,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            if (isAdmin) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('Admin', style: TextStyle(color: Colors.amber, fontSize: 10)),
                              ),
                            ],
                          ],
                        ),
                        Text(email, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        if (formattedDate.isNotEmpty)
                          Text('Joined $formattedDate', style: const TextStyle(color: Colors.white30, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2642),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blue, size: 13),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
