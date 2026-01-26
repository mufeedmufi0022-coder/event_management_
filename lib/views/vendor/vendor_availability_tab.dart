import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../providers/vendor_provider.dart';
import '../../models/vendor_model.dart';
import '../../core/constants/app_colors.dart';

class VendorAvailabilityTab extends StatefulWidget {
  const VendorAvailabilityTab({super.key});

  @override
  State<VendorAvailabilityTab> createState() => _VendorAvailabilityTabState();
}

class _VendorAvailabilityTabState extends State<VendorAvailabilityTab> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorProvider>();
    final vendor = provider.vendorModel;

    if (vendor == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        title: const Text(
          'Manage Availability',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 16),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 1)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _showBlockingDialog(context, selectedDay);
              },
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              eventLoader: (day) => _getEventsForDay(day, vendor),
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF904CC1),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color(0x60904CC1),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return null;

                  Color markerColor =
                      Colors.green; // Should not happen if empty
                  if (events.contains('blocked')) {
                    markerColor = Colors.red;
                  } else if (events.contains('partial')) {
                    markerColor = Colors.orange;
                  }

                  return Positioned(
                    bottom: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: markerColor,
                        shape: BoxShape.circle,
                      ),
                      width: 7.0,
                      height: 7.0,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: Colors.red, text: 'Store Closed'),
                SizedBox(width: 16),
                _LegendItem(color: Colors.orange, text: 'Partially Blocked'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: Text(
                'Tap a date to manage availability',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getEventsForDay(DateTime day, VendorModel vendor) {
    final dateStr = day.toIso8601String().split('T')[0];

    // Check if entire store is blocked
    if (vendor.availability[dateStr] == 'blocked') {
      return ['blocked'];
    }

    // Check if ANY product is blocked
    bool hasBlockedProduct = false;
    bool allProductsBlocked = vendor.products.isNotEmpty;

    for (var product in vendor.products) {
      if (product.blockedDates.contains(dateStr)) {
        hasBlockedProduct = true;
      } else {
        allProductsBlocked = false;
      }
    }

    if (allProductsBlocked && vendor.products.isNotEmpty) return ['blocked'];
    if (hasBlockedProduct) return ['partial'];

    return [];
  }

  void _showBlockingDialog(BuildContext context, DateTime date) {
    final provider = context.read<VendorProvider>();
    final vendor = provider.vendorModel!;
    final dateStr = date.toIso8601String().split('T')[0];

    // Initial States
    bool isStoreClosed = vendor.availability[dateStr] == 'blocked';

    // Map of Product Index -> IsBlocked
    Map<int, bool> productBlockStates = {};
    for (int i = 0; i < vendor.products.length; i++) {
      productBlockStates[i] = vendor.products[i].blockedDates.contains(dateStr);
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Availability: $dateStr'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Close Entire Store',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Block all bookings for this date'),
                      activeColor: Colors.red,
                      value: isStoreClosed,
                      onChanged: (val) {
                        setState(() {
                          isStoreClosed = val;
                          // If store is closed, visually check all products
                          if (val) {
                            for (var key in productBlockStates.keys) {
                              productBlockStates[key] = true;
                            }
                          }
                        });
                      },
                    ),
                    const Divider(height: 32),
                    const Text(
                      'Block Specific Products:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (vendor.products.isEmpty)
                      const Text(
                        'No products listed.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ...List.generate(vendor.products.length, (index) {
                      final product = vendor.products[index];
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(product.name),
                        subtitle: Text(
                          '₹${product.price}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        value: isStoreClosed
                            ? true
                            : (productBlockStates[index] ?? false),
                        activeColor: isStoreClosed
                            ? Colors.grey
                            : const Color(0xFF904CC1),
                        onChanged: isStoreClosed
                            ? null
                            : (val) {
                                setState(
                                  () =>
                                      productBlockStates[index] = val ?? false,
                                );
                              },
                      );
                    }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _saveBlockingConfiguration(
                    dateStr,
                    isStoreClosed,
                    productBlockStates,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF904CC1),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(100, 40),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _saveBlockingConfiguration(
    String dateStr,
    bool isStoreClosed,
    Map<int, bool> productBlockStates,
  ) {
    final provider = context.read<VendorProvider>();
    final vendor = provider.vendorModel!;

    // 1. Update Availability Map (Vendor Level)
    Map<String, String> newAvailability = Map.from(vendor.availability);
    if (isStoreClosed) {
      newAvailability[dateStr] = 'blocked';
    } else {
      newAvailability.remove(dateStr);
    }

    // 2. Update Products
    List<ProductModel> newProducts = [];
    for (int i = 0; i < vendor.products.length; i++) {
      final product = vendor.products[i];
      List<String> newBlockedDates = List.from(product.blockedDates);

      // If user manually checked it OR store is closed, we block it
      bool shouldBlock = isStoreClosed
          ? true
          : (productBlockStates[i] ?? false);

      if (shouldBlock) {
        if (!newBlockedDates.contains(dateStr)) newBlockedDates.add(dateStr);
      } else {
        newBlockedDates.remove(dateStr);
      }

      // Reconstruct ProductModel
      newProducts.add(
        ProductModel(
          images: product.images,
          price: product.price,
          name: product.name,
          capacity: product.capacity,
          mobileNumber: product.mobileNumber,
          location: product.location,
          priceType: product.priceType,
          categoryType: product.categoryType,
          subType: product.subType,
          blockedDates: newBlockedDates,
          bookedDates: product.bookedDates,
          ratings: product.ratings,
        ),
      );
    }

    // 3. Reconstruct VendorModel
    final newVendor = VendorModel(
      vendorId: vendor.vendorId,
      businessName: vendor.businessName,
      location: vendor.location,
      priceRange: vendor.priceRange,
      description: vendor.description,
      contactNumber: vendor.contactNumber,
      images: vendor.images,
      logoUrl: vendor.logoUrl,
      products: newProducts,
      status: vendor.status,
      availability: newAvailability,
      isActive: vendor.isActive,
    );

    provider.updateProfile(newVendor);
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
