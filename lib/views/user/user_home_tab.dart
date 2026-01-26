import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/utils/image_helper.dart';
import 'category_detail_view.dart';
import 'product_detail_view.dart';
import '../../models/vendor_model.dart';
import 'location_selection_view.dart';

class UserHomeTab extends StatelessWidget {
  const UserHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final lp = context.watch<LocaleProvider>();
    final authProvider = context.watch<AuthProvider>();
    final vendors = userProvider.approvedVendors;

    // Get all products and sort by review count/rating for featured
    final allProductsWithVendors = vendors
        .expand((v) => v.products.map((p) => {'product': p, 'vendor': v}))
        .toList();

    // Find most reviewed product
    Map<String, dynamic>? featuredItem;
    if (allProductsWithVendors.isNotEmpty) {
      allProductsWithVendors.sort((a, b) {
        final pA = a['product'] as ProductModel;
        final pB = b['product'] as ProductModel;
        int cmp = pB.ratings.length.compareTo(pA.ratings.length);
        if (cmp == 0) return pB.averageRating.compareTo(pA.averageRating);
        return cmp;
      });
      featuredItem = allProductsWithVendors.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lp.get('Explore Services', 'സേവനങ്ങൾ പര്യവേക്ഷണം ചെയ്യുക'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationSelectionView(),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 12,
                    color: Color(0xFF904CC1),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      authProvider.userModel?.currentAddress ??
                          lp.get('Select Location', 'ലൊക്കേഷൻ തിരഞ്ഞെടുക്കുക'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recently Added (Portrait Slider)
            if (allProductsWithVendors.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: allProductsWithVendors.length.clamp(0, 10),
                  itemBuilder: (context, index) {
                    final item = allProductsWithVendors[index];
                    final product = item['product'] as ProductModel;
                    final vendor = item['vendor'] as VendorModel;

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailView(
                            product: product,
                            vendor: vendor,
                          ),
                        ),
                      ),
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ImageHelper.displayImage(
                                product.images.isNotEmpty
                                    ? product.images.first
                                    : '',
                                fit: BoxFit.cover,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Featured Service Section
            if (featuredItem != null) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  lp.get('Featured Service', 'തിരഞ്ഞെടുത്ത സേവനം'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailView(
                      product: featuredItem!['product'],
                      vendor: featuredItem!['vendor'],
                    ),
                  ),
                ),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: ImageHelper.displayImage(
                          (featuredItem['product'] as ProductModel)
                                  .images
                                  .isNotEmpty
                              ? (featuredItem['product'] as ProductModel)
                                    .images
                                    .first
                              : '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (featuredItem['product'] as ProductModel).name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  (featuredItem['product'] as ProductModel)
                                      .averageRating
                                      .toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${(featuredItem['product'] as ProductModel).ratings.length} reviews)',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
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
              ),
            ],

            // Categories Section
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                lp.get('Event Categories', 'ഇവന്റ് വിഭാഗങ്ങൾ'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryCircle(
                    context,
                    lp.get('Wedding', 'വിവാഹം'),
                    Icons.favorite_border,
                  ),
                  _buildCategoryCircle(
                    context,
                    lp.get('Birthday', 'ജന്മദിനം'),
                    Icons.cake_outlined,
                  ),
                  _buildCategoryCircle(
                    context,
                    lp.get('Inauguration', 'ഉദ്ഘാടനം'),
                    Icons.content_cut,
                  ),
                  _buildCategoryCircle(
                    context,
                    lp.get('Party', 'പാർട്ടി'),
                    Icons.music_note_outlined,
                  ),
                  _buildCategoryCircle(
                    context,
                    lp.get('others', 'മറ്റുള്ളവ'),
                    Icons.grid_view_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCircle(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryDetailView(category: title),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        width: 85,
        child: Column(
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFBA68C8), Color(0xFF9C27B0)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x4D9C27B0),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
