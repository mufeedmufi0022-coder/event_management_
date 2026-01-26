import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/location_helper.dart';

class LocationSelectionView extends StatefulWidget {
  const LocationSelectionView({super.key});

  @override
  State<LocationSelectionView> createState() => _LocationSelectionViewState();
}

class _LocationSelectionViewState extends State<LocationSelectionView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  List<dynamic> _suggestions = [];
  Timer? _debounce;

  // Major cities in Kerala/Region for quick selection
  final List<String> _popularCities = [
    'Kochi, Kerala',
    'Thiruvananthapuram, Kerala',
    'Kozhikode, Kerala',
    'Thrissur, Kerala',
    'Malappuram, Kerala',
    'Kannur, Kerala',
    'Kollam, Kerala',
    'Alappuzha, Kerala',
    'Palakkad, Kerala',
    'Kottayam, Kerala',
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _error = null;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Using OpenStreetMap Nominatim API for suggestions
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5&countrycodes=in',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'EventManagementApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _suggestions = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load suggestions';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error occurred';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectSuggestion(Map<String, dynamic> suggestion) async {
    final lat = double.tryParse(suggestion['lat']?.toString() ?? '0') ?? 0.0;
    final lon = double.tryParse(suggestion['lon']?.toString() ?? '0') ?? 0.0;
    final displayName = suggestion['display_name'] ?? 'Unknown Location';

    await _finalizeSelection(displayName, lat, lon);
  }

  Future<void> _finalizeSelection(
    String address,
    double lat,
    double lon,
  ) async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.setCustomLocation(address, lat, lon);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error selecting location: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        title: const Text(
          'Select Location',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for area, street name...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF1F4F8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _useCurrentLocation,
                  child: const Row(
                    children: [
                      Icon(Icons.my_location, color: Color(0xFF904CC1)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Use Current Location',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF904CC1),
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Using GPS',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Show Suggestions if available
                  if (_suggestions.isNotEmpty) ...[
                    const Text(
                      'SUGGESTIONS',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._suggestions.map((suggestion) {
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey,
                        ),
                        title: Text(
                          suggestion['display_name'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(suggestion['type'] ?? 'Location'),
                        onTap: () => _selectSuggestion(
                          suggestion as Map<String, dynamic>,
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],

                  if (_searchController.text.isEmpty) ...[
                    const Text(
                      'POPULAR CITIES',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._popularCities.map((city) => _buildCityTile(city)),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCityTile(String city) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.location_city, color: Colors.grey),
      title: Text(city),
      onTap: () async {
        // Manual city selection, fetching coords
        FocusScope.of(context).unfocus();
        try {
          final position = await LocationHelper.getCoordinatesFromQuery(city);
          if (position != null) {
            _finalizeSelection(city, position.latitude, position.longitude);
          }
        } catch (e) {
          _onSearchChanged(city); // Fallback to search api
        }
      },
    );
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.updateLocation(); // This already handles GPS fetching
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Could not fetch current location.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
