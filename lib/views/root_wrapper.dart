import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'admin/admin_dashboard_view.dart';
import 'user/user_dashboard_view.dart';
import 'vendor/vendor_dashboard_view.dart';

class RootWrapper extends StatelessWidget {
  const RootWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.userModel == null) {
      return const LoginScreen();
    }

    // Role-based navigation
    switch (authProvider.userModel!.role) {
      case 'admin':
        return const AdminDashboardView();
      case 'vendor':
        return const VendorDashboardView();
      case 'user':
        return const UserDashboardView();
      default:
        return const LoginScreen();
    }
  }
}
