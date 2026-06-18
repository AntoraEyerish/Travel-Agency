import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';

// BookingScreen - Item 6: Booking System
//
// FEATURES:
// - Pre-filled user name and email from Firebase Auth
// - Date range picker (check-in / check-out)
// - Guest count selector
// - Special requests text input
// - Dynamic total price calculation
// - Saves booking to Firestore 'bookings' collection
// - Status defaults to 'Pending'

class BookingScreen extends StatefulWidget {
  final String placeName;
  final String location;
  final String imageUrl;
  final double pricePerDay;
  final String category;

  const BookingScreen({
    super.key,
    required this.placeName,
    required this.location,
    required this.imageUrl,
    required this.pricePerDay,
    required this.category,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final _phoneController = TextEditingController();
  final _requestsController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  int _guests = 1;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _requestsController.dispose();
    super.dispose();
  }

  int get _totalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays;
  }

  double get _totalPrice => widget.pricePerDay * _totalDays * _guests;

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF0A1628),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF0A1628),
            ),
            colorScheme: ColorScheme.dark(
              primary: Colors.blue[600]!,
              onPrimary: Colors.white,
              surface: const Color(0xFF1A2642),
              onSurface: Colors.white,
              secondary: Colors.blue[400]!,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your travel dates'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_totalDays <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-out must be after check-in'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await _firestoreService.createBooking({
        'userId': user.uid,
        'userEmail': user.email ?? '',
        'userName': user.displayName ?? 'Guest',
        'phone': _phoneController.text.trim(),
        'placeName': widget.placeName,
        'location': widget.location,
        'imageUrl': widget.imageUrl,
        'category': widget.category,
        'checkIn': DateFormat('yyyy-MM-dd').format(_startDate!),
        'checkOut': DateFormat('yyyy-MM-dd').format(_endDate!),
        'guests': _guests,
        'totalDays': _totalDays,
        'pricePerDay': widget.pricePerDay,
        'totalPrice': _totalPrice,
        'specialRequests': _requestsController.text.trim(),
        'status': 'Pending',
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2642),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your booking for ${widget.placeName} is pending approval. Check "My Bookings" for updates.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Done', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
          'Book Now',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Package Banner ---
            Container(
              height: 180,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                  onError: (_, __) {},
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.placeName,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          widget.location,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const Spacer(),
                        Text(
                          '\$${widget.pricePerDay.toStringAsFixed(0)}/night',
                          style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- Booking Form ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Traveller Details'),
                    const SizedBox(height: 12),

                    // Name (read-only from auth)
                    _infoCard(Icons.person, 'Name', user?.displayName ?? 'Guest'),
                    const SizedBox(height: 10),
                    _infoCard(Icons.email, 'Email', user?.email ?? ''),
                    const SizedBox(height: 10),

                    // Phone
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: '+1 234 567 8900',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone is required' : null,
                    ),

                    const SizedBox(height: 24),
                    _sectionLabel('Travel Dates'),
                    const SizedBox(height: 12),

                    // Date Range
                    GestureDetector(
                      onTap: _pickDateRange,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2642),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Colors.blue, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _startDate != null && _endDate != null
                                        ? '${DateFormat('MMM dd, yyyy').format(_startDate!)}  →  ${DateFormat('MMM dd, yyyy').format(_endDate!)}'
                                        : 'Select travel dates',
                                    style: TextStyle(
                                      color: _startDate != null ? Colors.white : Colors.white54,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (_totalDays > 0) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_totalDays night${_totalDays > 1 ? 's' : ''}',
                                      style: TextStyle(color: Colors.blue[300], fontSize: 12),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.white54),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    _sectionLabel('Number of Guests'),
                    const SizedBox(height: 12),

                    // Guests counter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2642),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people, color: Colors.blue),
                          const SizedBox(width: 12),
                          const Text('Guests', style: TextStyle(color: Colors.white, fontSize: 16)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () { if (_guests > 1) setState(() => _guests--); },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _guests > 1 ? Colors.blue[600] : Colors.white12,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.remove, color: Colors.white, size: 18),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '$_guests',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          GestureDetector(
                            onTap: () { if (_guests < 10) setState(() => _guests++); },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.blue[600],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    _sectionLabel('Special Requests (Optional)'),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _requestsController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Any special requirements or notes...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF1A2642),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // --- Price Summary ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2642),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          _priceLine('Price per night', '\$${widget.pricePerDay.toStringAsFixed(0)}'),
                          const SizedBox(height: 8),
                          _priceLine('Nights', '$_totalDays'),
                          const SizedBox(height: 8),
                          _priceLine('Guests', '$_guests'),
                          const Divider(color: Colors.white12, height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(
                                '\$${_totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.blue[300], fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          disabledBackgroundColor: Colors.blue.withValues(alpha: 0.4),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                          shadowColor: Colors.blue.withValues(alpha: 0.3),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Confirm Booking',
                                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
      );

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2642),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(icon, color: Colors.blue, size: 20),
        filled: true,
        fillColor: const Color(0xFF1A2642),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.5)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _priceLine(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      );
}
