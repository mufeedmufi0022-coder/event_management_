import 'package:flutter/material.dart';
import '../../providers/locale_provider.dart';
import 'package:provider/provider.dart';
import 'vendor_list_view.dart';
import '../../core/utils/image_helper.dart';

class CategoryDetailView extends StatelessWidget {
  final String category;
  const CategoryDetailView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LocaleProvider>();
    
    final categoryData = _getCategoryData(category);
    final subCategories = categoryData['subCategories'] as List<Map<String, dynamic>>;
    final headerImage = categoryData['headerImage'] as String;

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
                    lp.get('What are you looking for?', 'നിങ്ങൾ എന്താണ് തിരയുന്നത്?'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lp.get('Select a service category to find the best vendors', 'മികച്ച വെണ്ടർമാരെ കണ്ടെത്താൻ ഒരു സേവന വിഭാഗം തിരഞ്ഞെടുക്കുക'),
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
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final sub = subCategories[index];
                  return _buildSubCategoryCard(context, sub);
                },
                childCount: subCategories.length,
              ),
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: AssetImage(sub['image'] as String),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  sub['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryData(String category) {
    switch (category) {
      case 'Wedding':
      case 'വിവാഹം':
        return {
          'headerImage': 'assets/images/wedding_thumb.png',
          'subCategories': [
            {'name': 'Convention Center', 'image': 'assets/images/convention_center_sub.png', 'color': Colors.blue},
            {'name': 'Decoration', 'image': 'assets/images/decoration_sub.png', 'color': Colors.pink},
            {'name': 'Food & Catering', 'image': 'assets/images/food_sub.png', 'color': Colors.orange},
            {'name': 'Catering Boys', 'image': 'assets/images/catering_boys_sub.png', 'color': Colors.teal},
            {'name': 'Rental Wears', 'image': 'assets/images/rental_wears_sub.png', 'color': Colors.purple},
            {'name': 'Luxury Cars', 'image': 'assets/images/luxury_cars_sub.png', 'color': Colors.indigo},
            {'name': 'Photographer', 'image': 'assets/images/photographer_sub.png', 'color': Colors.red},
          ]
        };
      case 'Birthday':
      case 'ജന്മദിനം':
        return {
          'headerImage': 'assets/images/birthday_thumb.png',
          'subCategories': [
            {'name': 'Restaurant', 'image': 'assets/images/restaurant_sub.png', 'color': Colors.orange},
            {'name': 'Decoration', 'image': 'assets/images/decoration_sub.png', 'color': Colors.purple},
            {'name': 'Food', 'image': 'assets/images/food_sub.png', 'color': Colors.red},
            {'name': 'Catering', 'image': 'assets/images/food_sub.png', 'color': Colors.blue},
          ]
        };
      case 'Inauguration':
      case 'ഉദ്ഘാടനം':
        return {
          'headerImage': 'assets/images/inauguration_thumb.png',
          'subCategories': [
            {'name': 'Decoration', 'image': 'assets/images/decoration_sub.png', 'color': Colors.amber},
            {'name': 'Food', 'image': 'assets/images/food_sub.png', 'color': Colors.orange},
            {'name': 'Catering', 'image': 'assets/images/food_sub.png', 'color': Colors.blue},
            {'name': 'Photographer', 'image': 'assets/images/photographer_sub.png', 'color': Colors.red},
            {'name': 'Luxury Cars', 'image': 'assets/images/luxury_cars_sub.png', 'color': Colors.indigo},
          ]
        };
      case 'Party':
      case 'പാർട്ടി':
        return {
          'headerImage': 'assets/images/party_thumb.png',
          'subCategories': [
            {'name': 'Decoration', 'image': 'assets/images/decoration_sub.png', 'color': Colors.blue},
            {'name': 'Food', 'image': 'assets/images/food_sub.png', 'color': Colors.pink},
            {'name': 'Convention Center', 'image': 'assets/images/convention_center_sub.png', 'color': Colors.green},
            {'name': 'Catering', 'image': 'assets/images/food_sub.png', 'color': Colors.orange},
            {'name': 'Luxury Cars', 'image': 'assets/images/luxury_cars_sub.png', 'color': Colors.indigo},
          ]
        };
      default:
        return {
          'headerImage': 'assets/images/wedding_thumb.png',
          'subCategories': []
        };
    }
  }
}
