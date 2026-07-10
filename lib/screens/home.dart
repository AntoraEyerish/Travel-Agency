import 'package:firebase_auth/firebase_auth.dart' as import_firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'explore_screen.dart';
import 'tourist_spots.dart';
import 'hotel_detail_screen.dart';
import 'help_center_screen.dart';
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
  late final Stream<List<Place>> _placesStream;
  final List<Map<String, dynamic>> _upcomingEvents = [
    {
      'title': 'Tokyo Cherry Blossom Festival',
      'date': 'Mar 20 - Apr 10, 2026',
      'location': 'Ueno Park, Tokyo, Japan',
      'image':
          'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400',
      'details':
          'Experience the breath-taking views of Ueno Park covered in pink cherry blossoms. The festival features local food vendors, lantern illumination at night, and traditional picnic gatherings (Hanami) under the trees.',
    },
    {
      'title': 'Rio de Janeiro Carnival',
      'date': 'Feb 13 - Feb 18, 2026',
      'location': 'Sambadrome, Rio, Brazil',
      'image':
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400',
      'details':
          'The biggest and most colorful festival in the world. Witness magnificent samba school parades, extravagant costumes, and infectious street parties (blocos) that cover the entire city.',
    },
    {
      'title': 'Munich Oktoberfest',
      'date': 'Sep 19 - Oct 04, 2026',
      'location': 'Theresienwiese, Munich, Germany',
      'image':
          'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=400',
      'details':
          'Celebrate Bavarian culture at the world\'s largest Volksfest. Enjoy traditional German beers served in massive steins, delicious pretzels, amusement rides, and lively brass band music.',
    },
  ];
  final List<Map<String, String>> _exchangeRates = [
    {'currency': 'USD to EUR', 'rate': '0.92 €', 'flag': '🇪🇺'},
    {'currency': 'USD to JPY', 'rate': '156.4 ¥', 'flag': '🇯🇵'},
    {'currency': 'USD to GBP', 'rate': '0.78 £', 'flag': '🇬🇧'},
    {'currency': 'USD to AUD', 'rate': '1.51 A\$', 'flag': '🇦🇺'},
    {'currency': 'USD to CAD', 'rate': '1.37 C\$', 'flag': '🇨🇦'},
  ];

  final List<Map<String, dynamic>> _weatherForecasts = [
    {
      'city': 'Tokyo',
      'temp': '19°C',
      'cond': 'Rainy',
      'icon': Icons.thunderstorm,
    },
    {'city': 'Paris', 'temp': '24°C', 'cond': 'Sunny', 'icon': Icons.wb_sunny},
    {
      'city': 'Rome',
      'temp': '26°C',
      'cond': 'Clear',
      'icon': Icons.brightness_5,
    },
    {'city': 'Bali', 'temp': '30°C', 'cond': 'Humid', 'icon': Icons.cloud},
    {
      'city': 'New York',
      'temp': '22°C',
      'cond': 'Cloudy',
      'icon': Icons.wb_cloudy,
    },
  ];

  final List<Map<String, dynamic>> _testimonials = [
    {
      'name': 'Sarah Jenkins',
      'avatar':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      'quote':
          'The tour packages were incredibly well structured. Booking a hotel and tour together saved me so much hassle!',
      'rating': 5,
      'destination': 'Bali, Indonesia',
    },
    {
      'name': 'David Chen',
      'avatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      'quote':
          'Very seamless checkout process. The customer support answered my queries immediately when I reached out through the help center.',
      'rating': 4,
      'destination': 'Tokyo, Japan',
    },
    {
      'name': 'Elena Rostova',
      'avatar':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
      'quote':
          'Amazing experiences! Wandering the streets of Rome with their guided recommendation list was the highlight of my summer.',
      'rating': 5,
      'destination': 'Rome, Italy',
    },
  ];

  final List<Map<String, dynamic>> _specialOffers = [
    {
      'title': 'Summer Escape to Bali',
      'discount': '20% OFF',
      'image':
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400',
      'destination': 'Bali, Indonesia',
      'price': '\$320',
      'originalPrice': '\$400',
      'category': 'Attractions',
    },
    {
      'title': 'Tokyo Neon Experience',
      'discount': '15% OFF',
      'image':
          'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400',
      'destination': 'Tokyo, Japan',
      'price': '\$510',
      'originalPrice': '\$600',
      'category': 'Cheap Eats',
    },
    {
      'title': 'Rome Antiquities Tour',
      'discount': 'Buy 1 Get 1',
      'image':
          'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=400',
      'destination': 'Rome, Italy',
      'price': '\$80',
      'originalPrice': '\$160',
      'category': 'Attractions',
    },
  ];

  final List<Map<String, String>> _travelArticles = [
    {
      'title': '5 Smart Packing Hacks for Stress-Free Travel',
      'category': 'Travel Hacks',
      'readTime': '4 min read',
      'image':
          'https://images.unsplash.com/photo-1523482580672-f109ba8cb9be?w=400',
      'content':
          'Packing can be one of the most stressful parts of traveling. Here are 5 expert tips to optimize your luggage space:\n\n'
          '1. Roll, Don\'t Fold: Rolling your clothes saves incredible space and minimizes wrinkles.\n'
          '2. Use Packing Cubes: Organize items by category or day. This keeps your suitcase neat.\n'
          '3. Heavy Items at the Bottom: Place shoes and heavy toiletries near the wheels of your suitcase for better balance.\n'
          '4. Pack Multi-Purpose Shoes: Limit yourself to two pairs—one comfortable walking shoe, and one dressier option.\n'
          '5. Wear Your Bulkiest Layers: If you\'re traveling with a heavy coat or boots, wear them on the plane to save bag space.',
    },
    {
      'title': 'How to Travel on a Budget without Sacrificing Comfort',
      'category': 'Budget Guide',
      'readTime': '6 min read',
      'image':
          'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=400',
      'content':
          'Traveling doesn\'t have to break the bank. Here\'s how to experience luxury on a budget:\n\n'
          '1. Travel Off-Season: Destinations are cheaper, less crowded, and flights are discounted.\n'
          '2. Book Flights Incognito: Prevent airline websites from tracking search history and raising prices.\n'
          '3. Leverage Free Walking Tours: A great way to learn a city\'s history while spending little.\n'
          '4. Cook a Few Meals: Sticking to local supermarkets or street stalls for lunch will save you massive amounts compared to sit-down restaurants.\n'
          '5. Use Public Transit: Opt for subways and trains instead of taxis and rideshares.',
    },
    {
      'title': '10 Hidden Gem Destinations to Explore in 2026',
      'category': 'Destinations',
      'readTime': '5 min read',
      'image':
          'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=400',
      'content':
          'Skip the tourist crowds and check out these 10 breathtaking hidden gems this year:\n\n'
          '1. Ronda, Spain: A stunning cliffside town split by a canyon.\n'
          '2. Gimmelwald, Switzerland: A car-free alpine village with gorgeous mountain backdrops.\n'
          '3. Koh Lipe, Thailand: A pristine island paradise with turquoise waters and white sand beaches.\n'
          '4. Lake Bled, Slovenia: A magical lake featuring an island church and clifftop castle.\n'
          '5. Alberobello, Italy: Famous for its unique dome-shaped stone huts called Trulli.\n'
          '6. Jiuzhaigou Valley, China: Stunning multi-tiered waterfalls and colorful lakes.\n'
          '7. Colmar, France: A town that looks straight out of a fairy tale.\n'
          '8. Chefchaouen, Morocco: The stunning blue-washed mountain city.\n'
          '9. Hallstatt, Austria: A gorgeous lakeside town surrounded by the Alps.\n'
          '10. Huacachina, Peru: A tiny desert oasis town surrounded by massive sand dunes.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _placesStream = _firestoreService.getPlacesStream();
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
                  builder: (context) =>
                      ExploreScreen(initialSearchQuery: query.trim()),
                ),
              );
              _searchController.clear();
            }
          },
          decoration: InputDecoration(
            hintText: 'Search destinations, categories...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            prefixIcon: Icon(Icons.search, color: Colors.blue[400]),
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
                    builder: (context) =>
                        ExploreScreen(initialCategory: catName),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
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
            _buildSpecialOffers(),
            const SizedBox(height: 30),
            _buildPackagesSection(),
            const SizedBox(height: 30),
            _buildWeatherWidget(),
            const SizedBox(height: 30),
            _buildUpcomingEvents(),
            const SizedBox(height: 30),
            _buildFeaturedDestinations(),
            const SizedBox(height: 30),
            _buildTrendingHotels(),
            const SizedBox(height: 30),
            _buildStatsRow(),
            const SizedBox(height: 30),
            _buildTestimonials(),
            const SizedBox(height: 30),
            _buildTravelArticles(),
            const SizedBox(height: 30),
            _buildQuickHelpLinks(),
            const SizedBox(height: 30),
            _buildExchangeRates(),
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
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: Colors.blue),
                    ),
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
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No matching destinations found.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 15,
                        ),
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

  Widget _buildPackagesSection() {
    return StreamBuilder<List<Place>>(
      stream: _placesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(color: Colors.blue)),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Error loading packages: ${snapshot.error}',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final all = snapshot.data ?? [];
        final packages = all.where((p) {
          final c = p.category.toLowerCase();
          return c.contains('package') ||
              c.contains('tour') ||
              c.contains('attraction');
        }).toList();

        if (packages.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Packages & Tours',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See all',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: packages.length,
                itemBuilder: (context, index) {
                  final p = packages[index];
                  return Container(
                    width: 260,
                    height: 176,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2642),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShillongDetailsScreen(
                              destinationName: p.name,
                              imageUrl: p.image,
                              location: p.location,
                              price: _extractPrice(p.price),
                              category: p.category,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Image.network(
                              p.image,
                              width: 260,
                              height: 110,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 260,
                                height: 110,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${p.location} • ${p.category}',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  Text(
                                    p.price,
                                    style: TextStyle(
                                      color: Colors.blue[300],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: const Color(0xFF0D1B2A),
                    child: const Icon(Icons.image, color: Colors.white24),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place.location,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          place.price,
                          style: TextStyle(
                            color: Colors.blue[300],
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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

  Widget _buildSpecialOffers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Special Offers & Deals',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_specialOffers.length} Deals Available',
                style: TextStyle(
                  color: Colors.blue[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _specialOffers.length,
            itemBuilder: (context, index) {
              final offer = _specialOffers[index];
              return Container(
                width: 300,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(offer['image']!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.95),
                        Colors.black.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                offer['discount']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              offer['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white70,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    offer['destination']!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  offer['price']!,
                                  style: TextStyle(
                                    color: Colors.blue[300],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  offer['originalPrice']!,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShillongDetailsScreen(
                                      destinationName: offer['title']!,
                                      imageUrl: offer['image']!,
                                      location: offer['destination']!,
                                      price:
                                          double.tryParse(
                                            offer['price']!.replaceAll(
                                              r'\$',
                                              '',
                                            ),
                                          ) ??
                                          100.0,
                                      category: offer['category']!,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Get Deal',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingHotels() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trending Stays & Hotels',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ExploreScreen(initialCategory: 'Hotels'),
                    ),
                  );
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: Colors.blue[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Place>>(
          stream: _firestoreService.getPlacesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2642),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Failed to load stays',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              );
            }

            final allPlaces = snapshot.data ?? [];
            final hotels = allPlaces
                .where((place) => place.category == 'Hotels')
                .toList();

            if (hotels.isEmpty) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: hotels.length,
                itemBuilder: (context, index) {
                  final hotel = hotels[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2642),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HotelDetailScreen(
                              hotelName: hotel.name,
                              location: hotel.location,
                              rating: hotel.rating,
                              reviews:
                                  int.tryParse(
                                    hotel.reviews.replaceAll(
                                      RegExp(r'[^0-9]'),
                                      '',
                                    ),
                                  ) ??
                                  0,
                              imageUrl: hotel.image,
                              price: _extractPrice(hotel.price),
                              type: 'hotel',
                              description: hotel.description,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: Image.network(
                              hotel.image,
                              height: 110,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 110,
                                  color: const Color(0xFF0D1B2A),
                                  child: const Icon(
                                    Icons.hotel,
                                    color: Colors.white24,
                                    size: 36,
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hotel.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.blue,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        hotel.location,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.6,
                                          ),
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 13,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          hotel.rating.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      hotel.price,
                                      style: TextStyle(
                                        color: Colors.blue[300],
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
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
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTravelArticles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Travel Tips & Guides',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _travelArticles.length,
          itemBuilder: (context, index) {
            final article = _travelArticles[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2642),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showArticleDetails(article),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          article['image']!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: const Color(0xFF0D1B2A),
                              child: const Icon(
                                Icons.article,
                                color: Colors.white24,
                                size: 30,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[400]!.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    article['category']!,
                                    style: TextStyle(
                                      color: Colors.blue[300],
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  article['readTime']!,
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              article['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to read full guide',
                              style: TextStyle(
                                color: Colors.blue[300],
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showArticleDetails(Map<String, String> article) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          article['image']!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              color: const Color(0xFF1A2642),
                              child: const Icon(
                                Icons.image,
                                color: Colors.white24,
                                size: 50,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[400]!.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              article['category']!,
                              style: TextStyle(
                                color: Colors.blue[300],
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            article['readTime']!,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        article['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(color: Colors.white10, height: 32),
                      Text(
                        article['content']!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Close Article',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildWeatherWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Destination Weather Forecast',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _weatherForecasts.length,
            itemBuilder: (context, index) {
              final w = _weatherForecasts[index];
              return Container(
                width: 145,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2642),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      w['icon'] as IconData,
                      color: Colors.blue[300],
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            w['city'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            w['temp'] as String,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            w['cond'] as String,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'What Our Travelers Say',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _testimonials.length,
            itemBuilder: (context, index) {
              final t = _testimonials[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2642),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(t['avatar'] as String),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['name'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                t['destination'] as String,
                                style: TextStyle(
                                  color: Colors.blue[300],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              Icons.star,
                              color: i < (t['rating'] as int)
                                  ? Colors.amber
                                  : Colors.white12,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Text(
                        '"${t['quote']}"',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickHelpLinks() {
    final quickFaqs = [
      {'title': 'Booking Help', 'icon': Icons.book_online},
      {'title': 'Refund Policy', 'icon': Icons.monetization_on},
      {'title': 'Safety & Guides', 'icon': Icons.security},
      {'title': 'Contact Support', 'icon': Icons.support_agent},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Help & Support',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quickFaqs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
            ),
            itemBuilder: (context, index) {
              final faq = quickFaqs[index];
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2642),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpCenterScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          faq['icon'] as IconData,
                          color: Colors.blue[400],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            faq['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Upcoming Festivals & Events',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _upcomingEvents.length,
            itemBuilder: (context, index) {
              final event = _upcomingEvents[index];
              return GestureDetector(
                onTap: () => _showEventDetails(event),
                child: Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(event['image']!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            event['date']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          event['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white70,
                              size: 10,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event['location']!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    event['image']!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  event['title']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: Colors.blue[400],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event['date']!,
                      style: TextStyle(
                        color: Colors.blue[300],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue[400], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event['location']!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white10, height: 32),
                const Text(
                  'About the Event',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event['details']!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {'val': '12K+', 'label': 'Trips Booked'},
      {'val': '99.8%', 'label': 'Happy Travelers'},
      {'val': '50+', 'label': 'Countries Covered'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2642),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: stats.map((s) {
            return Column(
              children: [
                Text(
                  s['val']!,
                  style: TextStyle(
                    color: Colors.blue[400],
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s['label']!,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildExchangeRates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Travel Exchange Rates',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _exchangeRates.length,
            itemBuilder: (context, index) {
              final r = _exchangeRates[index];
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2642),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(r['flag']!, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          r['currency']!,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          r['rate']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
