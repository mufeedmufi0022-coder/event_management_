import 'package:flutter/material.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'vendor_list_view.dart';
import '../../core/utils/image_helper.dart';
import '../../core/utils/app_constants.dart';

class CategoryDetailView extends StatelessWidget {
  final String category;
  const CategoryDetailView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LocaleProvider>();
    final userProvider = context.watch<UserProvider>();

    // Show error if present
    if (userProvider.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.error!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () => userProvider.clearError(),
            ),
          ),
        );
        userProvider.clearError();
      });
    }

    final categoryData = _getCategoryData(category, context);
    final subCategories =
        categoryData['subCategories'] as List<Map<String, dynamic>>;
    final headerImage = categoryData['headerImage'] as String;

    // Show loading indicator if vendors are still loading
    if (userProvider.isLoading && userProvider.approvedVendors.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF1F4F8),
        appBar: AppBar(
          title: Text(category),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading services...'),
            ],
          ),
        ),
      );
    }

    // Show message if no subcategories found
    if (subCategories.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF1F4F8),
        appBar: AppBar(
          title: Text(category),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                lp.get('No services available', 'സേവനങ്ങളൊന്നും ലഭ്യമല്ല'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lp.get(
                  'Please check back later',
                  'പിന്നീട് വീണ്ടും പരിശോധിക്കുക',
                ),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    headerImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lp.get(
                      'What are you looking for?',
                      'നിങ്ങൾ എന്താണ് തിരയുന്നത്?',
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lp.get(
                      'Select a service category to find the best vendors',
                      'മികച്ച വെണ്ടർമാരെ കണ്ടെത്താൻ ഒരു സേവന വിഭാഗം തിരഞ്ഞെടുക്കുക',
                    ),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Changed to 3 for grid view matching images
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final sub = subCategories[index];
                return _buildSubCategoryCard(context, sub);
              }, childCount: subCategories.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildSubCategoryCard(BuildContext context, Map<String, dynamic> sub) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VendorListView(category: sub['name']),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    sub['image'] as String,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(sub['icon'] as IconData? ?? Icons.category),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sub['name'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCategoryData(String category, BuildContext context) {
    // Get info for the specific category from AppConstants
    final categoryInfo =
        AppConstants.eventCategories[category] ??
        AppConstants.eventCategories['Wedding']!;

    final headerImage = categoryInfo['headerImage'] as String;

    // Use the specific services defined for this category in AppConstants
    final categoryServices =
        categoryInfo['services'] as List<Map<String, dynamic>>;

    final List<Map<String, dynamic>> subCategories = categoryServices
        .map(
          (s) => {
            'name': s['name'] as String,
            'image': AppConstants.getServiceImage(s['name'] as String),
            'icon': s['icon'] as IconData,
          },
        )
        .toList();

    return {'headerImage': headerImage, 'subCategories': subCategories};
  }
}
