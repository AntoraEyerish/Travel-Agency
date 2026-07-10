import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// BookingHistoryScreen - Item 8: Booking History for logged-in users
//
// FEATURES:
// - Real-time Firestore stream of the current user's bookings
// - Color-coded status chips (Pending, Confirmed, Cancelled)
// - Cancel option for pending bookings
// - Empty state with illustration

class BookingHistoryScreen extends StatelessWidget {
  final String? statusFilter; // e.g. 'confirmed' — null means show all
  const BookingHistoryScreen({super.key, this.statusFilter});

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

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.hourglass_top;
    }
  }

  Future<void> _cancelBooking(BuildContext context, String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2642),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Booking', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to cancel this booking?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(docId)
            .update({'status': 'Cancelled'});
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking cancelled successfully'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel booking: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A1628),
        body: Center(child: Text('Please log in to view bookings', style: TextStyle(color: Colors.white))),
      );
    }

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
        title: Text(
          statusFilter != null
              ? '${statusFilter![0].toUpperCase()}${statusFilter!.substring(1)} Bookings'
              : 'My Bookings',
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Error loading bookings.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            );
          }

          final allDocs = snapshot.data?.docs ?? [];
          final docs = statusFilter != null
              ? allDocs.where((d) {
                  final s = (d.data() as Map)['status']?.toString().toLowerCase() ?? '';
                  return s == statusFilter!.toLowerCase();
                }).toList()
              : allDocs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2642),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(Icons.luggage, size: 50, color: Colors.blue[300]),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Bookings Yet',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your booked trips will appear here.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            );
          }

          // Sort in-memory to avoid needing a composite index
          final sortedDocs = List<QueryDocumentSnapshot>.from(docs)
            ..sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final aCreated = aData['createdAt'] ?? '';
              final bCreated = bData['createdAt'] ?? '';
              return bCreated.compareTo(aCreated);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              final doc = sortedDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status'] ?? 'Pending';
              final statusColor = _statusColor(status);
              final checkIn = data['checkIn'] ?? '';
              final checkOut = data['checkOut'] ?? '';
              final guests = data['guests'] ?? 1;
              final totalPrice = (data['totalPrice'] ?? 0).toDouble();
              final imageUrl = data['imageUrl'] ?? '';
              final placeName = data['placeName'] ?? 'Unknown Place';
              final location = data['location'] ?? '';
              final createdAt = data['createdAt'] ?? '';
              String formattedDate = '';
              try {
                formattedDate = DateFormat('MMM d, yyyy').format(DateTime.parse(createdAt));
              } catch (_) {}

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2642),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Header image + title
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Stack(
                        children: [
                          imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  height: 140,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 140,
                                    color: const Color(0xFF0D1B33),
                                    child: Icon(Icons.image, color: Colors.white24, size: 48),
                                  ),
                                )
                              : Container(
                                  height: 140,
                                  color: const Color(0xFF0D1B33),
                                  child: Icon(Icons.image, color: Colors.white24, size: 48),
                                ),
                          Container(
                            height: 140,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            right: 12,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    placeName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_statusIcon(status), color: statusColor, size: 13),
                                      const SizedBox(width: 4),
                                      Text(
                                        status,
                                        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Details
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.blue, size: 14),
                              const SizedBox(width: 4),
                              Text(location, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _infoChip(Icons.calendar_today, '$checkIn → $checkOut'),
                              const SizedBox(width: 12),
                              _infoChip(Icons.people, '$guests guest${guests > 1 ? 's' : ''}'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Cost', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                  Text(
                                    '\$${totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (status.toLowerCase() == 'pending')
                                TextButton.icon(
                                  onPressed: () => _cancelBooking(context, doc.id),
                                  icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 18),
                                  label: const Text('Cancel', style: TextStyle(color: Colors.red)),
                                ),
                            ],
                          ),
                          const Divider(color: Colors.white10, height: 20),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 12, color: Colors.white30),
                              const SizedBox(width: 4),
                              Text(
                                'Booked on $formattedDate',
                                style: const TextStyle(color: Colors.white30, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blue, size: 14),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
