import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vendor_model.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/chat_provider.dart';
import '../common/chat_view.dart';

class VendorDetailsView extends StatelessWidget {
  final VendorModel vendor;
  const VendorDetailsView({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;
    final userProvider = context.watch<UserProvider>();
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: vendor.logoUrl.isNotEmpty 
                ? Image.network(vendor.logoUrl, fit: BoxFit.cover)
                : Container(color: const Color(0xFF904CC1), child: const Icon(Icons.business, size: 80, color: Colors.white)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vendor.businessName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            Text(vendor.serviceType, style: const TextStyle(color: Color(0xFF904CC1), fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF904CC1)),
                          onPressed: () async {
                            String chatId = await chatProvider.startChat(user!.uid, vendor.vendorId);
                            if (context.mounted) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatView(chatId: chatId)));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('About'),
                  const SizedBox(height: 8),
                  Text(vendor.description, style: const TextStyle(color: Colors.grey, height: 1.5)),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Location'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text(vendor.location, style: const TextStyle(color: Colors.grey))),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Products & Services'),
                  const SizedBox(height: 16),
                  vendor.products.isEmpty
                    ? const Text('No products listed', style: TextStyle(color: Colors.grey))
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: vendor.products.length,
                        itemBuilder: (context, index) {
                          final p = vendor.products[index];
                          return Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: Image.network(p.imageUrl, fit: BoxFit.cover, width: double.infinity))),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                                      const SizedBox(height: 4),
                                      Text('₹${p.price}', style: const TextStyle(color: Color(0xFF904CC1), fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: ElevatedButton(
          onPressed: () => _showBookingDialog(context, vendor, userProvider, user!.uid),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF904CC1),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Book Now', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));

  void _showBookingDialog(BuildContext context, VendorModel vendor, UserProvider userProvider, String userId) {
    final events = userProvider.myEvents;
    if (events.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create an event first!')));
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Event', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...events.map((e) => ListTile(
              title: Text(e.eventName),
              subtitle: Text(e.date),
              onTap: () async {
                final booking = BookingModel(
                  bookingId: '',
                  eventId: e.eventId,
                  vendorId: vendor.vendorId,
                  userId: userId,
                  status: 'pending',
                );
                await userProvider.sendBookingRequest(booking);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request sent to vendor!')));
                }
              },
            )),
          ],
        ),
      ),
    );
  }
}
