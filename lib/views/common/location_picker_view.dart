import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class LocationResult {
  final String address;
  final LatLng latLng;

  LocationResult({required this.address, required this.latLng});
}

class LocationPickerView extends StatefulWidget {
  final LatLng initialCenter;
  final String? initialAddress;

  const LocationPickerView({
    super.key, 
    this.initialCenter = const LatLng(10.8505, 76.2711),
    this.initialAddress,
  });

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  late MapController _mapController;
  LatLng _selectedLatLng = const LatLng(10.8505, 76.2711);
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLatLng = widget.initialCenter;
    _selectedAddress = widget.initialAddress;
    if (_selectedAddress != null) {
      _searchController.text = _selectedAddress!;
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=10&viewbox=74.8,12.8,77.3,8.2&bounded=0'),
        headers: {'User-Agent': 'EventMVP_App'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _searchResults = json.decode(response.body);
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Search failed. Please try again.')),
      );
    }
  }

  void _selectLocation(dynamic result) {
    final lat = double.parse(result['lat']);
    final lon = double.parse(result['lon']);
    final newLatLng = LatLng(lat, lon);
    
    setState(() {
      _selectedLatLng = newLatLng;
      _selectedAddress = result['display_name'];
      _searchController.text = _selectedAddress!;
      _searchResults = [];
    });

    _mapController.move(newLatLng, 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        title: const Text('Select Location', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_selectedAddress != null)
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context, 
                  LocationResult(address: _selectedAddress!, latLng: _selectedLatLng),
                );
              },
              child: const Text('CONFIRM', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF904CC1))),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLatLng,
              initialZoom: 13,
              onTap: (tapPosition, point) async {
                setState(() => _selectedLatLng = point);
                // Reverse geocode to get address
                try {
                  final response = await http.get(
                    Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}'),
                    headers: {'User-Agent': 'EventMVP_App'},
                  );
                  if (response.statusCode == 200) {
                    final data = json.decode(response.body);
                    setState(() {
                      _selectedAddress = data['display_name'];
                      _searchController.text = _selectedAddress ?? '';
                    });
                  }
                } catch (e) {
                  print('Reverse geocoding failed: $e');
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.event_mvp',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLatLng,
                    width: 80,
                    height: 80,
                    alignment: Alignment.topCenter,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 45),
                  ),
                ],
              ),
            ],
          ),
          
          // Search Input
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for a place...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _isSearching 
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchResults = []);
                            },
                          ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onChanged: (value) {
                      if (value.length > 2) {
                        _searchLocation(value);
                      }
                    },
                  ),
                ),
                
                // Search Results
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchResults.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on_outlined, color: Colors.grey),
                          title: Text(
                            result['display_name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () => _selectLocation(result),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          
          // Selected Address Detail Bar
          if (_selectedAddress != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.my_location, color: Color(0xFF904CC1)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedAddress!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
