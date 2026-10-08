import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../login/login_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/edit_profile_screen.dart';
import 'donation_history_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserModel? _user;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageService.getUser();
    setState(() => _user = user);
  }


  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.water_drop, color: AppColors.primary),
              SizedBox(width: 8),
              Text('BloodBridge v1.0.0', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
          content: const Text(
            'BloodBridge is a real-time healthcare blood donor search platform connecting donors and patients across India.\n\n'
            '• Frontend: Flutter\n'
            '• Backend: PHP REST API\n'
            '• Database: XAMPP MySQL (bloodconnect_db)\n'
            '• Map: Google Maps (Roadmap / Satellite / Terrain)\n\n'
            'Developed with medical care & high precision.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to log out of BloodBridge?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings & Account', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            if (_user != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primarySoft,
                      child: Text(
                        _user!.bloodGroup,
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _user!.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                          Text(
                            '+91 ${_user!.mobileNumber}',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          Text(
                            '${_user!.area}, ${_user!.district}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // Profile Section
            _buildSectionHeader('Profile & Records'),
            _buildTile(
              icon: Icons.person_outline,
              title: 'My Profile',
              subtitle: 'View your public donor card and eligibility',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),
            _buildTile(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              subtitle: 'Update address, availability, blood group',
              onTap: () async {
                if (_user != null) {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(user: _user!)));
                  _loadUser();
                }
              },
            ),
            _buildTile(
              icon: Icons.history,
              title: 'Donation History',
              subtitle: 'Track your lifetime donations & certificates',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationHistoryScreen()));
              },
            ),


            const SizedBox(height: 16),
            // App Settings
            _buildSectionHeader('App Settings & Privacy'),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.textSecondary),
              title: const Text('Emergency Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: const Text('Get alerts for nearby critical blood requests', style: TextStyle(fontSize: 12)),
              value: _notificationsEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
            _buildTile(
              icon: Icons.lock_outline,
              title: 'Location Privacy',
              subtitle: 'Approximate donor pins shown to protect exact home address',
              onTap: () {},
            ),

            const SizedBox(height: 16),
            // Account & About
            _buildSectionHeader('About & Account'),
            _buildTile(
              icon: Icons.info_outline,
              title: 'About BloodBridge',
              subtitle: 'Version 1.0.0 (Production Build)',
              onTap: _showAboutDialog,
            ),
            _buildTile(
              icon: Icons.logout,
              title: 'Log Out',
              subtitle: 'Sign out from this device',
              color: Colors.red,
              onTap: _handleLogout,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? color,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon, color: color ?? AppColors.textSecondary, size: 22),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color ?? AppColors.textPrimary)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
          onTap: onTap,
        ),
      ),
    );
  }
}
