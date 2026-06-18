import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place.dart';

// FirestoreService - Firebase Firestore database operations
//
// COLLECTIONS:
// 1. users - User profiles with savedPlaces array
// 2. places - All travel destinations/packages
//
// METHODS IMPLEMENTED:
// User Operations:
// - getUserProfile(uid) - Get user profile data
// - getUserData(uid) - Get user data with savedPlaces
// - updateUserProfile(uid, data) - Update user profile
//
// Place Operations (Items 4 & 5):
// - savePlace(place) - Save place to Firestore
// - getPlace(placeId) - Retrieve place by ID
// - isPlaceSaved(userId, placeId) - Check if user saved a place
// - addPlaceToUserSavedPlaces(userId, placeId) - Add to favorites
// - removePlaceFromUserSavedPlaces(userId, placeId) - Remove from favorites
// - getUserSavedPlaces(userId) - Stream of user's saved places
//
// USAGE: Used by Explore Screen and all Detail Screens for save functionality

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- User Operations ---

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      throw 'Error updating profile: $e';
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        // Ensure savedPlaces field exists
        if (data != null && !data.containsKey('savedPlaces')) {
          data['savedPlaces'] = [];
        }
        return data;
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching user data: $e');
      return null;
    }
  }

  // --- Places Operations ---

  Future<void> savePlace(Place place) async {
    try {
      await _db
          .collection('places')
          .doc(place.id)
          .set(place.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw 'Error saving place: $e';
    }
  }

  Future<Place?> getPlace(String placeId) async {
    try {
      final doc = await _db.collection('places').doc(placeId).get();
      if (doc.exists) {
        return Place.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Error fetching place: $e';
    }
  }

  /// Check if a place is saved by user
  Future<bool> isPlaceSaved(String userId, String placeId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        final savedPlaces = List<String>.from(data?['savedPlaces'] ?? []);
        return savedPlaces.contains(placeId);
      }
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('Error checking if place is saved: $e');
      return false;
    }
  }

  /// Add place to user's saved places
  Future<void> addPlaceToUserSavedPlaces(String userId, String placeId) async {
    try {
      await _db.collection('users').doc(userId).set({
        'savedPlaces': FieldValue.arrayUnion([placeId]),
      }, SetOptions(merge: true));
    } catch (e) {
      // ignore: avoid_print
      print('Error adding place to saved: $e');
      rethrow;
    }
  }

  /// Remove place from user's saved places
  Future<void> removePlaceFromUserSavedPlaces(
    String userId,
    String placeId,
  ) async {
    try {
      await _db.collection('users').doc(userId).set({
        'savedPlaces': FieldValue.arrayRemove([placeId]),
      }, SetOptions(merge: true));
    } catch (e) {
      // ignore: avoid_print
      print('Error removing place from saved: $e');
      rethrow;
    }
  }

  Stream<List<Place>> getUserSavedPlaces(String userId) {
    return _db.collection('users').doc(userId).snapshots().asyncMap((
      userDoc,
    ) async {
      if (!userDoc.exists) return [];

      final savedPlaceIds = List<String>.from(
        userDoc.data()?['savedPlaces'] ?? [],
      );
      if (savedPlaceIds.isEmpty) return [];

      final placeDocs = await Future.wait(
        savedPlaceIds.map((id) => _db.collection('places').doc(id).get()),
      );

      return placeDocs
          .where((doc) => doc.exists)
          .map((doc) => Place.fromMap(doc.data()!))
          .toList();
    });
  }

  // --- Search, Filter & Admin Place Management ---

  Stream<List<Place>> getPlacesStream() {
    return _db.collection('places').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Place.fromMap(doc.data())).toList();
    });
  }

  Future<void> deletePlace(String placeId) async {
    try {
      await _db.collection('places').doc(placeId).delete();
    } catch (e) {
      throw 'Error deleting place: $e';
    }
  }

  // --- Booking Operations ---

  Future<void> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final docRef = _db.collection('bookings').doc();
      bookingData['bookingId'] = docRef.id;
      await docRef.set(bookingData);
    } catch (e) {
      throw 'Error creating booking: $e';
    }
  }

  Stream<List<Map<String, dynamic>>> getUserBookingsStream(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => doc.data()).toList();
      list.sort((a, b) {
        final dateA = DateTime.parse(
          a['createdAt'] ?? DateTime.now().toIso8601String(),
        );
        final dateB = DateTime.parse(
          b['createdAt'] ?? DateTime.now().toIso8601String(),
        );
        return dateB.compareTo(dateA);
      });
      return list;
    });
  }

  Stream<List<Map<String, dynamic>>> getAllBookingsStream() {
    return _db.collection('bookings').snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => doc.data()).toList();
      list.sort((a, b) {
        final dateA = DateTime.parse(
          a['createdAt'] ?? DateTime.now().toIso8601String(),
        );
        final dateB = DateTime.parse(
          b['createdAt'] ?? DateTime.now().toIso8601String(),
        );
        return dateB.compareTo(dateA);
      });
      return list;
    });
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      final querySnapshot = await _db
          .collection('bookings')
          .where('bookingId', isEqualTo: bookingId)
          .get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'status': status});
      }
    } catch (e) {
      throw 'Error updating booking status: $e';
    }
  }
}
