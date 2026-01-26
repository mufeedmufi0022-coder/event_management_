import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/vendor_model.dart';
import 'product_detail_view.dart';
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
    // Filter vendors if category is provided
    final matchedVendors = category == null
        ? userProvider.approvedVendors
        : userProvider.approvedVendors.where((v) {
            final searchCategory = category!.toLowerCase();

            // 1. Check if any product matches
            bool productMatch = v.products.any(
              (p) =>
                  // Check product name
                  p.name.toLowerCase().contains(searchCategory) ||
                  // Check category type (like 'car', 'catering')
                  (p.categoryType != null &&
                      p.categoryType!.toLowerCase().contains(searchCategory)) ||
                  // Check if searching for 'Luxury Cars', look for 'car' type
                  (searchCategory.contains('car') &&
                      (p.categoryType?.toLowerCase().contains('car') ?? false)),
            );

            return productMatch ||
                category == 'Others' ||
                category == 'മറ്റുള്ളവ';
          }).toList();

    // Flatten to products
    // Flatten to products
    final List<Map<String, dynamic>> productsWithVendors = [];
    for (var vendor in matchedVendors) {
      for (var product in vendor.products) {
        // If searching specific category, verify this individual product matches
        // logic should mirror the vendor filter logic
        // If searching specific category, verify this individual product matches
        // logic should mirror the vendor filter logic
        if (category != null &&
            category != 'Others' &&
            category != 'മറ്റുള്ളവ') {
          final searchCategory = category!.toLowerCase();
          // Determine if this is a specific product search
          bool isSpecificSearch =
              searchCategory.contains('car') ||
              searchCategory.contains('vehicle') ||
              searchCategory.contains('wear') ||
              searchCategory.contains('food') ||
              searchCategory.contains('cater') ||
              searchCategory.contains('decor') ||
              searchCategory.contains('photo') ||
              searchCategory.contains('music') ||
              searchCategory.contains('dj') ||
              searchCategory.contains('convention') ||
              searchCategory.contains('hall');

          bool productMatches =
              product.name.toLowerCase().contains(searchCategory) ||
              (product.categoryType?.toLowerCase().contains(searchCategory) ??
                  false) ||
              (product.subType?.toLowerCase().contains(searchCategory) ??
                  false) ||
              // Handle Synonyms based on Firestore types
              // Firestore Types: 'Vehicle', 'Convention Center', 'Food', 'Decoration', 'Catering', 'Photography', 'Music/DJ'
              // 1. Vehicles
              ((searchCategory.contains('car') ||
                      searchCategory.contains('vehicle')) &&
                  (product.categoryType?.toLowerCase().contains('vehicle') ??
                      false)) ||
              (searchCategory.contains('vehicle') &&
                  (product.categoryType?.toLowerCase().contains('car') ??
                      false)) ||
              // 2. Convention Center / Halls
              ((searchCategory.contains('convention') ||
                      searchCategory.contains('hall')) &&
                  (product.categoryType?.toLowerCase().contains('convention') ??
                      false)) ||
              // 3. Music/DJ
              ((searchCategory.contains('music') ||
                      searchCategory.contains('dj')) &&
                  ((product.categoryType?.toLowerCase().contains('music') ??
                          false) ||
                      (product.categoryType?.toLowerCase().contains('dj') ??
                          false)));

          if (isSpecificSearch && !productMatches) {
            continue;
          }
        }

        productsWithVendors.add({'product': product, 'vendor': vendor});
      }
    }

    // Sort by location if user has location set
    final userModel = context.watch<AuthProvider>().userModel;
    if (userModel?.latitude != null && userModel?.longitude != null) {
      productsWithVendors.sort((a, b) {
        final vA = a['vendor'] as VendorModel;
        final vB = b['vendor'] as VendorModel;

        // Since we don't have exact coordinates for vendors in VendorModel yet,
        // we can try to match the "location" string or use a fallback.
        // If VendorModel is updated to include lat/long, we would use:
        // double distA = Geolocator.distanceBetween(userModel!.latitude!, userModel!.longitude!, vA.latitude, vA.longitude);

        // For now, prioritize exact location match
        final userAddress = userModel?.currentAddress?.toLowerCase() ?? '';
        bool matchA =
            vA.location.toLowerCase().contains(userAddress) ||
            (userAddress.contains(vA.location.toLowerCase()));
        bool matchB =
            vB.location.toLowerCase().contains(userAddress) ||
            (userAddress.contains(vB.location.toLowerCase()));

        if (matchA && !matchB) return -1;
        if (!matchA && matchB) return 1;

        return 0;
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category ?? lp.get('Discover Services', 'സേവനങ്ങൾ കണ്ടെത്തുക'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 12,
                  color: Color(0xFF904CC1),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    context.watch<AuthProvider>().userModel?.currentAddress ??
                        lp.get('Locating...', 'തിരയുന്നു...'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
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
      ),
      body: productsWithVendors.isEmpty
          ? Center(
              child: Text(
                lp.get(
                  'No services found in this category.',
                  'ഈ വിഭാഗത്തിൽ സേവനങ്ങളൊന്നും ലഭ്യമല്ല.',
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: productsWithVendors.length,
              itemBuilder: (context, index) {
                final item = productsWithVendors[index];
                final p = item['product'] as ProductModel;
                final v = item['vendor'] as VendorModel;

                return _buildProductCard(context, p, v);
              },
            ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductModel p,
    VendorModel v,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailView(product: p, vendor: v),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: ImageHelper.displayImage(
                  p.images.isNotEmpty ? p.images.first : '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        p.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${p.ratings.length})',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${p.price}',
                        style: const TextStyle(
                          color: Color(0xFF904CC1),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (p.priceType == 'per_person')
                        const Text(
                          '/person',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
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
  }
}
