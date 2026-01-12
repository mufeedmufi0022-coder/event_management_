import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../models/vendor_model.dart';
import '../../models/booking_model.dart';
import 'edit_business_view.dart';
import 'vendor_availability_tab.dart';
import '../common/chat_view.dart';
import '../user/vendor_details_view.dart';
import '../../core/utils/image_helper.dart';
import '../../providers/chat_provider.dart';

class VendorDashboardView extends StatefulWidget {
  const VendorDashboardView({super.key});

  @override
  State<VendorDashboardView> createState() => _VendorDashboardViewState();
}

class _VendorDashboardViewState extends State<VendorDashboardView> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).userModel;
      if (user != null) {
        Provider.of<VendorProvider>(context, listen: false).init(user.uid);
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = context.watch<VendorProvider>();
    
    if (vendorProvider.vendorModel == null && !vendorProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Setup Business')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.business, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                const Text('Set up your business profile to start receiving bookings!',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditBusinessView()),
                  ),
                  child: const Text('Complete Profile'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final List<Widget> _tabs = [
      const BookingRequestsTab(),
      const VendorAvailabilityTab(),
      const ChatListView(),
      const VendorProfileTab(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _showExitDialog(context);
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _tabs,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xFF904CC1),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Requests'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Availability'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), label: 'Chats'),
            BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App?'),
        content: const Text('Do you want to exit the application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

class BookingRequestsTab extends StatelessWidget {
  const BookingRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorProvider>();
    final bookings = provider.bookings;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        title: const Text('Booking Requests', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: bookings.isEmpty
          ? const Center(child: Text('No booking requests yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _buildBookingItem(context, booking, provider);
              },
            ),
    );
  }

  Widget _buildBookingItem(BuildContext context, BookingModel booking, VendorProvider provider) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Booking ID: #${booking.bookingId.length > 5 ? booking.bookingId.substring(0, 5) : booking.bookingId}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                _buildStatusBadge(booking.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (booking.productImage != null && booking.productImage!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ImageHelper.displayImage(booking.productImage, width: 70, height: 70, fit: BoxFit.cover),
                  )
                else
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.productName ?? 'Service Ordered',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 12, color: Color(0xFF904CC1)),
                          const SizedBox(width: 4),
                          Text(
                            '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.celebration, size: 12, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            booking.occasion ?? 'General',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (booking.status == 'requested') ...[
              const Text('Action Required', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => provider.updateBookingStatus(booking.bookingId, 'cancelled'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showQuoteDialog(context, booking.bookingId, provider),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF904CC1), foregroundColor: Colors.white),
                      child: const Text('Send Quote'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text('Details: ${booking.status.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w500)),
              if (booking.quotePrice != null) ...[
                const SizedBox(height: 4),
                Text('Quoted Price: ₹${booking.quotePrice}', style: const TextStyle(color: Color(0xFF904CC1), fontWeight: FontWeight.bold)),
              ],
              if (booking.status == 'accepted') 
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ElevatedButton(
                    onPressed: () => provider.updateBookingStatus(booking.bookingId, 'completed'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 36)),
                    child: const Text('Mark as Completed'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showQuoteDialog(BuildContext context, String bookingId, VendorProvider provider) {
    final priceController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Quotation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Total Price (₹)', hintText: 'e.g. 5000'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Optional Note', hintText: 'Delivery included...'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (priceController.text.isNotEmpty) {
                provider.sendQuotation(bookingId, priceController.text.trim(), noteController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'requested': color = Colors.orange; break;
      case 'quoted': color = Colors.blue; break;
      case 'accepted': color = Colors.green; break;
      case 'completed': color = Colors.teal; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class VendorProfileTab extends StatelessWidget {
  const VendorProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vendor = context.watch<VendorProvider>().vendorModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile'),
        actions: [
          IconButton(
            onPressed: () {
              if (vendor != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VendorDetailsView(vendor: vendor)),
                );
              }
            },
            icon: const Icon(Icons.visibility_outlined),
            tooltip: 'Preview Profile',
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditBusinessView()),
            ),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Business Registry',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditBusinessView()),
        ),
        icon: const Icon(Icons.shopping_bag_outlined),
        label: const Text('Add Product'),
        backgroundColor: const Color(0xFF904CC1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50, 
              backgroundColor: Colors.white,
              backgroundImage: vendor?.logoUrl != null && vendor!.logoUrl.isNotEmpty 
                ? ImageHelper.getImageProvider(vendor.logoUrl) 
                : null,
              child: (vendor?.logoUrl == null || vendor!.logoUrl.isEmpty) 
                ? const Icon(Icons.store, size: 50, color: Color(0xFF904CC1)) 
                : null,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditBusinessView()),
              ),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit Identity'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF904CC1)),
            ),
            const SizedBox(height: 16),
            Text(vendor?.businessName ?? 'No Name',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(vendor?.serviceType ?? 'No Type', style: const TextStyle(color: Color(0xFF904CC1), fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            _buildInfoRow(Icons.location_on_outlined, vendor?.location ?? 'No location'),
            _buildInfoRow(Icons.phone_outlined, vendor?.contactNumber ?? 'No contact number'),
            _buildInfoRow(Icons.payments_outlined, vendor?.priceRange ?? 'No price range'),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('About Business', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                vendor?.description ?? 'No description provided.',
                style: const TextStyle(color: Colors.grey, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.headset_mic_outlined, color: Colors.blue),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Need Assistance?', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Chat with system admin for support', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final user = Provider.of<AuthProvider>(context, listen: false).userModel;
                      if (user != null) {
                        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                        String chatId = await chatProvider.startChat(user.uid, 'admin@event.com');
                        if (context.mounted) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatView(chatId: chatId, title: 'Admin Support')));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: const Text('Chat'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('My Products & Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            if (vendor?.products == null || vendor!.products.isEmpty)
              const Text('No products added yet', style: TextStyle(color: Colors.grey))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: vendor.products.length,
                itemBuilder: (context, index) {
                  final p = vendor.products[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(12), 
                      border: Border.all(color: Colors.grey[200]!)
                    ),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VendorDetailsView(vendor: vendor)),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), 
                                  child: ImageHelper.displayImage(p.imageUrl, fit: BoxFit.cover, width: double.infinity)
                                )
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1),
                                    Text('₹${p.price}', style: const TextStyle(color: Color(0xFF904CC1), fontSize: 13, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white.withOpacity(0.9),
                              child: IconButton(
                                icon: const Icon(Icons.edit, size: 14, color: Color(0xFF904CC1)),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const EditBusinessView()),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
