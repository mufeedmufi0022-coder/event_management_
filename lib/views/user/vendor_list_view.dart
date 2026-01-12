import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/booking_model.dart';
import '../../models/vendor_model.dart';
import 'vendor_details_view.dart';
import '../../core/utils/image_helper.dart';
import '../../providers/locale_provider.dart';

class VendorListView extends StatelessWidget {
  final String? category;
  const VendorListView({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final lp = context.watch<LocaleProvider>();
    
    // Filter vendors if category is provided
    final vendors = category == null 
        ? userProvider.approvedVendors 
        : userProvider.approvedVendors.where((v) => 
            v.serviceType.toLowerCase().contains(category!.toLowerCase()) || 
            category == 'Others' ||
            category == 'മറ്റുള്ളവ'
          ).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category ?? lp.get('Discover Vendors', 'വെണ്ടർമാരെ കണ്ടെത്തുക'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: Color(0xFF904CC1)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    context.watch<AuthProvider>().userModel?.currentAddress ?? lp.get('Locating...', 'തിരയുന്നു...'),
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language_rounded, color: Color(0xFF904CC1)),
            onSelected: lp.setLocale,
            itemBuilder: (context) => [
              const PopupMenuItem(value: Locale('en'), child: Text('English')),
              const PopupMenuItem(value: Locale('ml'), child: Text('മലയാളം')),
            ],
          ),
        ],
      ),
      body: vendors.isEmpty
          ? Center(child: Text(lp.get('No approved vendors yet.', 'വെണ്ടർമാരെ ലഭ്യമല്ല.')))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vendors.length,
              itemBuilder: (context, index) {
                final vendor = vendors[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VendorDetailsView(vendor: vendor)),
                  ),
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (vendor.logoUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: ImageHelper.displayImage(
                              vendor.logoUrl,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    vendor.businessName.isNotEmpty ? vendor.businessName : 'Unnamed Business',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    vendor.priceRange,
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vendor.serviceType,
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      vendor.location,
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  }
