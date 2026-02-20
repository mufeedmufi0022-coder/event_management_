import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationHelper {
  // Determine the current position of the device.
  static Future<Position?> getCurrentPosition() async {
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

    // Check for last known position first for speed
    try {
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        // Return immediately if recent enough? For now just return it if available
        // But we actually want the *current* position if possible.
        // Let's stick to returning current position but with a timeout
      }
    } catch (e) {
      // Ignore
    }

    // Set a timeout for getting the position (e.g. 5 seconds)
    // If it times out, we can try to fall back to last known position
    try {
      return await Geolocator.getCurrentPosition(
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
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Print all fields for debugging if needed
        print("Placemark: ${place.toJson()}");

        List<String> addressParts = [];

        // Try to get the most specific parts first
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        } else if (place.thoroughfare != null &&
            place.thoroughfare!.isNotEmpty) {
          addressParts.add(place.thoroughfare!);
        }

        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }

        if (addressParts.isEmpty) {
          if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty) {
            addressParts.add(place.administrativeArea!);
          } else {
            return place.name ?? "Unknown Location";
          }
        }

        return addressParts.join(", ");
      }
    } catch (e) {
      print("Error getting address: $e");
    }
    return null;
  }

  // Get coordinates from address query
  static Future<Position?> getCoordinatesFromQuery(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        return Position(
          latitude: locations.first.latitude,
          longitude: locations.first.longitude,
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
    } catch (e) {
      print("Error finding location: $e");
    }
    return null;
  }
}
