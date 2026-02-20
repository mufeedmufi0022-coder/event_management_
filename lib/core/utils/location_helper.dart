import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class LocationHelper {
  // Determine the current position of the device.
  static Future<Position?> getCurrentPosition() async {
    // For web, we need to handle permissions slightly differently or rely on browser prompt
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Set a timeout for getting the position (e.g. 5 seconds)
    // If it times out, we can try to fall back to last known position
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      // If timed out or failed, try last known position
      return await Geolocator.getLastKnownPosition();
    }
  }

  // Get address from coordinates
  static Future<String?> getAddressFromLatLng(
    double latitude,
    double longitude,
  ) async {
    // 1. Try Native Geocoding first (ONLY ON MOBILE)
    if (!kIsWeb) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude,
          longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          List<String> addressParts = [];

          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            addressParts.add(place.subLocality!);
          } else if (place.thoroughfare != null &&
              place.thoroughfare!.isNotEmpty) {
            addressParts.add(place.thoroughfare!);
          }

          if (place.locality != null && place.locality!.isNotEmpty) {
            addressParts.add(place.locality!);
          }

          if (addressParts.isNotEmpty) {
            return addressParts.join(", ");
          }
        }
      } catch (e) {
        print("Native Geocoding Error: $e");
      }
    }

    // 2. Fallback: Try OpenStreetMap Nominatim API if native fails
    // This is useful for emulators or regions with limited Google Services
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'EventManagementApp/1.0'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          // Extract most relevant parts
          String? sub =
              address['suburb'] ??
              address['neighbourhood'] ??
              address['village'];
          String? city =
              address['city'] ?? address['town'] ?? address['state_district'];

          if (sub != null && city != null) {
            return "$sub, $city";
          } else if (city != null) {
            return city;
          } else if (sub != null) {
            return sub;
          }
        }
      }
    } catch (e) {
      print("Nominatim Fallback Error: $e");
    }

    return null;
  }

  // Get coordinates from address query
  static Future<Position?> getCoordinatesFromQuery(String query) async {
    try {
      // Try native first
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        return _buildPosition(
          locations.first.latitude,
          locations.first.longitude,
        );
      }
    } catch (e) {
      // Try Nominatim fallback
      try {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1',
        );
        final response = await http.get(
          url,
          headers: {'User-Agent': 'EventManagementApp/1.0'},
        );
        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          if (data.isNotEmpty) {
            return _buildPosition(
              double.parse(data[0]['lat']),
              double.parse(data[0]['lon']),
            );
          }
        }
      } catch (e) {
        print("nominatim conversion error: $e");
      }
    }
    return null;
  }

  static Position _buildPosition(double lat, double lng) {
    return Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }
}
