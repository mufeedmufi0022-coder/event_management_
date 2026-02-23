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

    // Unified matching logic for products
    bool isProductMatch(ProductModel p, String searchCat) {
      final s = searchCat.toLowerCase();
      final pName = p.name.toLowerCase();
      final pCat = (p.categoryType ?? '').toLowerCase();
      final pSub = (p.subType ?? '').toLowerCase();

      // 1. Direct contains check
      if (pName.contains(s) || pCat.contains(s) || pSub.contains(s))
        return true;

      // 2. Synonyms mapping
      // Vehicles
      if ((s.contains('car') || s.contains('vehicle')) &&
          (pCat.contains('vehicle') || pCat.contains('car')))
        return true;

      // Convention Center
      if ((s.contains('convention') ||
              s.contains('hall') ||
              s.contains('center')) &&
          (pCat.contains('convention') ||
              pCat.contains('hall') ||
              pCat.contains('center')))
        return true;

      // Music/DJ
      if ((s.contains('music') || s.contains('dj')) &&
          (pCat.contains('music') || pCat.contains('dj')))
        return true;

      // Photography
      if ((s.contains('photo') || s.contains('graphy') || s.contains('cam')) &&
          (pCat.contains('photo') ||
              pCat.contains('graphy') ||
              pCat.contains('cam')))
        return true;

      // Catering / Food / Restaurant
      if ((s.contains('cater') || s.contains('food') || s.contains('rest')) &&
          (pCat.contains('cater') ||
              pCat.contains('food') ||
              pCat.contains('rest')))
        return true;

      // Decoration
      if (s.contains('decor') && pCat.contains('decor')) return true;

      return false;
    }

    // Filter vendors and flatten to products in one pass
    final List<Map<String, dynamic>> productsWithVendors = [];
    final searchCategory = category;

    for (var vendor in userProvider.approvedVendors) {
      for (var product in vendor.products) {
        bool matches = true;
        if (searchCategory != null &&
            searchCategory != 'Others' &&
            searchCategory != 'മറ്റുള്ളവ') {
          matches = isProductMatch(product, searchCategory);
        }

        if (matches) {
          productsWithVendors.add({'product': product, 'vendor': vendor});
        }
      }
    }

    // Sort by location if user has location set
    final userModel = context.watch<AuthProvider>().userModel;
    if (userModel?.latitude != null && userModel?.longitude != null) {
      productsWithVendors.sort((a, b) {
        final vA = a['vendor'] as VendorModel;
        final vB = b['vendor'] as VendorModel;

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
