import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/place.dart';
import 'booking_screen.dart';

// HotelDetailScreen - Hotel/Restaurant/Cafe Details (Item 5)
//
// FEATURES IMPLEMENTED:
// - Full-screen image with gradient overlay
// - Tab navigation: Overview, Amenities, Reviews
// - Rating and reviews display
// - Location information with map placeholder
// - Amenities list with icons
// - Price per night/meal display
// - Save/unsave functionality (Firebase)
// - Reservation button (shows "Coming soon" message)
//
// TYPES SUPPORTED: hotel, restaurant, cafe
// DESIGN: Dark theme, tab-based navigation, professional card layout

class HotelDetailScreen extends StatefulWidget {
  final String hotelName;
  final String location;
  final double rating;
  final int reviews;
  final String? imageUrl;
  final double? price;
  final String? description;
  final String? type; // 'hotel', 'restaurant', 'cafe'
  final List<Map<String, dynamic>>? amenities;

  const HotelDetailScreen({
    super.key,
    required this.hotelName,
    required this.location,
    required this.rating,
    required this.reviews,
    this.imageUrl,
    this.price,
    this.description,
    this.type = 'hotel',
    this.amenities,
  });

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSaved = false;
  String _placeId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
    _placeId = widget.hotelName.toLowerCase().replaceAll(' ', '_');
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists && mounted) {
        final savedPlaces = List<String>.from(
          userDoc.data()?['savedPlaces'] ?? [],
        );
        setState(() {
          _isSaved = savedPlaces.contains(_placeId);
        });
      }
    }
  }

  Future<void> _toggleSave() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to save places'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      if (_isSaved) {
        await _firestoreService.removePlaceFromUserSavedPlaces(
          user.uid,
          _placeId,
        );
        setState(() => _isSaved = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from saved places'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        final place = Place(
          id: _placeId,
          name: widget.hotelName,
          location: widget.location,
          category: widget.type ?? 'Hotel',
          rating: widget.rating,
          reviews: widget.reviews.toString(),
          image: widget.imageUrl ?? '',
          description: widget.description ?? '',
          price: widget.price?.toString() ?? '',
          isOpen: true,
          duration: 0,
        );
        await _firestoreService.savePlace(place);
        await _firestoreService.addPlaceToUserSavedPlaces(user.uid, _placeId);
        setState(() => _isSaved = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to saved places'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildRating(),
                _buildTabs(),
                if (_selectedTab == 0) _buildOverviewTab(),
                if (_selectedTab == 1) _buildReviewsTab(),
                if (_selectedTab == 2) _buildLocationTab(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: const Color(0xFF0A1628),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isSaved ? Icons.favorite : Icons.favorite_border,
              color: _isSaved ? Colors.red : Colors.white,
            ),
          ),
          onPressed: _toggleSave,
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, color: Colors.white),
          ),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.imageUrl ??
                  'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF1A2642),
                  child: const Center(
                    child: Icon(Icons.image, color: Colors.white54, size: 64),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.hotelName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue, size: 18),
              const SizedBox(width: 4),
              Text(
                widget.location,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRating() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2642),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.rating.toString(),
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < widget.rating.floor()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.reviews} Reviews',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A2642),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.blue[600],
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          labelPadding: EdgeInsets.zero,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Reviews'),
            Tab(text: 'Location'),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.description ??
                '${widget.hotelName} is a ${widget.type == 'restaurant'
                    ? 'fine dining restaurant'
                    : widget.type == 'cafe'
                    ? 'cozy cafe'
                    : 'luxury hotel'} located in ${widget.location}. It offers world-class ${widget.type == 'restaurant' || widget.type == 'cafe' ? 'cuisine and ambiance' : 'amenities and services'} to make your ${widget.type == 'restaurant' || widget.type == 'cafe' ? 'dining experience' : 'stay'} comfortable and memorable.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Amenities',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildAmenities(),
        ],
      ),
    );
  }

  Widget _buildAmenities() {
    // Use custom amenities if provided, otherwise use defaults based on type
    final List<Map<String, dynamic>> amenities =
        widget.amenities ??
        (widget.type == 'restaurant'
            ? [
                {'icon': Icons.restaurant_menu, 'name': 'Fine Dining'},
                {'icon': Icons.wine_bar, 'name': 'Bar'},
                {'icon': Icons.outdoor_grill, 'name': 'Outdoor Seating'},
                {'icon': Icons.local_parking, 'name': 'Parking'},
                {'icon': Icons.wifi, 'name': 'Free WiFi'},
                {'icon': Icons.music_note, 'name': 'Live Music'},
                {'icon': Icons.cake, 'name': 'Desserts'},
                {'icon': Icons.delivery_dining, 'name': 'Delivery'},
              ]
            : widget.type == 'cafe'
            ? [
                {'icon': Icons.coffee, 'name': 'Coffee'},
                {'icon': Icons.bakery_dining, 'name': 'Bakery'},
                {'icon': Icons.wifi, 'name': 'Free WiFi'},
                {'icon': Icons.chair, 'name': 'Cozy Seating'},
                {'icon': Icons.book, 'name': 'Reading Area'},
                {'icon': Icons.ac_unit, 'name': 'AC'},
                {'icon': Icons.local_parking, 'name': 'Parking'},
                {'icon': Icons.takeout_dining, 'name': 'Takeaway'},
              ]
            : [
                {'icon': Icons.wifi, 'name': 'Free WiFi'},
                {'icon': Icons.pool, 'name': 'Swimming Pool'},
                {'icon': Icons.restaurant, 'name': 'Restaurant'},
                {'icon': Icons.local_parking, 'name': 'Free Parking'},
                {'icon': Icons.fitness_center, 'name': 'Gym'},
                {'icon': Icons.spa, 'name': 'Spa'},
                {'icon': Icons.room_service, 'name': 'Room Service'},
                {'icon': Icons.ac_unit, 'name': 'Air Conditioning'},
              ]);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2642),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                amenities[index]['icon'] as IconData,
                color: Colors.blue,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                amenities[index]['name'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 10),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    final reviews = [
      {
        'name': 'Anna Hale',
        'date': '2 days ago',
        'rating': 5.0,
        'comment':
            'Wonderful experience! The staff was very friendly and the room was clean and comfortable.',
        'avatar': 'A',
      },
      {
        'name': 'Rashed Kabir',
        'date': '1 week ago',
        'rating': 4.5,
        'comment':
            'Great location and excellent service. Would definitely recommend to others.',
        'avatar': 'R',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '4.5 (${widget.reviews} Reviews)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('Write review')),
            ],
          ),
          const SizedBox(height: 16),
          ...reviews.map((review) => _buildReviewCard(review)),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'See all reviews',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2642),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  review['avatar'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      review['date'],
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    review['rating'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'],
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2642),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.map, color: Colors.blue, size: 48),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.location,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sylhet, Bangladesh',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2642),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${widget.price?.toStringAsFixed(0) ?? '120'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.type == 'restaurant' || widget.type == 'cafe'
                      ? 'average price'
                      : 'per night',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                  onPressed: () {
                  if (widget.type == 'restaurant' || widget.type == 'cafe') {
                    // Show reservation dialog for restaurants/cafes
                    _showReservationDialog();
                  } else {
                    // Navigate to the booking screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(
                          placeName: widget.hotelName,
                          location: widget.location,
                          imageUrl: widget.imageUrl ??
                              'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
                          pricePerDay: widget.price ?? 120,
                          category: widget.type ?? 'Hotel',
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.type == 'restaurant' || widget.type == 'cafe'
                      ? 'Make Reservation'
                      : 'Book Now',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReservationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2642),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Make a Reservation',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reserve a table at ${widget.hotelName}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 20),
            Text(
              'Call us or book online to secure your spot!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reservation request sent!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
