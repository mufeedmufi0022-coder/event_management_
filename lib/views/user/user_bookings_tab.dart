import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/booking_model.dart';

class UserBookingsTab extends StatelessWidget {
  const UserBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;
    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        title: const Text('My Bookings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: user.uid)
            .where('isActive', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final bookings = snapshot.data!.docs
              .map((doc) => BookingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings found', style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildBookingCard(context, booking);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Booking ID: #${booking.bookingId.substring(0, 5)}', 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                _buildStatusBadge(booking.status),
              ],
            ),
            const Divider(height: 24),
            if (booking.status == 'quoted' && booking.quotePrice != null) ...[
              const Text('Quotation Received', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text('Total Price: ₹${booking.quotePrice}', style: const TextStyle(fontSize: 20, color: Color(0xFF904CC1), fontWeight: FontWeight.bold)),
              if (booking.quoteNote != null) ...[
                const SizedBox(height: 4),
                Text('Note: ${booking.quoteNote}', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(context, booking.bookingId, 'cancelled'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(context, booking.bookingId, 'accepted'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Text('Booking Details', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Current Status: ${booking.status.toUpperCase()}', style: const TextStyle(color: Colors.blueGrey)),
            ],
          ],
        ),
      ),
    );
  }

  void _updateStatus(BuildContext context, String id, String status) {
    Provider.of<UserProvider>(context, listen: false).updateBookingStatus(id, status);
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
