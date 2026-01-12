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

    return await Geolocator.getCurrentPosition();
  }

  // Get address from coordinates
  static Future<String?> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Create a concise address: "Locality, City"
        String locality = place.locality ?? '';
        String subLocality = place.subLocality ?? '';
        
        if (subLocality.isNotEmpty && locality.isNotEmpty) {
          return "$subLocality, $locality";
        } else if (locality.isNotEmpty) {
          return locality;
        } else {
          return place.name ?? "Unknown Location";
        }
      }
    } catch (e) {
      print("Error getting address: $e");
    }
    return null;
  }
}
