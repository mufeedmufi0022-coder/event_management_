import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class VendorStatusView extends StatelessWidget {
  final String status;
  const VendorStatusView({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(),
              const SizedBox(height: 32),
              Text(
                _getTitle(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _getMessage(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              if (status == 'denied' || status == 'rejected')
                ElevatedButton(
                  onPressed: () {
                    // Maybe email support?
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Contact Support'),
                )
              else
                 ElevatedButton(
                  onPressed: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF904CC1),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Logout'),
                ),
                const SizedBox(height: 16),
                if (status == 'pending')
                    TextButton(
                        onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
                        child: const Text('Login with different account', style: TextStyle(color: Colors.grey)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (status) {
      case 'pending':
        return const Icon(Icons.hourglass_empty_rounded, size: 100, color: Colors.orange);
      case 'denied':
      case 'rejected':
      case 'blocked':
        return const Icon(Icons.block_flipped, size: 100, color: Colors.red);
      default:
        return const Icon(Icons.info_outline, size: 100, color: Colors.blue);
    }
  }

  String _getTitle() {
    switch (status) {
      case 'pending':
        return 'Registration Pending';
      case 'denied':
      case 'rejected':
        return 'Application Denied';
      case 'blocked':
        return 'Account Blocked';
      default:
        return 'Account Status';
    }
  }

  String _getMessage() {
    switch (status) {
      case 'pending':
        return 'Your vendor application is currently under review by our admin team. We will notify you once it is approved.';
      case 'denied':
      case 'rejected':
        return 'Unfortunately, your vendor application has been denied at this time. Please contact support for more details.';
      case 'blocked':
        return 'Your account has been deactivated by the administrator. You can no longer access the vendor dashboard.';
      default:
        return 'There is an issue with your account status. Please contact the administrator.';
    }
  }
}
