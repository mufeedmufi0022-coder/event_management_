import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import 'create_event_view.dart';
import 'vendor_list_view.dart';
import '../../models/event_model.dart';
import 'user_bookings_tab.dart';
import '../common/chat_view.dart';
import '../common/terms_view.dart';
import 'edit_profile_view.dart';
import '../../core/utils/image_helper.dart';
import '../../providers/chat_provider.dart';
import '../../providers/locale_provider.dart';

import 'user_home_tab.dart';

class UserDashboardView extends StatefulWidget {
  const UserDashboardView({super.key});

  @override
  State<UserDashboardView> createState() => _UserDashboardViewState();
}

class _UserDashboardViewState extends State<UserDashboardView> {
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
        Provider.of<UserProvider>(context, listen: false).init(user.uid);
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

  final List<Widget> _tabs = [
    const UserHomeTab(),
    const UserBookingsTab(),
    const ChatListView(),
    const UserProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LocaleProvider>();
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
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.search_rounded), label: lp.get('Explore', 'തിരയുക')),
            BottomNavigationBarItem(icon: const Icon(Icons.assignment_turned_in_outlined), label: lp.get('My Bookings', 'ബുക്കിംഗുകൾ')),
            BottomNavigationBarItem(icon: const Icon(Icons.chat_outlined), label: lp.get('Chats', 'ചാറ്റുകൾ')),
            BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: lp.get('Profile', 'പ്രൊഫൈൽ')),
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

// Deprecated UserHomeTab removed as events are no longer the primary focus.

class UserProfileTab extends StatelessWidget {
  const UserProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;
    final chatProvider = context.read<ChatProvider>();
    final lp = context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        title: Text(lp.get('Profile', 'പ്രൊഫൈൽ')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF904CC1), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: ImageHelper.displayImage(
                        user?.logoUrl ?? '',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileView())),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Color(0xFF904CC1), shape: BoxShape.circle),
                        child: const Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              user?.name ?? 'User',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    Icons.phone_outlined,
                    lp.get('Phone', 'ഫോൺ'),
                    user?.contactNumber ?? lp.get('Not Provided', 'ലഭ്യമല്ല'),
                  ),
                  const Divider(height: 1),
                  _buildProfileTile(
                    Icons.headset_mic_outlined,
                    lp.get('Help with Admin', 'അഡ്മിനുമായി സംസാരിക്കുക'),
                    lp.get('Support Chat', 'സപ്പോർട്ട് ചാറ്റ്'),
                    onTap: () async {
                      if (user != null) {
                        // Using the initialized admin email as UID
                        String adminUid = 'admin@event.com';
                        String chatId = await chatProvider.startChat(user.uid, adminUid);
                        if (context.mounted) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatView(chatId: chatId)));
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileTile(
                    Icons.description_outlined,
                    lp.get('Terms & Conditions', 'നിബന്ധനകളും വ്യവസ്ഥകളും'),
                    lp.get('Read our policies', 'ഞങ്ങളുടെ പോളിസികൾ വായിക്കുക'),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsView())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout),
                label: Text(lp.get('Logout', 'ലോഗൗട്ട്')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF904CC1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF904CC1), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      trailing: onTap != null ? const Icon(Icons.chevron_right, size: 20, color: Colors.grey) : null,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final lp = context.read<LocaleProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lp.get('Logout?', 'ലോഗൗട്ട് ചെയ്യണോ?')),
        content: Text(lp.get('Are you sure you want to log out?', 'നിങ്ങൾക്ക് ലോഗൗട്ട് ചെയ്യണമെന്ന് ഉറപ്പാണോ?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lp.get('Cancel', 'റദ്ദാക്കുക'), style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(lp.get('Logout', 'ലോഗൗട്ട്')),
          ),
        ],
      ),
    );
  }
}
