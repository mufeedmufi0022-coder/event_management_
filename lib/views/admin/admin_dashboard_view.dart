import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';
import '../../models/event_model.dart';
import '../../core/constants/app_colors.dart';
import 'pending_approvals_view.dart';

import '../../models/booking_model.dart';
import '../../models/log_model.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const AdminHomeTab(),
    const PeopleListTab(role: 'user'),
    const PeopleListTab(role: 'vendor'),
    const AdminBookingsTab(),
    const AdminEventsTab(),
    const AdminLogsTab(),
  ];

  final List<String> _titles = [
    'Admin Console',
    'User Directory',
    'Partner Directory',
    'Global Bookings',
    'Event Registry',
    'System Audit Logs',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF904CC1),
        foregroundColor: Colors.white,
        title: Text(_titles[_selectedIndex], style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
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
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF904CC1),
          unselectedItemColor: Colors.grey[400],
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.apps_rounded), label: 'Stats'),
            BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Users'),
            BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Vendors'),
            BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), label: 'Bookings'),
            BottomNavigationBarItem(icon: Icon(Icons.event_available_outlined), label: 'Events'),
            BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Logs'),
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
        content: const Text('Are you sure you want to log out of the admin console?'),
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
}

class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({super.key});

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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
          ),
          const SizedBox(height: 20),
          _buildSummaryCard('Active Users', counts['users'].toString(), Icons.group, const Color(0xFF3498DB)),
          const SizedBox(height: 16),
          _buildSummaryCard('Business Partners', counts['vendors'].toString(), Icons.handshake, const Color(0xFF2ECC71)),
          const SizedBox(height: 16),
          _buildSummaryCard('Managed Events', counts['events'].toString(), Icons.celebration, const Color(0xFFE67E22)),
          const SizedBox(height: 32),
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
          ),
          const SizedBox(height: 16),
          _buildQuickAction(
            context, 
            'Pending Approvals', 
            Icons.pending_actions, 
            Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PendingApprovalsView()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String title, IconData icon, Color color, {VoidCallback? onTap}) {
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
    final people = role == 'user' ? adminProvider.users : adminProvider.vendors;

    if (people.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(role == 'user' ? Icons.person_off : Icons.store_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No ${role}s registered yet.', style: const TextStyle(color: Colors.grey)),
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(
              person.businessName?.isNotEmpty == true ? person.businessName! : person.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.email, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 6),
                _buildStatusBadge(person.status),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (status) => adminProvider.updateStatus(person.uid, status),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'approved', child: Text('Approve Account')),
                const PopupMenuItem(value: 'pending', child: Text('Set Pending')),
                const PopupMenuItem(value: 'blocked', child: Text('Block Access')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'approved': color = Colors.green; break;
      case 'blocked': color = Colors.red; break;
      default: color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class AdminEventsTab extends StatelessWidget {
  const AdminEventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final events = context.watch<AdminProvider>().eventsList;

    if (events.isEmpty) {
      return const Center(child: Text('No events created yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.celebration, color: Colors.purple),
            ),
            title: Text(event.eventName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${event.eventType} • ${event.location}\nDate: ${event.date}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            title: Text('Booking #${b.bookingId.substring(0, 5)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('User: ${b.userId.substring(0,5)} | Vendor: ${b.vendorId.substring(0,5)}\nStatus: ${b.status.toUpperCase()}'),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.settings_suggest_outlined),
              onSelected: (val) => provider.manualOverrideBooking(b.bookingId, val),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'accepted', child: Text('Force Accept')),
                const PopupMenuItem(value: 'cancelled', child: Text('Force Cancel')),
                const PopupMenuItem(value: 'completed', child: Text('Mark Complete')),
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
                    Text(log.action, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
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
