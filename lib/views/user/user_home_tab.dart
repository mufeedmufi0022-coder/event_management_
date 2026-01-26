import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/utils/image_helper.dart';
import '../../core/utils/app_constants.dart';
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
    final categories = AppConstants.eventCategories.keys.toList();

    // Get all products for the instagram-style portrait slider
    final allProductsWithVendors = vendors
        .expand((v) => v.products.map((p) => {'product': p, 'vendor': v}))
        .toList();

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
            // Top side: Instagram Style Posters (Formerly Recently Added)
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

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                lp.get('Event Categories', 'ഇവന്റ് വിഭാഗങ്ങൾ'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bottom side: Image Cards
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final catData = AppConstants.eventCategories[cat]!;
                final image = catData['headerImage'] as String;

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryDetailView(category: cat),
                    ),
                  ),
                  child: Container(
                    height: 160,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: DecorationImage(
                        image: AssetImage(image),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Container(
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
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lp.get(cat, cat),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            lp.get('View Services', 'സേവനങ്ങൾ കാണുക'),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Recent Reviews section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                lp.get('What our customers say', 'ഉപഭോക്താക്കൾ പറയുന്നത്'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildRecentReviewsSection(vendors, lp),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReviewsSection(
    List<VendorModel> vendors,
    LocaleProvider lp,
  ) {
    // Collect all ratings from all products of all vendors
    final allRatings = vendors
        .expand(
          (v) => v.products.expand(
            (p) =>
                p.ratings.map((r) => {'rating': r, 'product': p, 'vendor': v}),
          ),
        )
        .toList();

    if (allRatings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'No reviews yet. Be the first to review!',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Sort by timestamp and take 5
    allRatings.sort(
      (a, b) => (b['rating'] as RatingModel).timestamp.compareTo(
        (a['rating'] as RatingModel).timestamp,
      ),
    );
    final displayRatings = allRatings.take(5).toList();

    return SizedBox(
      height: 180,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: displayRatings.length,
        itemBuilder: (context, index) {
          final item = displayRatings[index];
          final r = item['rating'] as RatingModel;
          final p = item['product'] as ProductModel;
          final v = item['vendor'] as VendorModel;

          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xFF904CC1).withOpacity(0.1),
                      child: const Icon(
                        Icons.person,
                        size: 14,
                        color: Color(0xFF904CC1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          size: 10,
                          color: i < r.stars ? Colors.amber : Colors.grey[300],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    r.comment,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'on ${p.name}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF904CC1),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${r.timestamp.day}/${r.timestamp.month}',
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
