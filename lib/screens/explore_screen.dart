import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tourist_spots.dart';
import 'hotel_detail_screen.dart';
import '../services/firestore_service.dart';
import '../models/place.dart';

// ExploreScreen - Travel Package Catalog (Item 4)
//
// FEATURES IMPLEMENTED:
// 1. Search Bar - Search destinations by name or location
// 2. Category Filtering - 8 categories (All, Restaurants, Cheap Eats, Cafes,
//    Attractions, Hotels, Shopping, Nightlife)
// 3. Top Places Section - Horizontal scrolling featured places
// 4. Destination Cards - 12 sample destinations with:
//    - High-quality images, ratings, reviews, prices
//    - Open/Closed status badge
//    - Save/favorite functionality (Firebase integration)
//    - Category badges
// 5. Navigation - Click cards to view details (hotel/restaurant/attraction screens)
//
// DESTINATIONS: Cox's Bazar, Sylhet, Dhaka, Shillong, Malaga, Tokyo, Rome,
//               Bangkok, Egypt, Sydney, Argentina, Morocco
// DESIGN: Dark theme (#0A1628), blue accents, card-based UI

class ExploreScreen extends StatefulWidget {
  final String? initialSearchQuery;
  final String? initialCategory;
  const ExploreScreen({super.key, this.initialSearchQuery, this.initialCategory});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final TextEditingController _searchController;
  final FirestoreService _firestoreService = FirestoreService();
  late String _selectedCategory;
  Set<String> _savedPlaceNames = {};

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
    _searchController = TextEditingController(text: widget.initialSearchQuery);
    _fetchSavedPlaces();
    _checkAndSeedDatabase();
  }

  final List<String> categories = [
    'All',
    'Attractions',
    'Cafes',
    'Cheap Eats',
    'Hotels',
    'Nightlife',
    'Restaurants',
    'Shopping',
  ];

  final List<Map<String, dynamic>> destinations = [
    {
      'name': 'Cox\'s Bazar Beach',
      'location': 'Bangladesh',
      'category': 'Attractions',
      'rating': 4.9,
      'reviews': '1.1k',
      'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400',
      'description': 'World\'s longest natural sea beach with crystal clear water',
      'price': '\$50-100',
      'isOpen': true,
      'duration': 4,
    },
    {
      'name': 'Sylhet Museum Ln',
      'location': 'Sylhet, Bangladesh',
      'category': 'Attractions',
      'rating': 4.5,
      'reviews': '856',
      'image': 'https://images.unsplash.com/photo-1523482580672-f109ba8cb9be?w=400',
      'description': 'Historical museum showcasing local culture and heritage',
      'price': '\$10-25',
      'isOpen': true,
      'duration': 2,
    },
    {
      'name': 'City Hut Family Dhaba',
      'location': 'Dhaka, Bangladesh',
      'category': 'Restaurants',
      'rating': 4.9,
      'reviews': '2.3k',
      'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
      'description': 'Casual dhaba with palm-frond roof and local food',
      'price': '\$15-30',
      'isOpen': true,
      'duration': 1,
    },
    {
      'name': 'Shillong Peak Cafe',
      'location': 'Shillong, India',
      'category': 'Cafes',
      'rating': 4.7,
      'reviews': '945',
      'image': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=400',
      'description': 'Mountain cafe with panoramic views and local coffee',
      'price': '\$8-20',
      'isOpen': false,
      'duration': 1,
    },
    {
      'name': 'Malaga Sunset Resort',
      'location': 'Malaga, Spain',
      'category': 'Hotels',
      'rating': 4.8,
      'reviews': '1.8k',
      'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400',
      'description': 'Luxury resort with Mediterranean views and spa',
      'price': '\$200-400',
      'isOpen': true,
      'duration': 7,
    },
    {
      'name': 'Tokyo Street Food Market',
      'location': 'Tokyo, Japan',
      'category': 'Cheap Eats',
      'rating': 4.6,
      'reviews': '3.2k',
      'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
      'description': 'Authentic street food experience in bustling market',
      'price': '\$5-15',
      'isOpen': true,
      'duration': 3,
    },
    {
      'name': 'Colosseum Tour',
      'location': 'Rome, Italy',
      'category': 'Attractions',
      'rating': 4.8,
      'reviews': '10.5k',
      'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400',
      'description': 'Guided tour of the ancient Roman amphitheater.',
      'price': '40-80',
      'isOpen': true,
      'duration': 1,
    },
    {
      'name': 'Bangkok Night Market Eats',
      'location': 'Bangkok, Thailand',
      'category': 'Restaurants',
      'rating': 4.7,
      'reviews': '4.1k',
      'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400',
      'description': 'Vibrant street food stalls offering authentic Thai cuisine.',
      'price': '5-20',
      'isOpen': true,
      'duration': 2,
    },
    {
      'name': 'The Nile Cruise',
      'location': 'Luxor, Egypt',
      'category': 'Attractions',
      'rating': 4.9,
      'reviews': '3.1k',
      'image': 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=400',
      'description': 'Multi-day cruise viewing ancient temples between Luxor and Aswan.',
      'price': '400-800',
      'isOpen': true,
      'duration': 5,
    },
    {
      'name': 'Sydney Opera House',
      'location': 'Sydney, Australia',
      'category': 'Attractions',
      'rating': 4.8,
      'reviews': '12.2k',
      'image': 'https://images.unsplash.com/photo-1523482580672-f109ba8cb9be?w=400',
      'description': 'Iconic multi-venue performing arts center on Sydney Harbour.',
      'price': '30-70',
      'isOpen': true,
      'duration': 2,
    },
    {
      'name': 'El Calafate Glamping',
      'location': 'Patagonia, Argentina',
      'category': 'Hotels',
      'rating': 4.9,
      'reviews': '990',
      'image': 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=400',
      'description': 'Luxury dome tents with stunning views of the Patagonian ice fields.',
      'price': '250-450',
      'isOpen': true,
      'duration': 6,
    },
    {
      'name': 'Marrakesh Souk',
      'location': 'Marrakesh, Morocco',
      'category': 'Cheap Eats',
      'rating': 4.6,
      'reviews': '5.5k',
      'image': 'https://images.unsplash.com/photo-1523482580672-f109ba8cb9be?w=400',
      'description': 'Bustling market with tagine stalls, spices, and handcrafted goods.',
      'price': '5-25',
      'isOpen': true,
      'duration': 3,
    },
  ];

  double _priceLimit = 500.0;
  int _maxDuration = 10;
  String _sortBy = 'Rating'; // 'Rating', 'Price: Low to High', 'Price: High to Low'


  Future<void> _checkAndSeedDatabase() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('places').get();
      if (snap.docs.isEmpty) {
        debugPrint('Seeding places database...');
        for (var d in destinations) {
          final name = d['name'] as String;
          final placeId = name.toLowerCase().replaceAll(' ', '_');
          final place = Place(
            id: placeId,
            name: name,
            location: d['location'],
            category: d['category'],
            rating: d['rating'],
            reviews: d['reviews'].toString(),
            image: d['image'],
            description: d['description'],
            price: d['price'],
            isOpen: d['isOpen'],
            duration: d['duration'] ?? 3,
          );
          await _firestoreService.savePlace(place);
        }
        debugPrint('Database seeded successfully.');
      }
    } catch (e) {
      debugPrint('Error seeding database: $e');
    }
  }

  Future<void> _fetchSavedPlaces() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await _firestoreService.getUserData(user.uid);
        if (userData != null) {
          setState(() {
            _savedPlaceNames = Set.from(userData['savedPlaces'] ?? []);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching saved places: $e');
    }
  }

  Future<void> _toggleSavePlace(Place place) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to save places'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final placeName = place.name;
      if (_savedPlaceNames.contains(placeName)) {
        await _firestoreService.removePlaceFromUserSavedPlaces(
          user.uid,
          place.id,
        );
        setState(() {
          _savedPlaceNames.remove(placeName);
        });
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
        await _firestoreService.savePlace(place);
        await _firestoreService.addPlaceToUserSavedPlaces(user.uid, place.id);
        setState(() {
          _savedPlaceNames.add(placeName);
        });
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A1628),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Destinations',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _priceLimit = 500.0;
                            _maxDuration = 10;
                            _sortBy = 'Rating';
                          });
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Max Price',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Text(
                        '\$${_priceLimit.round()}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _priceLimit,
                    min: 10,
                    max: 1000,
                    divisions: 99,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.white12,
                    onChanged: (val) {
                      setModalState(() {
                        _priceLimit = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Max Duration (Days)',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Text(
                        '$_maxDuration days',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _maxDuration.toDouble(),
                    min: 1,
                    max: 14,
                    divisions: 13,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.white12,
                    onChanged: (val) {
                      setModalState(() {
                        _maxDuration = val.round();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sort By',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      'Rating',
                      'Price: Low to High',
                      'Price: High to Low',
                    ].map((option) {
                      final isSelected = _sortBy == option;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(option),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                _sortBy = option;
                              });
                            }
                          },
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 12,
                          ),
                          backgroundColor: const Color(0xFF1A2642),
                          selectedColor: Colors.blue[600],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Place> getFilteredAndSortedPlaces(List<Place> allPlaces) {
    var filtered = allPlaces;

    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((p) => p.category == _selectedCategory)
          .toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (p) =>
                p.name.toLowerCase().contains(query) ||
                p.location.toLowerCase().contains(query),
          )
          .toList();
    }

    // Filter by Price Limit
    filtered = filtered.where((p) {
      final priceNum = _extractPrice(p.price);
      return priceNum <= _priceLimit;
    }).toList();

    // Filter by Duration Limit
    filtered = filtered.where((p) => p.duration <= _maxDuration).toList();

    // Sorting
    if (_sortBy == 'Rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'Price: Low to High') {
      filtered.sort(
        (a, b) => _extractPrice(a.price).compareTo(_extractPrice(b.price)),
      );
    } else if (_sortBy == 'Price: High to Low') {
      filtered.sort(
        (a, b) => _extractPrice(b.price).compareTo(_extractPrice(a.price)),
      );
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryTabs(),
            _buildTopPlacesSection(),
            Expanded(child: _buildDestinationsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2642),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What\'s On Your Mind?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Perfect. Grab a deal.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2642),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.favorite_border,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A2642),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search destinations, restaurants...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      child: Icon(
                        Icons.clear,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _showFilterBottomSheet,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.tune,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = category),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue[600]
                        : const Color(0xFF1A2642),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.6),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopPlacesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Places Shillong',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'See all',
                    style: TextStyle(color: Colors.blue[400]),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) {
                final topPlaces = [
                  {
                    'name': 'Cox\'s Bazar Beach',
                    'rating': '4.9',
                    'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=300',
                  },
                  {
                    'name': 'Sylhet Museum Ln',
                    'rating': '4.5',
                    'image': 'https://images.unsplash.com/photo-1523482580672-f109ba8cb9be?w=300',
                  },
                  {
                    'name': 'Shillong Peak',
                    'rating': '4.7',
                    'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300',
                  },
                  {
                    'name': 'Barcelona',
                    'rating': '4.9',
                    'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=300',
                  },
                  {
                    'name': 'Paris',
                    'rating': '4.5',
                    'image': 'https://images.unsplash.com/photo-1523482580672-f109ba8cb9be?w=300',
                  },
                  {
                    'name': 'Istanbul',
                    'rating': '4.7',
                    'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300',
                  },
                ];
                return _buildTopPlaceCard(topPlaces[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPlaceCard(Map<String, String> place) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(place['image']!),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    place['rating']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Text(
              place['name']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationsList() {
    return StreamBuilder<List<Place>>(
      stream: _firestoreService.getPlacesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load destinations',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A Firestore database permission or connection issue occurred.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => _showDetailedErrorPopup(context, 'Database Error', snapshot.error.toString()),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('View Details', style: TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        final allPlaces = snapshot.data ?? [];
        final filtered = getFilteredAndSortedPlaces(allPlaces);

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No destinations found',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return _buildDestinationCard(filtered[index]);
          },
        );
      },
    );
  }

  void _showDetailedErrorPopup(BuildContext context, String title, String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2642),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          error,
          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Dismiss', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(Place destination) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2642),
        borderRadius: BorderRadius.circular(16),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if (destination.category == 'Hotels') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HotelDetailScreen(
                    hotelName: destination.name,
                    location: destination.location,
                    rating: destination.rating,
                    reviews: int.parse(
                      destination.reviews.replaceAll(RegExp(r'[^0-9]'), ''),
                    ),
                    imageUrl: destination.image,
                    price: _extractPrice(destination.price),
                    type: 'hotel',
                    description: destination.description,
                  ),
                ),
              );
            } else if (destination.category == 'Restaurants' ||
                destination.category == 'Cheap Eats') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HotelDetailScreen(
                    hotelName: destination.name,
                    location: destination.location,
                    rating: destination.rating,
                    reviews: int.parse(
                      destination.reviews.replaceAll(RegExp(r'[^0-9]'), ''),
                    ),
                    imageUrl: destination.image,
                    price: _extractPrice(destination.price),
                    type: 'restaurant',
                    description: destination.description,
                  ),
                ),
              );
            } else if (destination.category == 'Cafes') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HotelDetailScreen(
                    hotelName: destination.name,
                    location: destination.location,
                    rating: destination.rating,
                    reviews: int.parse(
                      destination.reviews.replaceAll(RegExp(r'[^0-9]'), ''),
                    ),
                    imageUrl: destination.image,
                    price: _extractPrice(destination.price),
                    type: 'cafe',
                    description: destination.description,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShillongDetailsScreen(
                    destinationName: destination.name,
                    imageUrl: destination.image,
                    location: destination.location,
                    price: _extractPrice(destination.price),
                    category: destination.category,
                  ),
                ),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(destination.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _toggleSavePlace(destination),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _savedPlaceNames.contains(destination.name)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _savedPlaceNames.contains(destination.name)
                                ? Colors.red
                                : Colors.black,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: destination.isOpen ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        destination.isOpen ? 'Open' : 'Closed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            destination.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          destination.price,
                          style: TextStyle(
                            color: Colors.blue[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          destination.location,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.schedule,
                          color: Colors.white54,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${destination.duration} days',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      destination.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              destination.rating.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${destination.reviews} reviews)',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            destination.category,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
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
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Restaurants':
        return Icons.restaurant;
      case 'Cheap Eats':
        return Icons.fastfood;
      case 'Cafes':
        return Icons.local_cafe;
      case 'Attractions':
        return Icons.place;
      case 'Hotels':
        return Icons.hotel;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Nightlife':
        return Icons.nightlife;
      default:
        return Icons.explore;
    }
  }

  double _extractPrice(String priceString) {
    final match = RegExp(r'\d+').firstMatch(priceString);
    if (match != null) {
      return double.parse(match.group(0)!);
    }
    return 50.0; // default price
  }
}
