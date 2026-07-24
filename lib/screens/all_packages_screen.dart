import 'package:flutter/material.dart';
import 'dart:math';
import '../models/place.dart';
import 'tourist_spots.dart';

class AllPackagesScreen extends StatelessWidget {
  final List<Place> packages;

  const AllPackagesScreen({super.key, required this.packages});

  static final List<String> _unsplashDefaults = [
    'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
    'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400',
    'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=400',
    'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=400',
    'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=400',
    'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400',
    'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=400',
    'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=400',
  ];

  static final Random _rand = Random();

  static String _randomDefaultImage() =>
      _unsplashDefaults[_rand.nextInt(_unsplashDefaults.length)];

  Widget _buildImage(
    String? src, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    final fallback = _randomDefaultImage();
    if (src == null || src.trim().isEmpty) {
      return Image.network(fallback, width: width, height: height, fit: fit);
    }

    if (src.startsWith('http')) {
      return Image.network(
        src,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            Image.network(fallback, width: width, height: height, fit: fit),
      );
    }

    return Image.asset(src, width: width, height: height, fit: fit);
  }

  double _parsePrice(String priceString) {
    final match = RegExp(r"\d+").firstMatch(priceString);
    if (match != null) return double.parse(match.group(0)!);
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        title: const Text('All Packages & Tours'),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final p = packages[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShillongDetailsScreen(
                      destinationName: p.name,
                      imageUrl: p.image,
                      location: p.location,
                      price: _parsePrice(p.price),
                      category: p.category,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2642),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                      child: Stack(
                        children: [
                          _buildImage(
                            p.image,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                p.price,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.55),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${p.location} • ${p.category}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                p.rating.toString(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              // small blue pill to show action
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[600],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Book',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
            );
          },
        ),
      ),
    );
  }
}
