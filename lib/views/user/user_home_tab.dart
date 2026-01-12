import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/utils/image_helper.dart';
import 'vendor_list_view.dart';
import 'vendor_details_view.dart';

class UserHomeTab extends StatelessWidget {
  const UserHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final lp = context.watch<LocaleProvider>();
    final authProvider = context.watch<AuthProvider>();
    final vendors = userProvider.approvedVendors;

    // Get all products from all approved vendors for "Recently Added"
    final allProducts = vendors.expand((v) => v.products.map((p) => {'product': p, 'vendor': v})).toList();
    allProducts.shuffle(); // Just for variety in MVP
    final recentlyAdded = allProducts.take(5).toList();

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
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: Color(0xFF904CC1)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    authProvider.userModel?.currentAddress ?? lp.get('Locating...', 'തിരയുന്നു...'),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recently Added Section (Horizontal Scroll)
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                lp.get('Recently Added', 'അടുത്തിടെ ചേർത്തവ'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: recentlyAdded.isEmpty
                  ? const Center(child: Text('No products available'))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: recentlyAdded.length,
                      itemBuilder: (context, index) {
                        final item = recentlyAdded[index];
                        final product = item['product'] as dynamic;
                        final vendor = item['vendor'] as dynamic;
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => VendorDetailsView(vendor: vendor)),
                          ),
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: ImageHelper.displayImage(product.imageUrl, fit: BoxFit.cover, width: double.infinity),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      Text('₹${product.price}', style: const TextStyle(color: Color(0xFF904CC1), fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Event Categories Grid
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                lp.get('Event Categories', 'ഇവന്റ് വിഭാഗങ്ങൾ'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildCategoryItem(context, lp.get('Wedding', 'വിവാഹം'), Icons.favorite, const Color(0xFFFF4081)),
                _buildCategoryItem(context, lp.get('Birthday', 'ജന്മദിനം'), Icons.cake, const Color(0xFF7C4DFF)),
                _buildCategoryItem(context, lp.get('Inauguration', 'ഉദ്ഘാടനം'), Icons.store, const Color(0xFF00BCD4)),
                _buildCategoryItem(context, lp.get('Party', 'പാർട്ടി'), Icons.music_note, const Color(0xFFFFC107)),
                _buildCategoryItem(context, lp.get('Others', 'മറ്റുള്ളവ'), Icons.more_horiz, const Color(0xFF9E9E9E)),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VendorListView(category: title)),
      ),
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.7), color],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
