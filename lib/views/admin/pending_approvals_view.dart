import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';
import '../../core/constants/app_colors.dart';

class PendingApprovalsView extends StatelessWidget {
  const PendingApprovalsView({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    
    // Filter pending vendors only (users no longer need approval)
    final pendingVendors = adminProvider.vendors.where((v) => v.status == 'pending').toList();
    final totalPending = pendingVendors.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF904CC1),
        foregroundColor: Colors.white,
        title: const Text('Vendor Approvals', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _buildPendingList(context, pendingVendors, 'Vendors'),
      bottomNavigationBar: totalPending > 0 ? Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Text(
          'Showing $totalPending pending vendor requests',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ) : null,
    );
  }

  Widget _buildPendingList(BuildContext context, List<UserModel> items, String type) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.done_all_rounded, size: 64, color: Colors.green.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('No pending $type!', style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF904CC1).withOpacity(0.1),
                    child: Text(item.name[0].toUpperCase(), style: const TextStyle(color: Color(0xFF904CC1), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.businessName?.isNotEmpty == true ? item.businessName! : item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(item.email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('PENDING', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.phone_outlined, item.contactNumber ?? 'Contact not provided'),
              if (item.role == 'vendor' && item.serviceType != null) ...[
                _buildInfoRow(Icons.category_outlined, item.serviceType ?? 'N/A'),
                _buildInfoRow(Icons.location_on_outlined, item.location ?? 'N/A'),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.read<AdminProvider>().updateStatus(item.uid, 'blocked'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.read<AdminProvider>().updateStatus(item.uid, 'approved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 13))),
        ],
      ),
    );
  }
}
