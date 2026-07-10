import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/place.dart';
import 'hotel_detail_screen.dart';

class SavedPlacesScreen extends StatelessWidget {
  const SavedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final fs = FirestoreService();

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
            child:
                const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Saved Places',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: user == null
          ? const Center(
              child: Text('Please log in to view saved places',
                  style: TextStyle(color: Colors.white54)))
          : StreamBuilder<List<Place>>(
              stream: fs.getUserSavedPlaces(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.blue));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Error loading saved places.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                }

                final places = snapshot.data ?? [];

                if (places.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1A2642),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.bookmark_border,
                              color: Colors.amber, size: 48),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No Saved Places Yet',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Places you bookmark will appear here.\nExplore and save your favourites!',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.74,
                  ),
                  itemCount: places.length,
                  itemBuilder: (ctx, i) {
                    final place = places[i];
                    return GestureDetector(
                      onTap: () {
                        // Parse reviews string → int (e.g. "1.1k" → 1100)
                        int reviewsInt = 0;
                        final r = place.reviews.toLowerCase().replaceAll(',', '');
                        if (r.endsWith('k')) {
                          reviewsInt = ((double.tryParse(r.replaceAll('k', '')) ?? 0) * 1000).toInt();
                        } else {
                          reviewsInt = int.tryParse(r) ?? 0;
                        }

                        // Parse price string → double (e.g. "$50-100" → 50)
                        double priceDouble = 0;
                        final pStr = place.price.replaceAll(RegExp(r'[^\d.]'), '');
                        priceDouble = double.tryParse(pStr.split('-').first) ?? 0;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HotelDetailScreen(
                              hotelName: place.name,
                              location: place.location,
                              rating: place.rating,
                              reviews: reviewsInt,
                              imageUrl: place.image,
                              price: priceDouble,
                              description: place.description,
                              type: place.category.toLowerCase(),
                            ),
                          ),
                        );
                      },
                      child: _PlaceCard(
                          place: place, userId: user.uid, fs: fs),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final Place place;
  final String userId;
  final FirestoreService fs;

  const _PlaceCard(
      {required this.place, required this.userId, required this.fs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A2642),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                place.image.isNotEmpty
                    ? Image.network(place.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder())
                    : _placeholder(),
                // Unsave button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      await fs.removePlaceFromUserSavedPlaces(
                          userId, place.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${place.name} removed from saved'),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bookmark,
                          color: Colors.amber, size: 16),
                    ),
                  ),
                ),
                // Rating badge
                if (place.rating > 0)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              color: Colors.amber, size: 12),
                          const SizedBox(width: 3),
                          Text(
                            place.rating.toStringAsFixed(1),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white38, size: 11),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        place.location,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (place.price.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    place.price,
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFF0D1B33),
        child: const Center(
            child: Icon(Icons.landscape, color: Colors.white24, size: 40)),
      );
}
