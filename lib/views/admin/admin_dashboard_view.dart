import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';
import '../../models/event_model.dart';
import '../../core/constants/app_colors.dart';
import 'pending_approvals_view.dart';

import 'package:fl_chart/fl_chart.dart';
import '../../models/booking_model.dart';
import '../../models/log_model.dart';
import 'vendor_detail_admin_view.dart';
import '../common/chat_view.dart';
import '../../providers/chat_provider.dart';
import '../../core/utils/image_helper.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  List<Widget> _getScreens() {
    return [
      AdminHomeTab(onTabChange: _onItemTapped),
      const AdminBookingsTab(),
      const ChatListView(),
      const AdminLogsTab(),
    ];
  }

  final List<String> _titles = [
    'Admin Console',
    'Global Bookings',
    'Support Chats',
    'System Audit Logs',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF904CC1),
        foregroundColor: Colors.white,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showExitDialog(context),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          _showExitDialog(context);
        },
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _getScreens(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF904CC1),
          unselectedItemColor: Colors.grey[400],
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.apps_rounded),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Support',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'Logs',
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
        title: const Text('Exit Session?'),
        content: const Text(
          'Are you sure you want to log out of the admin console?',
        ),
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
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class AdminHomeTab extends StatelessWidget {
  final Function(int)? onTabChange;
  const AdminHomeTab({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final counts = context.watch<AdminProvider>().counts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Overview',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 20),
          _buildSummaryCard(
            'Active Users',
            counts['users'].toString(),
            Icons.group,
            const Color(0xFF3498DB),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const DirectoryPage(role: 'user', title: 'User Directory'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Business Partners',
            counts['vendors'].toString(),
            Icons.handshake,
            const Color(0xFF2ECC71),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DirectoryPage(
                  role: 'vendor',
                  title: 'Partner Directory',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildBookingChart(context),
          const SizedBox(height: 32),
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickAction(
            context,
            'Pending Approvals',
            Icons.pending_actions,
            Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PendingApprovalsView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingChart(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final bookings = adminProvider.allBookings;
    final users = adminProvider.allUsers;

    // Map vendor IDs to categories and get all unique categories in system
    final systemCategories = users
        .where((u) => u.role == 'vendor')
        .expand((u) => u.products.map((p) => p.categoryType))
        .where((c) => c != null && c.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    if (systemCategories.isEmpty) systemCategories.add('Services');

    final vendorCategories = {
      for (var u in users.where((u) => u.role == 'vendor'))
        u.uid:
            u.products
                .map((p) => p.categoryType)
                .where((c) => c != null && c.isNotEmpty)
                .toSet()
                .join(', ')
                .isEmpty
            ? 'General'
            : u.products
                  .map((p) => p.categoryType)
                  .where((c) => c != null && c.isNotEmpty)
                  .toSet()
                  .first,
    };

    // Group bookings by category
    final categoryCounts = {for (var cat in systemCategories) cat: 0};
    for (var b in bookings) {
      final category = vendorCategories[b.vendorId] ?? 'Other';
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    final sortedCategories = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      const Color(0xFF904CC1),
      const Color(0xFF3498DB),
      const Color(0xFF2ECC71),
      const Color(0xFFE67E22),
      const Color(0xFFF1C40F),
      const Color(0xFFE74C3C),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Volume by business category',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: bookings.isEmpty
                    ? [
                        PieChartSectionData(
                          color: Colors.grey[200],
                          value: 1,
                          title: '0%',
                          radius: 50,
                          titleStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                          ),
                        ),
                      ]
                    : sortedCategories
                          .where((e) => e.value > 0)
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                            final idx = entry.key;
                            final category = entry.value.key;
                            final count = entry.value.value;
                            final percentage = (count / bookings.length * 100)
                                .toStringAsFixed(1);

                            return PieChartSectionData(
                              color: colors[idx % colors.length],
                              value: count.toDouble(),
                              title: '$percentage%',
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          })
                          .toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: sortedCategories.asMap().entries.map((entry) {
              final idx = entry.key;
              final category = entry.value.key;
              final count = entry.value.value;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[idx % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$category ($count)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String title,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class PeopleListTab extends StatelessWidget {
  final String role;
  const PeopleListTab({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    List<UserModel> people;
    if (role == 'user') {
      people = adminProvider.users;
    } else if (role == 'vendor') {
      people = adminProvider.vendors;
    } else {
      people = adminProvider.allUsers;
    }

    if (people.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              role == 'user'
                  ? Icons.person_off
                  : (role == 'vendor'
                        ? Icons.store_outlined
                        : Icons.storage_rounded),
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${role == 'all' ? 'records' : role + 's'} found.',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Total records in system: ${adminProvider.allUsers.length}',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: people.length,
      itemBuilder: (context, index) {
        final person = people[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            leading: CircleAvatar(
              backgroundColor: role == 'user'
                  ? Colors.blue[50]
                  : Colors.purple[50],
              child: Icon(
                role == 'user' ? Icons.person : Icons.store,
                color: role == 'user' ? Colors.blue : Colors.purple,
              ),
            ),
            title: Text(
              person.businessName?.isNotEmpty == true
                  ? person.businessName!
                  : person.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (role == 'vendor' && person.products.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        person.products
                            .map((p) => p.categoryType)
                            .where((c) => c != null && c.isNotEmpty)
                            .toSet()
                            .join(', '),
                        style: const TextStyle(
                          color: Color(0xFF904CC1),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          person.email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        person.contactNumber ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (role == 'vendor' && person.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            person.location!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  _buildStatusBadge(person.status),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFF904CC1),
                  ),
                  onPressed: () async {
                    final chatProvider = Provider.of<ChatProvider>(
                      context,
                      listen: false,
                    );
                    final admin = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).userModel;
                    if (admin != null) {
                      String chatId = await chatProvider.startChat(
                        admin.uid,
                        person.uid,
                      );
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatView(
                              chatId: chatId,
                              title: person.businessName?.isNotEmpty == true
                                  ? person.businessName
                                  : person.name,
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (status) =>
                      adminProvider.updateStatus(person.uid, status),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'approved',
                      child: Text('Approve Account'),
                    ),
                    const PopupMenuItem(
                      value: 'pending',
                      child: Text('Set Pending'),
                    ),
                    const PopupMenuItem(
                      value: 'blocked',
                      child: Text('Block Access'),
                    ),
                  ],
                ),
              ],
            ),
            onTap: role == 'vendor'
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VendorDetailAdminView(vendorUser: person),
                      ),
                    );
                  }
                : null,
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

// Obsolete AdminEventsTab removed

class AdminBookingsTab extends StatelessWidget {
  const AdminBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final bookings = provider.allBookings;

    if (bookings.isEmpty) {
      return const Center(child: Text('No bookings in system'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final b = bookings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (b.productImage != null && b.productImage!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ImageHelper.displayImage(
                      b.productImage,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.productName ?? 'Event Service',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'User: ${b.userId.substring(0, 5)} | Vendor: ${b.vendorId.substring(0, 5)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Status: ${b.status.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF904CC1),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.person_search_outlined,
                        color: Colors.blue,
                        size: 20,
                      ),
                      onPressed: () async {
                        final chatProvider = Provider.of<ChatProvider>(
                          context,
                          listen: false,
                        );
                        final adminId = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).userModel?.uid;
                        if (adminId != null) {
                          String chatId = await chatProvider.startChat(
                            adminId,
                            b.userId,
                          );
                          if (context.mounted)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatView(
                                  chatId: chatId,
                                  title: 'Chat with User',
                                ),
                              ),
                            );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.storefront_outlined,
                        color: Colors.purple,
                        size: 20,
                      ),
                      onPressed: () async {
                        final chatProvider = Provider.of<ChatProvider>(
                          context,
                          listen: false,
                        );
                        final adminId = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).userModel?.uid;
                        if (adminId != null) {
                          String chatId = await chatProvider.startChat(
                            adminId,
                            b.vendorId,
                          );
                          if (context.mounted)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatView(
                                  chatId: chatId,
                                  title: 'Chat with Vendor',
                                ),
                              ),
                            );
                        }
                      },
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.settings_suggest_outlined,
                        size: 20,
                      ),
                      onSelected: (val) =>
                          provider.manualOverrideBooking(b.bookingId, val),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'accepted',
                          child: Text('Force Accept'),
                        ),
                        const PopupMenuItem(
                          value: 'cancelled',
                          child: Text('Force Cancel'),
                        ),
                        const PopupMenuItem(
                          value: 'completed',
                          child: Text('Mark Complete'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AdminLogsTab extends StatelessWidget {
  const AdminLogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<AdminProvider>().logs;

    if (logs.isEmpty) {
      return const Center(child: Text('No system logs found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.history, size: 16, color: Colors.blue[300]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.action,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${log.type.toUpperCase()} • ${log.timestamp.toLocal().toString().split('.')[0]}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DirectoryPage extends StatelessWidget {
  final String role;
  final String title;
  const DirectoryPage({super.key, required this.role, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF904CC1),
        foregroundColor: Colors.white,
      ),
      body: PeopleListTab(role: role),
    );
  }
}
