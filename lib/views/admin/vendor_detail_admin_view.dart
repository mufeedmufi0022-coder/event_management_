import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/vendor_model.dart';
import '../../core/utils/image_helper.dart';

class VendorDetailAdminView extends StatelessWidget {
  final UserModel vendorUser;
  const VendorDetailAdminView({super.key, required this.vendorUser});

  @override
  Widget build(BuildContext context) {
    // Map UserModel fields to a more comprehensive display
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        title: const Text(
          'Vendor Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF904CC1).withOpacity(0.1),
                    backgroundImage: vendorUser.images.isNotEmpty
                        ? ImageHelper.getImageProvider(vendorUser.images.first)
                        : null,
                    child: vendorUser.images.isEmpty
                        ? const Icon(
                            Icons.store,
                            size: 40,
                            color: Color(0xFF904CC1),
                          )
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendorUser.businessName ?? vendorUser.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          vendorUser.products
                                  .map((p) => p.categoryType)
                                  .where((c) => c != null && c.isNotEmpty)
                                  .toSet()
                                  .join(', ')
                                  .isEmpty
                              ? 'No Service Type'
                              : vendorUser.products
                                    .map((p) => p.categoryType)
                                    .where((c) => c != null && c.isNotEmpty)
                                    .toSet()
                                    .join(', '),
                          style: const TextStyle(
                            color: Color(0xFF904CC1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildStatusChip(vendorUser.status),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Contact Information
            const Text(
              'Contact & Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailCard([
              _buildDetailItem(
                Icons.email_outlined,
                'Email Address',
                vendorUser.email,
              ),
              _buildDetailItem(
                Icons.phone_outlined,
                'Contact Number',
                vendorUser.contactNumber ?? 'Not provided',
              ),
              _buildDetailItem(
                Icons.location_on_outlined,
                'Service Location',
                vendorUser.location ?? 'Not provided',
              ),
            ]),
            const SizedBox(height: 32),

            // Business Details
            const Text(
              'Business Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailCard([
              _buildDetailItem(
                Icons.payments_outlined,
                'Price Range',
                vendorUser.priceRange ?? 'Not provided',
              ),
              _buildDetailItem(
                Icons.description_outlined,
                'Description',
                vendorUser.description ?? 'No description provided',
              ),
            ]),
            const SizedBox(height: 32),

            // Gallery (If any images exist)
            if (vendorUser.images.isNotEmpty) ...[
              const Text(
                'Gallery',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: vendorUser.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ImageHelper.displayImage(
                          vendorUser.images[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Products Section
            if (vendorUser.products.isNotEmpty) ...[
              const Text(
                'Products & Services',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vendorUser.products.length,
                itemBuilder: (context, index) {
                  final product = vendorUser.products[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ImageHelper.displayImage(
                            product.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₹${product.price}',
                                style: const TextStyle(
                                  color: Color(0xFF904CC1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],

            // Note: In a real app we might also fetch and display products list here.
            // Since we only have the UserModel here, we display what we have.
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[400], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'approved':
        color = Colors.green;
        break;
      case 'blocked':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
