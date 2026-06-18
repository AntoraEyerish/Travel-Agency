// Place Model - Data structure for travel destinations/packages
//
// FIELDS:
// - id: Unique identifier (lowercase name with underscores)
// - name: Place name (e.g., "Cox's Bazar Beach")
// - location: City/Country (e.g., "Bangladesh")
// - category: Type (Restaurants, Hotels, Attractions, Cafes, etc.)
// - rating: Star rating (0.0 - 5.0)
// - reviews: Review count as string (e.g., "1.1k")
// - image: URL to place image
// - description: Detailed description
// - price: Price range (e.g., "$50-100")
// - isOpen: Current open/closed status
// - createdAt: Timestamp
//
// FIREBASE: Stored in 'places' collection
// USAGE: Used in Explore Screen, Detail Screens, and Save functionality

class Place {
  final String id;
  final String name;
  final String location;
  final String category;
  final double rating;
  final String reviews;
  final String image;
  final String description;
  final String price;
  final bool isOpen;
  final int duration;
  final DateTime createdAt;

  Place({
    required this.id,
    required this.name,
    required this.location,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.image,
    required this.description,
    required this.price,
    required this.isOpen,
    required this.duration,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'category': category,
      'rating': rating,
      'reviews': reviews,
      'image': image,
      'description': description,
      'price': price,
      'isOpen': isOpen,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      category: map['category'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviews: map['reviews'] ?? '',
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? '',
      isOpen: map['isOpen'] ?? true,
      duration: map['duration'] ?? 3,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }
}
