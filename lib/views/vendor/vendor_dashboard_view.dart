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
import '../common/location_map_view.dart';
import 'package:latlong2/latlong.dart';
import 'package:fl_chart/fl_chart.dart';

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
                const Text(
                  'Set up your business profile to start receiving bookings!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditBusinessView(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
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
      const VendorHomeTab(), // New Home Tab
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
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Requests'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Availability',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Profile',
            ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 40),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

class VendorHomeTab extends StatelessWidget {
  const VendorHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorProvider>();
    final bookings = provider.bookings;
    final vendor = provider.vendorModel;

    // Summary Statistics
    final totalBookings = bookings.length;
    final pendingBookings = bookings
        .where((b) => b.status == 'requested')
        .length;
    final acceptedBookings = bookings
        .where((b) => b.status == 'accepted')
        .length;
    final completedBookings = bookings
        .where((b) => b.status == 'completed')
        .length;

    // Get Recent Feedback
    final allRatings = vendor?.products.expand((p) => p.ratings).toList() ?? [];
    allRatings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final recentRatings = allRatings.take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        title: const Text(
          'Business Console',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Summary Cards
            Row(
              children: [
                _buildStatCard('Total', totalBookings.toString(), Colors.blue),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Pending',
                  pendingBookings.toString(),
                  Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Success',
                  completedBookings.toString(),
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Analytics Chart
            _buildVendorChart(bookings),
            const SizedBox(height: 24),

            // Recent Requests heading
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (bookings.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No recent activities'),
                ),
              )
            else
              ...bookings.take(2).map((b) => _buildMiniBooking(b)),

            const SizedBox(height: 24),
            // Recent Feedbacks heading
            const Text(
              'Customer Feedback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (recentRatings.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No reviews received yet'),
                ),
              )
            else
              ...recentRatings.map((r) => _buildRatingItem(r)),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorChart(List<BookingModel> bookings) {
    final statusCounts = {
      'requested': 0,
      'quoted': 0,
      'accepted': 0,
      'completed': 0,
      'cancelled': 0,
    };
    for (var b in bookings) {
      if (statusCounts.containsKey(b.status)) {
        statusCounts[b.status] = statusCounts[b.status]! + 1;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Distribution',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (bookings.length / 2 + 5).toDouble(),
                barTouchData: BarTouchData(enabled: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: [
                  _makeBarGroup(
                    0,
                    statusCounts['requested']!.toDouble(),
                    Colors.orange,
                  ),
                  _makeBarGroup(
                    1,
                    statusCounts['quoted']!.toDouble(),
                    Colors.blue,
                  ),
                  _makeBarGroup(
                    2,
                    statusCounts['accepted']!.toDouble(),
                    Colors.yellow,
                  ),
                  _makeBarGroup(
                    3,
                    statusCounts['completed']!.toDouble(),
                    Colors.green,
                  ),
                  _makeBarGroup(
                    4,
                    statusCounts['cancelled']!.toDouble(),
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegend('Pend', Colors.orange),
              _buildLegend('Quot', Colors.blue),
              _buildLegend('Acce', Colors.yellow),
              _buildLegend('Done', Colors.green),
              _buildLegend('Canc', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMiniBooking(BookingModel b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_outlined, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.productName ?? 'New Request',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Status: ${b.status}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${b.bookingDate.day}/${b.bookingDate.month}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingItem(RatingModel r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                r.userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    size: 14,
                    color: i < r.stars ? Colors.amber : Colors.grey[300],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            r.comment,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            '${r.timestamp.day}/${r.timestamp.month}/${r.timestamp.year}',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
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
        title: const Text(
          'Booking Requests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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

  Widget _buildBookingItem(
    BuildContext context,
    BookingModel booking,
    VendorProvider provider,
  ) {
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
                Text(
                  'Booking ID: #${booking.bookingId.length > 5 ? booking.bookingId.substring(0, 5) : booking.bookingId}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                _buildStatusBadge(booking.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (booking.productImage != null &&
                    booking.productImage!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ImageHelper.displayImage(
                      booking.productImage,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.productName ?? 'Service Ordered',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Color(0xFF904CC1),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.celebration,
                            size: 12,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking.occasion ?? 'General',
                            style: TextStyle(
                              color: Colors.grey[600],
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
            const SizedBox(height: 16),
            if (booking.status == 'requested') ...[
              const Text(
                'Action Required',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => provider.updateBookingStatus(
                        booking.bookingId,
                        'cancelled',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showQuoteDialog(
                        context,
                        booking.bookingId,
                        provider,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF904CC1),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Send Quote'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'Details: ${booking.status.toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (booking.quotePrice != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Quoted Price: ₹${booking.quotePrice}',
                  style: const TextStyle(
                    color: Color(0xFF904CC1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              if (booking.status == 'accepted')
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ElevatedButton(
                    onPressed: () => provider.updateBookingStatus(
                      booking.bookingId,
                      'completed',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 36),
                    ),
                    child: const Text('Mark as Completed'),
                  ),
                ),
              if (booking.status == 'completed' && booking.hasFeedback)
                _buildFeedbackDisplay(booking, provider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackDisplay(BookingModel booking, VendorProvider provider) {
    // Find the rating matching this booking context
    final product = provider.vendorModel?.products.firstWhere(
      (p) => p.name == booking.productName,
      orElse: () => provider.vendorModel!.products.first,
    );
    final rating = product?.ratings.firstWhere(
      (r) =>
          r.userName != 'Anonymous' &&
          r.timestamp.isAfter(booking.bookingDate), // Simple logic to match
      orElse: () => product.ratings.last,
    );

    if (rating == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                'Customer Feedback',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.amber[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rating.comment,
            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                Icons.star,
                size: 12,
                color: i < rating.stars ? Colors.amber : Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuoteDialog(
    BuildContext context,
    String bookingId,
    VendorProvider provider,
  ) {
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
              decoration: const InputDecoration(
                labelText: 'Total Price (₹)',
                hintText: 'e.g. 5000',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Optional Note',
                hintText: 'Delivery included...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (priceController.text.isNotEmpty) {
                provider.sendQuotation(
                  bookingId,
                  priceController.text.trim(),
                  noteController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'requested':
        color = Colors.orange;
        break;
      case 'quoted':
        color = Colors.blue;
        break;
      case 'accepted':
        color = Colors.green;
        break;
      case 'completed':
        color = Colors.teal;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
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
                  MaterialPageRoute(
                    builder: (context) => VendorDetailsView(vendor: vendor),
                  ),
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
              backgroundImage:
                  vendor?.logoUrl != null && vendor!.logoUrl.isNotEmpty
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
                MaterialPageRoute(
                  builder: (context) => const EditBusinessView(),
                ),
              ),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit Identity'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF904CC1),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              vendor?.businessName ?? 'No Name',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              vendor?.products
                      .map((p) => p.categoryType)
                      .where((c) => c != null && c.isNotEmpty)
                      .toSet()
                      .join(', ') ??
                  'No Type',
              style: const TextStyle(
                color: Color(0xFF904CC1),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 32),
            _buildInfoRow(
              Icons.location_on_outlined,
              vendor?.location ?? 'No location',
            ),
            _buildInfoRow(
              Icons.phone_outlined,
              vendor?.contactNumber ?? 'No contact number',
            ),
            _buildInfoRow(
              Icons.payments_outlined,
              vendor?.priceRange ?? 'No price range',
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About Business',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
                        Text(
                          'Need Assistance?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Chat with system admin for support',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final user = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).userModel;
                      if (user != null) {
                        final chatProvider = Provider.of<ChatProvider>(
                          context,
                          listen: false,
                        );
                        String chatId = await chatProvider.startChat(
                          user.uid,
                          'admin@event.com',
                        );
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatView(
                                chatId: chatId,
                                title: 'Admin Support',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text('Chat'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Products & Services',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            if (vendor?.products == null || vendor!.products.isEmpty)
              const Text(
                'No products added yet',
                style: TextStyle(color: Colors.grey),
              )
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
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VendorDetailsView(vendor: vendor),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: ImageHelper.displayImage(
                                    p.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                    ),
                                    Text(
                                      '₹${p.price}',
                                      style: const TextStyle(
                                        color: Color(0xFF904CC1),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (p.latitude != null && p.longitude != null)
                            Positioned(
                              top: 4,
                              left: 4,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.white.withOpacity(0.9),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.map_outlined,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LocationMapView(
                                          latLng: LatLng(
                                            p.latitude!,
                                            p.longitude!,
                                          ),
                                          title: p.name,
                                          address: p.location ?? 'No address',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white.withOpacity(0.9),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: Color(0xFF904CC1),
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EditBusinessView(),
                                  ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 40),
            ),
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
          Expanded(
            child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
