import 'package:flutter/material.dart';

class AppConstants {
  static const Map<String, Map<String, dynamic>> eventCategories = {
    'Wedding': {
      'headerImage':
          'assets/images/wedding_thumb.png', // Fallback, updated via category_detail_view
      'services': [
        {'name': 'Convention Center', 'icon': Icons.business},
        {'name': 'Decoration', 'icon': Icons.auto_awesome},
        {'name': 'Food', 'icon': Icons.restaurant},
        {'name': 'Catering', 'icon': Icons.room_service},
        {'name': 'Photography', 'icon': Icons.camera_alt},
        {'name': 'Vehicle', 'icon': Icons.directions_car},
        {'name': 'Music/DJ', 'icon': Icons.music_note},
        {'name': 'Rental Wears', 'icon': Icons.shopping_bag},
      ],
    },
    'Birthday': {
      'headerImage': 'assets/images/birthday_thumb.png',
      'services': [
        {'name': 'Catering', 'icon': Icons.room_service},
        {'name': 'Decoration', 'icon': Icons.celebration},
        {'name': 'Photography', 'icon': Icons.camera_alt},
        {'name': 'Music/DJ', 'icon': Icons.music_note},
        {'name': 'Restaurant', 'icon': Icons.restaurant_menu},
      ],
    },
    'Inauguration': {
      'headerImage': 'assets/images/inauguration_thumb.png',
      'services': [
        {'name': 'Decoration', 'icon': Icons.auto_awesome},
        {'name': 'Food', 'icon': Icons.restaurant},
        {'name': 'Catering', 'icon': Icons.room_service},
        {'name': 'Photography', 'icon': Icons.camera_alt},
        {'name': 'Vehicle', 'icon': Icons.directions_car},
      ],
    },
    'Party': {
      'headerImage': 'assets/images/party_thumb.png',
      'services': [
        {'name': 'Decoration', 'icon': Icons.auto_awesome},
        {'name': 'Food', 'icon': Icons.restaurant},
        {'name': 'Convention Center', 'icon': Icons.business},
        {'name': 'Catering', 'icon': Icons.room_service},
        {'name': 'Music/DJ', 'icon': Icons.music_note},
        {'name': 'Vehicle', 'icon': Icons.directions_car},
      ],
    },
  };

  static const List<String> serviceCategories = [
    'Photography',
    'Food',
    'Catering',
    'Vehicle',
    'Convention Center',
    'Music/DJ',
    'Decoration',
    'Restaurant',
    'Other',
  ];

  // Shared keywords for image mapping (used in CategoryDetailView logic)
  static String getServiceImage(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('convention') ||
        lowerType.contains('hall') ||
        lowerType.contains('center')) {
      return 'assets/images/convention_center_sub.png';
    } else if (lowerType.contains('decor')) {
      return 'assets/images/decoration_sub.png';
    } else if (lowerType.contains('food') || lowerType.contains('cater')) {
      return 'assets/images/food_sub.png';
    } else if (lowerType.contains('car') || lowerType.contains('vehicle')) {
      return 'assets/images/luxury_cars_sub.png';
    } else if (lowerType.contains('photo') || lowerType.contains('graphy')) {
      return 'assets/images/photographer_sub.png';
    } else if (lowerType.contains('music') || lowerType.contains('dj')) {
      return 'assets/images/party_thumb.png';
    } else if (lowerType.contains('wear') || lowerType.contains('rental')) {
      return 'assets/images/rental_wears_sub.png';
    } else if (lowerType.contains('restaurant')) {
      return 'assets/images/restaurant_sub.png';
    }
    return 'assets/images/wedding_thumb.png';
  }
}
