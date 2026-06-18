import 'package:firebase_auth/firebase_auth.dart' as import_firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'explore_screen.dart';
import 'tourist_spots.dart';
import 'hotel_detail_screen.dart';
import '../services/firestore_service.dart';
import '../models/place.dart';

// HomeScreen - Main landing page after login
//
// FEATURES IMPLEMENTED:
// 1. User Profile Header - Shows avatar, welcome message, user name from Firebase
// 2. Welcome Card - Blue gradient card with "Find Your Next Adventure"
//    - Clickable to navigate to Explore Screen (Travel Package Catalog)
// 3. Featured Destinations Section - Showcases 3 popular destinations:
//    - Paris, France (4.8★) - Eiffel Tower image
//    - Tokyo, Japan (4.9★) - Neon city streets
//    - Dubai, UAE (4.7★) - Modern skyline with Burj Khalifa
//    Each card: 200px height, gradient overlay, location pin, amber rating badge
// 4. Bottom Navigation - Home, Notifications, Profile tabs
//
// DESIGN: Dark theme (#061024), blue accents, 20px padding, smooth animations
// NAVIGATION: Home → Explore Screen → Package Details

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061024),
      body: _selectedIndex == 0
          ? SafeArea(child: _buildHomePage())
          : _buildOtherScreens(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildOtherScreens() {
    Widget screen;
    switch (_selectedIndex) {
      case 1:
        screen = const NotificationsScreen();
        break;
      case 2:
        screen = const ProfileScreen();
        break;
      default:
        screen = const SizedBox();
    }
    return SafeArea(bottom: false, child: screen);
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.notifications_outlined, 'Notifications', 1),
              _buildNavItem(Icons.person_outline, 'Profile', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue[400] : Colors.white54,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue[400] : Colors.white54,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A2642),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          textInputAction: TextInputAction.search,
          onSubmitted: (query) {
            if (query.trim().isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExploreScreen(
                    initialSearchQuery: query.trim(),
                  ),
                ),
              );
              _searchController.clear();
            }
          },
          decoration: InputDecoration(
            hintText: 'Search destinations, categories...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.blue[400],
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: (val) {
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final homeCategories = [
      {'name': 'Attractions', 'icon': Icons.place},
      {'name': 'Cafes', 'icon': Icons.local_cafe},
      {'name': 'Hotels', 'icon': Icons.hotel},
      {'name': 'Nightlife', 'icon': Icons.nightlife},
      {'name': 'Restaurants', 'icon': Icons.restaurant},
      {'name': 'Shopping', 'icon': Icons.shopping_bag},
    ];

    return Container(
      height: 46,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: homeCategories.length,
        itemBuilder: (context, index) {
          final category = homeCategories[index];
          final String catName = category['name'] as String;
          final IconData catIcon = category['icon'] as IconData;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExploreScreen(
                      initialCategory: catName,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2642),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(catIcon, size: 16, color: Colors.blue[400]),
                    const SizedBox(width: 8),
                    Text(
                      catName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomePage() {
    final showSearch = _searchController.text.trim().isNotEmpty;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 10),
          _buildSearchBar(),
          if (showSearch) ...[
            _buildSearchResults(),
          ] else ...[
            _buildCategoryFilters(),
            const SizedBox(height: 20),
            _buildWelcomeCard(),
            const SizedBox(height: 30),
            _buildFeaturedDestinations(),
          ],
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final query = _searchController.text.toLowerCase().trim();
    return StreamBuilder<List<Place>>(
      stream: _firestoreService.getPlacesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: Colors.blue)),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2642),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          );
        }

        final allPlaces = snapshot.data ?? [];
        final results = allPlaces.where((place) {
          return place.name.toLowerCase().contains(query) ||
              place.location.toLowerCase().contains(query) ||
              place.category.toLowerCase().contains(query);
        }).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Search Results for "$query"',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    child: const Text('Clear', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (results.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2642),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.white.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'No matching destinations found.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final place = results[index];
                    return _buildSearchResultCard(place);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResultCard(Place place) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2642),
        borderRadius: BorderRadius.circular(16),
      ),
      child: GestureDetector(
        onTap: () {
          if (place.category == 'Hotels') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HotelDetailScreen(
                  hotelName: place.name,
                  location: place.location,
                  rating: place.rating,
                  reviews: int.parse(
                    place.reviews.replaceAll(RegExp(r'[^0-9]'), ''),
                  ),
                  imageUrl: place.image,
                  price: _extractPrice(place.price),
                  type: 'hotel',
                  description: place.description,
                ),
              ),
            );
          } else if (place.category == 'Restaurants' ||
              place.category == 'Cheap Eats') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HotelDetailScreen(
                  hotelName: place.name,
                  location: place.location,
                  rating: place.rating,
                  reviews: int.parse(
                    place.reviews.replaceAll(RegExp(r'[^0-9]'), ''),
                  ),
                  imageUrl: place.image,
                  price: _extractPrice(place.price),
                  type: 'restaurant',
                  description: place.description,
                ),
              ),
            );
          } else if (place.category == 'Cafes') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HotelDetailScreen(
                  hotelName: place.name,
                  location: place.location,
                  rating: place.rating,
                  reviews: int.parse(
                    place.reviews.replaceAll(RegExp(r'[^0-9]'), ''),
                  ),
                  imageUrl: place.image,
                  price: _extractPrice(place.price),
                  type: 'cafe',
                  description: place.description,
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShillongDetailsScreen(
                  destinationName: place.name,
                  imageUrl: place.image,
                  location: place.location,
                  price: _extractPrice(place.price),
                  category: place.category,
                ),
              ),
            );
          }
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                place.image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  color: const Color(0xFF0D1B2A),
                  child: const Icon(Icons.image, color: Colors.white24),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue, size: 13),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place.location,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          place.rating.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          place.price,
                          style: TextStyle(color: Colors.blue[300], fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _extractPrice(String priceString) {
    final match = RegExp(r'\d+').firstMatch(priceString);
    if (match != null) {
      return double.parse(match.group(0)!);
    }
    return 50.0;
  }

  Widget _buildHeader() {
    final currentUser = import_firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String displayName = currentUser.displayName ?? 'Traveler';
        String? photoURL = currentUser.photoURL;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data();
          if (data != null) {
            displayName = data['displayName'] ?? displayName;
            photoURL = data['profilePhoto'] ?? photoURL;
          }
        }

        final firstLetter = displayName.isNotEmpty
            ? displayName[0].toUpperCase()
            : 'T';

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue[700],
                backgroundImage: (photoURL != null && photoURL.isNotEmpty)
                    ? NetworkImage(photoURL)
                    : null,
                child: (photoURL == null || photoURL.isEmpty)
                    ? Text(
                        firstLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.blue[400],
                  size: 24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExploreScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[700]!, Colors.blue[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.travel_explore, color: Colors.white, size: 40),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Find Your Next Adventure',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore amazing destinations around the world',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Featured Destinations Section
  // Displays 3 popular destinations with detailed information
  //
  // DESTINATION 1: PARIS, FRANCE ★4.8
  // - Image: Iconic Eiffel Tower at sunset with Seine River
  // - Description: The City of Light, romantic European capital
  // - Highlights: Eiffel Tower, Louvre Museum, Notre-Dame Cathedral
  // - Best for: Romance, Art & Culture, Fine Dining
  // - Visual: Warm sunset tones, classic Parisian architecture
  //
  // DESTINATION 2: TOKYO, JAPAN ★4.9 (Highest Rated)
  // - Image: Vibrant neon-lit city streets, bustling urban scene
  // - Description: Modern Asian metropolis, blend of tradition & technology
  // - Highlights: Shibuya Crossing, Tokyo Tower, Sensoji Temple
  // - Best for: Technology, Shopping, Street Food, Nightlife
  // - Visual: Colorful neon signs, crowded streets, electric atmosphere
  //
  // DESTINATION 3: DUBAI, UAE ★4.7
  // - Image: Stunning modern skyline with Burj Khalifa at golden hour
  // - Description: Luxury Middle Eastern destination, architectural marvel
  // - Highlights: Burj Khalifa, Palm Jumeirah, Dubai Mall
  // - Best for: Luxury Travel, Shopping, Desert Safari, Modern Architecture
  // - Visual: Golden sunset, futuristic skyscrapers, desert backdrop
  //
  // Card Design: 200px height, gradient overlay, location pin, rating badge
  // Theme: Dark background with amber ratings, 20px border radius
  Widget _buildFeaturedDestinations() {
    final destinations = [
      {
        'name': 'Paris',
        'country': 'France',
        'image':
            'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
        'rating': '4.8',
        'type': 'standard',
      },
      {
        'name': 'Tokyo',
        'country': 'Japan',
        'image':
            'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400',
        'rating': '4.9',
        'type': 'standard',
      },
      {
        'name': 'Dubai',
        'country': 'UAE',
        'image':
            'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=400',
        'rating': '4.7',
        'type': 'standard',
      },
      {
        'name': 'New York',
        'country': 'USA',
        'image':
            'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=400',
        'rating': '4.6',
        'type': 'compact',
      },
      {
        'name': 'London',
        'country': 'UK',
        'image':
            'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=400',
        'rating': '4.7',
        'type': 'compact',
      },
      {
        'name': 'Bali',
        'country': 'Indonesia',
        'image':
            'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400',
        'rating': '4.8',
        'type': 'wide',
      },
      {
        'name': 'Sydney',
        'country': 'Australia',
        'image':
            'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=400',
        'rating': '4.6',
        'type': 'standard',
      },
      {
        'name': 'Rome',
        'country': 'Italy',
        'image':
            'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=400',
        'rating': '4.9',
        'type': 'standard',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured Destinations',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...destinations.map((dest) {
            if (dest['type'] == 'compact') {
              return _buildCompactDestinationCard(dest);
            } else if (dest['type'] == 'wide') {
              return _buildWideDestinationCard(dest);
            } else {
              return _buildDestinationCard(dest);
            }
          }),
        ],
      ),
    );
  }

  // Destination Card Builder
  // Creates individual cards for Featured Destinations
  // Features: Full-width image, gradient overlay (transparent→black 80%)
  // Text: Destination name (24px bold), location with pin icon
  // Rating: Amber badge (top right) with star icon
  // Size: 200px height, 20px border radius, 16px bottom margin
  Widget _buildDestinationCard(Map<String, dynamic> destination) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShillongDetailsScreen(
              destinationName: destination['name']!,
              imageUrl: destination['image']!,
              location: destination['country']!,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(destination['image']!),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                destination['name']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    destination['country']!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          destination['rating']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Compact Card Design - Smaller height with side-by-side layout
  Widget _buildCompactDestinationCard(Map<String, dynamic> destination) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShillongDetailsScreen(
              destinationName: destination['name']!,
              imageUrl: destination['image']!,
              location: destination['country']!,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1A2642),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                destination['image']!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    color: const Color(0xFF0D1B2A),
                    child: const Icon(Icons.image, color: Colors.white54),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      destination['name']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.blue[400],
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          destination['country']!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          destination['rating']!,
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Explore',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Wide Card Design - Horizontal scroll with overlay info
  Widget _buildWideDestinationCard(Map<String, dynamic> destination) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShillongDetailsScreen(
              destinationName: destination['name']!,
              imageUrl: destination['image']!,
              location: destination['country']!,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                destination['image']!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF1A2642),
                    child: const Center(
                      child: Icon(Icons.image, color: Colors.white54, size: 50),
                    ),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      destination['rating']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'TRENDING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    destination['name']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        destination['country']!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
