import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vendor_model.dart';
import '../../models/booking_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/image_helper.dart';
import '../../providers/locale_provider.dart';
import 'package:intl/intl.dart';
import '../common/chat_view.dart';
import '../../providers/chat_provider.dart';

class ProductDetailView extends StatefulWidget {
  final ProductModel product;
  final VendorModel vendor;
  const ProductDetailView({super.key, required this.product, required this.vendor});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  int _currentImageIndex = 0;
  DateTime? _selectedDate;
  DateTime _focusedDate = DateTime.now();
  int _personCount = 1;
  final TextEditingController _occasionController = TextEditingController();

  bool _isDateBlocked(DateTime date) {
    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    return widget.product.blockedDates.contains(dateStr) || 
           widget.product.bookedDates.contains(dateStr);
  }

  double get _totalPrice {
    double basePrice = double.tryParse(widget.product.price) ?? 0.0;
    if (widget.product.priceType == 'per_person') {
      return basePrice * _personCount;
    }
    return basePrice;
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LocaleProvider>();
    final userProvider = context.watch<UserProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: widget.product.images.length,
                    onPageChanged: (index) => setState(() => _currentImageIndex = index),
                    itemBuilder: (context, index) => ImageHelper.displayImage(
                      widget.product.images[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (widget.product.images.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: widget.product.images.asMap().entries.map((entry) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(_currentImageIndex == entry.key ? 0.9 : 0.4),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
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
                            Text(widget.product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  widget.product.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${widget.product.ratings.length} reviews)',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${widget.product.price}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF904CC1)),
                          ),
                          Text(
                            widget.product.priceType == 'per_person' ? 'per person' : 'fixed price',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (widget.product.capacity != null || widget.product.mobileNumber != null || widget.product.location != null) ...[
                    const Text('Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildInfoTile(Icons.people_outline, 'Capacity: ${widget.product.capacity ?? "N/A"}'),
                    if (widget.product.location != null) _buildInfoTile(Icons.location_on_outlined, widget.product.location!),
                    if (widget.product.mobileNumber != null) _buildInfoTile(Icons.phone_outlined, widget.product.mobileNumber!),
                    const SizedBox(height: 24),
                  ],
                  const Text('Check Availability', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildCalendar(context),
                  const SizedBox(height: 24),
                  if (widget.product.priceType == 'per_person') ...[
                    const Text('Book for People', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildCounterButton(Icons.remove, () => setState(() => _personCount = _personCount > 1 ? _personCount - 1 : 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text('$_personCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        _buildCounterButton(Icons.add, () => setState(() => _personCount++)),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text('Booking Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _occasionController,
                    decoration: InputDecoration(
                      labelText: 'Occasion',
                      hintText: 'e.g. Wedding, Birthday',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
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
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Price', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text('₹${_totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF904CC1))),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF904CC1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF904CC1)),
                      onPressed: () async {
                        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                        String chatId = await chatProvider.startChat(authProvider.userModel!.uid, widget.vendor.vendorId);
                        if (context.mounted) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatView(
                            chatId: chatId, 
                            title: widget.vendor.businessName
                          )));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedDate != null ? () async {
                        final booking = BookingModel(
                          bookingId: '',
                          vendorId: widget.vendor.vendorId,
                          userId: authProvider.userModel!.uid,
                          status: 'requested',
                          bookingDate: _selectedDate!,
                          productName: widget.product.name,
                          productImage: widget.product.images.isNotEmpty ? widget.product.images.first : '',
                          occasion: _occasionController.text.trim().isEmpty ? 'General' : _occasionController.text.trim(),
                        );
                        await userProvider.sendBookingRequest(booking);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Booking request sent successfully!'), backgroundColor: Colors.green),
                          );
                        }
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF904CC1),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Confirm Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    // Calculate the number of days in the focused month
    final lastDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    
    // We want to show a horizontal list of dates for the focused month.
    // If it's the current month, start from today if preferred, but usually calendars show from the 1st.
    // However, to keep it simple and user-friendly, let's show all days of the focused month.

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Color(0xFF904CC1)),
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
                  });
                },
              ),
              Text(DateFormat('MMMM yyyy').format(_focusedDate), style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Color(0xFF904CC1)),
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: lastDayOfMonth,
              itemBuilder: (context, index) {
                DateTime date = DateTime(_focusedDate.year, _focusedDate.month, index + 1);
                
                // Don't allow selecting past dates
                bool isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
                bool blocked = _isDateBlocked(date);
                bool selected = _selectedDate != null && 
                    DateFormat('yyyy-MM-dd').format(_selectedDate!) == DateFormat('yyyy-MM-dd').format(date);

                bool isDisabled = isPast || blocked;

                return GestureDetector(
                  onTap: isDisabled ? null : () => setState(() => _selectedDate = date),
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF904CC1) : (isDisabled ? Colors.grey[100] : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selected ? const Color(0xFF904CC1) : Colors.grey[200]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('E').format(date), style: TextStyle(
                          fontSize: 10, 
                          color: selected ? Colors.white70 : (isDisabled ? Colors.grey[400] : Colors.grey),
                        )),
                        Text(DateFormat('d').format(date), style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          color: selected ? Colors.white : (isDisabled ? Colors.grey[300] : Colors.black),
                        )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
