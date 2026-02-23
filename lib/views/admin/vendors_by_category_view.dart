import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';
import '../../core/utils/app_constants.dart';
import 'vendor_detail_admin_view.dart';

class VendorsByCategoryView extends StatefulWidget {
  const VendorsByCategoryView({super.key});

  @override
  State<VendorsByCategoryView> createState() => _VendorsByCategoryViewState();
}

class _VendorsByCategoryViewState extends State<VendorsByCategoryView> {
  String _selectedCategory = AppConstants.serviceCategories.first;

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final vendors = adminProvider.vendors;

    // Filter vendors by selected category
    final filteredVendors = vendors.where((v) {
      if (_selectedCategory == 'Other') {
        // Find vendors who have 'Other' or no matching category in system categories
        return v.products.any(
          (p) =>
              p.categoryType == 'Other' ||
              !AppConstants.serviceCategories.contains(p.categoryType),
        );
      }
      return v.products.any((p) => p.categoryType == _selectedCategory);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        title: const Text(
          'Vendors by Category',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF904CC1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Category Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.serviceCategories.length,
                itemBuilder: (context, index) {
                  final cat = AppConstants.serviceCategories[index];
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        }
                      },
                      selectedColor: const Color(0xFF904CC1),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Vendor List
          Expanded(
            child: filteredVendors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No vendors found for $_selectedCategory',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredVendors.length,
                    itemBuilder: (context, index) {
                      final vendor = filteredVendors[index];
                      return _buildVendorCard(context, vendor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(BuildContext context, UserModel vendor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFF904CC1).withOpacity(0.1),
          child: const Icon(Icons.store, color: Color(0xFF904CC1)),
        ),
        title: Text(
          vendor.businessName ?? vendor.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              vendor.location ?? 'No location',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: vendor.status == 'approved'
                    ? Colors.green[50]
                    : Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                vendor.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: vendor.status == 'approved'
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VendorDetailAdminView(vendorUser: vendor),
            ),
          );
        },
      ),
    );
  }
}
