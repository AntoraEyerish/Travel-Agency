import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/place.dart';
import 'booking_screen.dart';

// ShillongDetailsScreen - Tourist Attraction Details (Item 5)
//
// FEATURES IMPLEMENTED:
// - Full-screen destination image
// - Tab navigation: Overview, Gallery, Reviews, Map
// - Destination description and information
// - Photo gallery section
// - User reviews display
// - Location map placeholder
// - Save/unsave functionality (Firebase)
// - Share button
//
// DESIGN: Dark theme, immersive images, tab-based content organization
// FIREBASE: Integrates with places collection and user savedPlaces

class ShillongDetailsScreen extends StatefulWidget {
  final String destinationName;
  final String imageUrl;
  final String? location;
  final double? price;
  final String? category;

  const ShillongDetailsScreen({
    super.key,
    required this.destinationName,
    required this.imageUrl,
    this.location,
    this.price,
    this.category,
  });

  @override
  State<ShillongDetailsScreen> createState() => _ShillongDetailsScreenState();
}

class _ShillongDetailsScreenState extends State<ShillongDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSaved = false;
  bool _isLoading = false;
  DestinationDetails? _destinationDetails;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkIfSaved();
    _loadDestinationDetails();
  }

  void _loadDestinationDetails() {
    final key = widget.destinationName.toLowerCase();
    _destinationDetails = destinationDetailsData[key];
  }

  Future<void> _checkIfSaved() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userData = await _firestoreService.getUserData(user.uid);
        if (userData != null && mounted) {
          final placeId = widget.destinationName.toLowerCase().replaceAll(
            ' ',
            '_',
          );
          final savedPlaces = List<String>.from(userData['savedPlaces'] ?? []);
          setState(() {
            _isSaved = savedPlaces.contains(placeId);
          });
        }
      } catch (e) {
        debugPrint('Error checking saved status: $e');
      }
    }
  }

  Future<void> _toggleSave() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to save places'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final placeId = widget.destinationName.toLowerCase().replaceAll(' ', '_');

      if (_isSaved) {
        await _firestoreService.removePlaceFromUserSavedPlaces(
          user.uid,
          placeId,
        );
        if (mounted) {
          setState(() => _isSaved = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.destinationName} removed from saved'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Save the place to Firestore
        final place = Place(
          id: placeId,
          name: widget.destinationName,
          location: widget.location ?? 'Unknown',
          image: widget.imageUrl,
          rating: 4.5,
          reviews: '1k',
          category: 'Destination',
          description: '',
          price: '',
          isOpen: true,
          duration: 0,
        );
        await _firestoreService.savePlace(place);
        await _firestoreService.addPlaceToUserSavedPlaces(user.uid, placeId);
        if (mounted) {
          setState(() => _isSaved = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.destinationName} saved!'),
              backgroundColor: Colors.green,
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(),
                _buildTabBar(),
                _buildTabContent(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
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
                    '\$${(widget.price ?? 150.0).toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'per person',
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(
                          placeName: widget.destinationName,
                          location: widget.location ?? 'India',
                          imageUrl: widget.imageUrl,
                          pricePerDay: widget.price ?? 150.0,
                          category: widget.category ?? 'Attractions',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Book Package',
                    style: TextStyle(
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
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF0A1628),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _isLoading ? null : _toggleSave,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : Icon(
                    _isSaved ? Icons.favorite : Icons.favorite_border,
                    color: _isSaved ? Colors.red : Colors.black,
                    size: 20,
                  ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF1A2642),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0A1628).withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue, size: 20),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${widget.destinationName}, ${widget.location ?? 'India'}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.destinationName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(Icons.calendar_today, 'Plan your trip'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip(Icons.wb_sunny, '8:00 am - 11:00 pm'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2642),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.amber, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
        indicatorPadding: EdgeInsets.symmetric(horizontal: 4.0),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Details'),
          Tab(text: 'Review'),
          Tab(text: 'Location'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 600,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildDetailsTab(),
          _buildReviewTab(),
          _buildLocationTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final details = _destinationDetails;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            details?.overview ??
                'Discover the beauty of ${widget.destinationName}, a magnificent destination that offers breathtaking landscapes, rich culture, and unforgettable experiences.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
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
            details?.description ??
                'Experience the local culture, stunning natural beauty, and warm hospitality. This destination offers a perfect blend of adventure and relaxation for travelers of all kinds.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Gallery Photos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: details?.galleryImages.length ?? 5,
              itemBuilder: (context, index) {
                final images =
                    details?.galleryImages ??
                    [
                      'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400',
                      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
                      'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=400',
                      'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=400',
                      'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400',
                    ];
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF1A2642),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF1A2642),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            Icons.restaurant,
            'Dining Style',
            details?.additionalInfo['Dining Style'] ?? 'Local & International',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.fastfood,
            'Cuisine',
            details?.additionalInfo['Cuisine'] ?? 'Traditional & Modern',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.checkroom,
            'Dress Code',
            details?.additionalInfo['Dress Code'] ?? 'Casual',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.access_time,
            'Best Time',
            details?.additionalInfo['Best Time'] ?? 'All Year Round',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab() {
    final details = _destinationDetails;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Travel Information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            'Best Season',
            details?.travelInfo['Best Season'] ?? 'October to March',
          ),
          const SizedBox(height: 12),
          _buildDetailCard(
            'Language',
            details?.travelInfo['Language'] ?? 'English, Local dialects',
          ),
          const SizedBox(height: 12),
          _buildDetailCard(
            'Currency',
            details?.travelInfo['Currency'] ?? 'Dollars, GBP, Euros',
          ),
          const SizedBox(height: 12),
          _buildDetailCard(
            'Transportation',
            details?.travelInfo['Transportation'] ??
                'Taxi, Bus, Metro, Train, Boat',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2642),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              content,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTab() {
    final details = _destinationDetails;
    final rating = details?.rating ?? 4.9;
    final reviews = details?.reviews ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (index) =>
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on ${reviews.length * 78} reviews',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (reviews.isNotEmpty)
            ...reviews.map(
              (review) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildReviewItem(
                  name: review.name,
                  date: review.date,
                  rating: review.rating,
                  comment: review.comment,
                ),
              ),
            )
          else ...[
            _buildReviewItem(
              name: 'John Doe',
              date: '2 days ago',
              rating: 5,
              comment:
                  'Amazing place! The scenery is breathtaking and the local culture is fascinating.',
            ),
            const SizedBox(height: 16),
            _buildReviewItem(
              name: 'Sarah Smith',
              date: '1 week ago',
              rating: 4,
              comment:
                  'Great experience overall. Would definitely recommend visiting.',
            ),
            const SizedBox(height: 16),
            _buildReviewItem(
              name: 'Mike Johnson',
              date: '2 weeks ago',
              rating: 5,
              comment:
                  'Perfect destination for a peaceful getaway. Loved every moment!',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewItem({
    required String name,
    required String date,
    required int rating,
    required String comment,
  }) {
    return Container(
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
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  rating,
                  (index) =>
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2642),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map, color: Colors.blue, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Map View',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Open in Maps',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${widget.destinationName}, ${widget.location ?? 'India'}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.directions, color: Colors.amber, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Get directions to ${widget.destinationName}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Destination Details Data Classes
class DestinationDetails {
  final String name;
  final String location;
  final String country;
  final double rating;
  final String imageUrl;
  final String description;
  final String overview;
  final List<String> galleryImages;
  final Map<String, String> travelInfo;
  final Map<String, String> additionalInfo;
  final List<Review> reviews;

  DestinationDetails({
    required this.name,
    required this.location,
    required this.country,
    required this.rating,
    required this.imageUrl,
    required this.description,
    required this.overview,
    required this.galleryImages,
    required this.travelInfo,
    required this.additionalInfo,
    required this.reviews,
  });
}

class Review {
  final String name;
  final String date;
  final int rating;
  final String comment;

  Review({
    required this.name,
    required this.date,
    required this.rating,
    required this.comment,
  });
}

final Map<String, DestinationDetails> destinationDetailsData = {
  'paris': DestinationDetails(
    name: 'Paris',
    location: 'France',
    country: 'France',
    rating: 4.8,
    imageUrl:
        'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800',
    description:
        'The City of Light, known for its art, fashion, gastronomy, and culture.',
    overview:
        'Discover the beauty of Paris, a magnificent destination that offers breathtaking architecture, world-class museums, iconic landmarks like the Eiffel Tower, and unforgettable culinary experiences. Experience the romantic atmosphere, stunning boulevards, and rich cultural heritage that makes Paris one of the most visited cities in the world.',
    galleryImages: [
      'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
      'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=400',
      'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?w=400',
      'https://images.unsplash.com/photo-1431274172761-fca41d930114?w=400',
      'https://images.unsplash.com/photo-1549144511-f099e773c147?w=400',
    ],
    travelInfo: {
      'Best Season': 'April to June, September to October',
      'Language': 'French, English',
      'Currency': 'Euro (EUR)',
      'Transportation': 'Metro, Bus, Taxi, Bike, Train',
    },
    additionalInfo: {
      'Dining Style': 'French Cuisine & International',
      'Cuisine': 'Pastries, Wine, Cheese, Fine Dining',
      'Dress Code': 'Smart Casual',
      'Best Time': 'Spring and Fall',
    },
    reviews: [
      Review(
        name: 'Emma Wilson',
        date: '1 week ago',
        rating: 5,
        comment:
            'Paris is absolutely magical! The Eiffel Tower at night is breathtaking, and the food is incredible. A must-visit destination!',
      ),
      Review(
        name: 'James Brown',
        date: '2 weeks ago',
        rating: 5,
        comment:
            'The art museums, especially the Louvre, are world-class. Walking along the Seine is romantic and beautiful.',
      ),
      Review(
        name: 'Sophie Martin',
        date: '3 weeks ago',
        rating: 4,
        comment:
            'Beautiful city with amazing architecture. Can be crowded during peak season but still worth every moment.',
      ),
    ],
  ),
  'tokyo': DestinationDetails(
    name: 'Tokyo',
    location: 'Japan',
    country: 'Japan',
    rating: 4.9,
    imageUrl:
        'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800',
    description:
        'A vibrant metropolis blending ultramodern and traditional, from neon-lit skyscrapers to historic temples.',
    overview:
        'Discover the beauty of Tokyo, a magnificent destination that offers breathtaking contrasts between ancient traditions and cutting-edge technology. Experience the bustling streets of Shibuya, serene temples, world-class cuisine, and the unique blend of old and new that makes Tokyo one of the most fascinating cities on Earth.',
    galleryImages: [
      'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400',
      'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=400',
      'https://images.unsplash.com/photo-1542051841857-5f90071e7989?w=400',
      'https://images.unsplash.com/photo-1513407030348-c983a97b98d8?w=400',
      'https://images.unsplash.com/photo-1492571350019-22de08371fd3?w=400',
    ],
    travelInfo: {
      'Best Season': 'March to May, September to November',
      'Language': 'Japanese, English in tourist areas',
      'Currency': 'Japanese Yen (JPY)',
      'Transportation': 'Metro, Train, Bus, Taxi, Shinkansen',
    },
    additionalInfo: {
      'Dining Style': 'Japanese & International Fusion',
      'Cuisine': 'Sushi, Ramen, Tempura, Street Food',
      'Dress Code': 'Casual to Smart Casual',
      'Best Time': 'Cherry Blossom Season (Spring)',
    },
    reviews: [
      Review(
        name: 'David Chen',
        date: '3 days ago',
        rating: 5,
        comment:
            'Tokyo exceeded all expectations! The food is phenomenal, the people are incredibly polite, and there is so much to see and do.',
      ),
      Review(
        name: 'Lisa Anderson',
        date: '1 week ago',
        rating: 5,
        comment:
            'An amazing blend of tradition and modernity. The temples are peaceful, and the city energy is electric. Loved every minute!',
      ),
      Review(
        name: 'Kenji Tanaka',
        date: '2 weeks ago',
        rating: 5,
        comment:
            'As a local, I can say Tokyo never gets old. Every neighborhood has its own character and charm. Perfect for all travelers.',
      ),
    ],
  ),
  'dubai': DestinationDetails(
    name: 'Dubai',
    location: 'UAE',
    country: 'United Arab Emirates',
    rating: 4.7,
    imageUrl:
        'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800',
    description:
        'A futuristic city in the desert, known for luxury shopping, ultramodern architecture, and vibrant nightlife.',
    overview:
        'Discover the beauty of Dubai, a magnificent destination that offers breathtaking skyscrapers, luxurious resorts, world-class shopping, and unforgettable desert experiences. Experience the opulence of the Burj Khalifa, traditional souks, pristine beaches, and the perfect blend of Arabian heritage and modern innovation.',
    galleryImages: [
      'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=400',
      'https://images.unsplash.com/photo-1518684079-3c830dcef090?w=400',
      'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400',
      'https://images.unsplash.com/photo-1582672060674-bc2bd808a8b5?w=400',
      'https://images.unsplash.com/photo-1546412414-e1885259563a?w=400',
    ],
    travelInfo: {
      'Best Season': 'November to March',
      'Language': 'Arabic, English widely spoken',
      'Currency': 'UAE Dirham (AED)',
      'Transportation': 'Metro, Taxi, Bus, Tram, Water Taxi',
    },
    additionalInfo: {
      'Dining Style': 'International & Middle Eastern',
      'Cuisine': 'Arabic, Indian, Asian, European',
      'Dress Code': 'Modest in public, Smart Casual',
      'Best Time': 'Winter months (cooler weather)',
    },
    reviews: [
      Review(
        name: 'Mohammed Al-Rashid',
        date: '4 days ago',
        rating: 5,
        comment:
            'Dubai is a city like no other! The Burj Khalifa views are stunning, and the shopping is world-class. Highly recommend!',
      ),
      Review(
        name: 'Rachel Green',
        date: '1 week ago',
        rating: 4,
        comment:
            'Luxurious and modern with great attractions. The desert safari was a highlight. Can be expensive but worth it.',
      ),
      Review(
        name: 'Ahmed Hassan',
        date: '2 weeks ago',
        rating: 5,
        comment:
            'Perfect blend of tradition and modernity. The gold souk and spice markets are amazing. Great hospitality everywhere!',
      ),
    ],
  ),
  'new york': DestinationDetails(
    name: 'New York',
    location: 'USA',
    country: 'United States',
    rating: 4.6,
    imageUrl:
        'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=800',
    description:
        'The city that never sleeps, a global hub of culture, finance, and entertainment.',
    overview:
        'Discover the beauty of New York, a magnificent destination that offers breathtaking skyline views, world-famous landmarks like the Statue of Liberty and Times Square, diverse neighborhoods, and unforgettable cultural experiences. Experience the energy of Manhattan, the charm of Brooklyn, and the endless possibilities that make NYC truly unique.',
    galleryImages: [
      'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=400',
      'https://images.unsplash.com/photo-1485871981521-5b1fd3805eee?w=400',
      'https://images.unsplash.com/photo-1522083165195-3424ed129620?w=400',
      'https://images.unsplash.com/photo-1518391846015-55a9cc003b25?w=400',
      'https://images.unsplash.com/photo-1534430480872-3498386e7856?w=400',
    ],
    travelInfo: {
      'Best Season': 'April to June, September to November',
      'Language': 'English, Spanish',
      'Currency': 'US Dollar (USD)',
      'Transportation': 'Subway, Bus, Taxi, Ferry, Bike',
    },
    additionalInfo: {
      'Dining Style': 'Global Cuisine & Fine Dining',
      'Cuisine': 'Pizza, Bagels, International Food',
      'Dress Code': 'Casual to Business Casual',
      'Best Time': 'Spring and Fall',
    },
    reviews: [
      Review(
        name: 'Jennifer Lopez',
        date: '5 days ago',
        rating: 5,
        comment:
            'NYC is incredible! So much to see and do. Broadway shows, amazing food, and the energy is unmatched. A must-visit!',
      ),
      Review(
        name: 'Michael Scott',
        date: '1 week ago',
        rating: 4,
        comment:
            'Great city with iconic landmarks. Central Park is beautiful. Can be overwhelming but that\'s part of the charm.',
      ),
      Review(
        name: 'Sarah Johnson',
        date: '2 weeks ago',
        rating: 5,
        comment:
            'The diversity and culture here is amazing. Every neighborhood feels like a different world. Loved exploring!',
      ),
    ],
  ),
  'london': DestinationDetails(
    name: 'London',
    location: 'UK',
    country: 'United Kingdom',
    rating: 4.7,
    imageUrl:
        'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800',
    description:
        'A historic capital blending royal heritage with modern innovation and multicultural vibrancy.',
    overview:
        'Discover the beauty of London, a magnificent destination that offers breathtaking historic landmarks, world-class museums, royal palaces, and unforgettable experiences. Experience the grandeur of Buckingham Palace, the history of the Tower of London, and the vibrant culture that makes London one of the world\'s greatest cities.',
    galleryImages: [
      'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=400',
      'https://images.unsplash.com/photo-1505761671935-60b3a7427bad?w=400',
      'https://images.unsplash.com/photo-1486299267070-83823f5448dd?w=400',
      'https://images.unsplash.com/photo-1529655683826-aba9b3e77383?w=400',
      'https://images.unsplash.com/photo-1533929736458-ca588d08c8be?w=400',
    ],
    travelInfo: {
      'Best Season': 'May to September',
      'Language': 'English',
      'Currency': 'British Pound (GBP)',
      'Transportation': 'Tube, Bus, Taxi, Train, River Bus',
    },
    additionalInfo: {
      'Dining Style': 'British & International',
      'Cuisine': 'Fish & Chips, Afternoon Tea, Curry',
      'Dress Code': 'Smart Casual',
      'Best Time': 'Late Spring to Early Fall',
    },
    reviews: [
      Review(
        name: 'Oliver Smith',
        date: '3 days ago',
        rating: 5,
        comment:
            'London is fantastic! The history, the museums, the parks - everything is world-class. The tube makes getting around easy.',
      ),
      Review(
        name: 'Emily Watson',
        date: '1 week ago',
        rating: 4,
        comment:
            'Beautiful city with so much to offer. The architecture is stunning and there\'s always something happening.',
      ),
      Review(
        name: 'James Bond',
        date: '2 weeks ago',
        rating: 5,
        comment:
            'My favorite city in the world. Perfect blend of tradition and modernity. The theater scene is unbeatable!',
      ),
    ],
  ),
  'bali': DestinationDetails(
    name: 'Bali',
    location: 'Indonesia',
    country: 'Indonesia',
    rating: 4.8,
    imageUrl:
        'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800',
    description:
        'A tropical paradise known for stunning beaches, lush rice terraces, and spiritual culture.',
    overview:
        'Discover the beauty of Bali, a magnificent destination that offers breathtaking beaches, ancient temples, lush jungles, and unforgettable spiritual experiences. Experience the tranquility of Ubud, the surf culture of Canggu, and the warm hospitality that makes Bali the Island of the Gods.',
    galleryImages: [
      'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400',
      'https://images.unsplash.com/photo-1555400038-63f5ba517a47?w=400',
      'https://images.unsplash.com/photo-1559628376-f3fe5f782a2e?w=400',
      'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?w=400',
      'https://images.unsplash.com/photo-1604999333679-b86d54738315?w=400',
    ],
    travelInfo: {
      'Best Season': 'April to October',
      'Language': 'Indonesian, Balinese, English',
      'Currency': 'Indonesian Rupiah (IDR)',
      'Transportation': 'Scooter, Taxi, Private Driver, Boat',
    },
    additionalInfo: {
      'Dining Style': 'Indonesian & International',
      'Cuisine': 'Nasi Goreng, Satay, Fresh Seafood',
      'Dress Code': 'Casual Beach Wear',
      'Best Time': 'Dry Season (May-September)',
    },
    reviews: [
      Review(
        name: 'Ketut Wijaya',
        date: '2 days ago',
        rating: 5,
        comment:
            'Bali is paradise! The beaches are stunning, the people are friendly, and the culture is rich. Perfect for relaxation and adventure.',
      ),
      Review(
        name: 'Amanda Lee',
        date: '1 week ago',
        rating: 5,
        comment:
            'Absolutely loved Bali! The rice terraces in Ubud are breathtaking. Great yoga retreats and amazing food everywhere.',
      ),
      Review(
        name: 'Jake Thompson',
        date: '2 weeks ago',
        rating: 4,
        comment:
            'Beautiful island with great surf spots. Can get touristy in some areas but still worth visiting. The sunsets are incredible!',
      ),
    ],
  ),
  'sydney': DestinationDetails(
    name: 'Sydney',
    location: 'Australia',
    country: 'Australia',
    rating: 4.6,
    imageUrl:
        'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=800',
    description:
        'A vibrant harbor city famous for its Opera House, beaches, and outdoor lifestyle.',
    overview:
        'Discover the beauty of Sydney, a magnificent destination that offers breathtaking harbor views, iconic landmarks, pristine beaches, and unforgettable outdoor experiences. Experience the architectural marvel of the Opera House, the excitement of Bondi Beach, and the laid-back Australian lifestyle.',
    galleryImages: [
      'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=400',
      'https://images.unsplash.com/photo-1523059623039-a9ed027e7fad?w=400',
      'https://images.unsplash.com/photo-1549180030-48bf079fb38a?w=400',
      'https://images.unsplash.com/photo-1524293368946-d820b5a0e2d7?w=400',
      'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=400',
    ],
    travelInfo: {
      'Best Season': 'September to November, March to May',
      'Language': 'English',
      'Currency': 'Australian Dollar (AUD)',
      'Transportation': 'Train, Bus, Ferry, Light Rail, Taxi',
    },
    additionalInfo: {
      'Dining Style': 'Modern Australian & Asian Fusion',
      'Cuisine': 'Seafood, BBQ, Multicultural Food',
      'Dress Code': 'Casual Beach Style',
      'Best Time': 'Spring and Autumn',
    },
    reviews: [
      Review(
        name: 'Chris Hemsworth',
        date: '4 days ago',
        rating: 5,
        comment:
            'Sydney is amazing! The harbor is beautiful, beaches are world-class, and the food scene is incredible. Love this city!',
      ),
      Review(
        name: 'Nicole Kidman',
        date: '1 week ago',
        rating: 4,
        comment:
            'Beautiful city with great weather. The Opera House is stunning and there are so many great coastal walks.',
      ),
      Review(
        name: 'Hugh Jackman',
        date: '2 weeks ago',
        rating: 5,
        comment:
            'My hometown! Sydney has it all - beaches, culture, food, and the friendliest people. A must-visit destination!',
      ),
    ],
  ),
  'rome': DestinationDetails(
    name: 'Rome',
    location: 'Italy',
    country: 'Italy',
    rating: 4.9,
    imageUrl: 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800',
    description:
        'The Eternal City, a living museum of ancient history, art, and Italian culture.',
    overview:
        'Discover the beauty of Rome, a magnificent destination that offers breathtaking ancient ruins, Renaissance art, world-famous cuisine, and unforgettable historical experiences. Experience the grandeur of the Colosseum, the beauty of the Vatican, and the timeless charm that makes Rome eternal.',
    galleryImages: [
      'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=400',
      'https://images.unsplash.com/photo-1531572753322-ad063cecc140?w=400',
      'https://images.unsplash.com/photo-1525874684015-58379d421a52?w=400',
      'https://images.unsplash.com/photo-1529260830199-42c24126f198?w=400',
      'https://images.unsplash.com/photo-1515542622106-78bda8ba0e5b?w=400',
    ],
    travelInfo: {
      'Best Season': 'April to June, September to October',
      'Language': 'Italian, English in tourist areas',
      'Currency': 'Euro (EUR)',
      'Transportation': 'Metro, Bus, Tram, Taxi, Walking',
    },
    additionalInfo: {
      'Dining Style': 'Traditional Italian',
      'Cuisine': 'Pasta, Pizza, Gelato, Wine',
      'Dress Code': 'Smart Casual',
      'Best Time': 'Spring and Fall',
    },
    reviews: [
      Review(
        name: 'Marco Rossi',
        date: '3 days ago',
        rating: 5,
        comment:
            'Rome is magnificent! Every corner has history. The Colosseum is breathtaking and the food is the best in the world!',
      ),
      Review(
        name: 'Isabella Ferrari',
        date: '1 week ago',
        rating: 5,
        comment:
            'Absolutely stunning city! The art, the architecture, the atmosphere - everything is perfect. Don\'t miss the Trevi Fountain!',
      ),
      Review(
        name: 'Antonio Banderas',
        date: '2 weeks ago',
        rating: 5,
        comment:
            'Rome is a masterpiece! Walking through the ancient streets feels like traveling back in time. The Vatican is incredible!',
      ),
    ],
  ),
};
