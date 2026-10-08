import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/donor_model.dart';
import '../../models/history_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'edit_profile_screen.dart';
import '../settings/donation_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int? donorId;
  final DonorModel? donor;

  const ProfileScreen({super.key, this.donorId, this.donor});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _profile;
  List<DonationHistoryModel> _history = [];
  bool _isLoading = true;
  bool _isOwnProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final currentUser = await StorageService.getUser();
    final targetId = widget.donor?.id ?? widget.donorId;

    // Check if viewing own profile
    _isOwnProfile = (targetId == null || (currentUser != null && targetId == currentUser.id));

    // If viewing own profile
    if (_isOwnProfile) {
      if (currentUser != null) {
        setState(() {
          _profile = currentUser;
          _isLoading = false;
        });
      }
      final res = await ApiService.getProfile();
      final histRes = await ApiService.getHistory();
      if (!mounted) return;
      setState(() {
        if (res.success && res.data != null) {
          _profile = res.data;
        }
        _history = histRes.data ?? [];
        _isLoading = false;
      });
      return;
    }

    // If viewing another donor's profile:
    // If a DonorModel was passed directly, show it immediately so there is zero delay!
    if (widget.donor != null) {
      final d = widget.donor!;
      _profile = UserModel(
        id: d.id,
        fullName: d.fullName,
        mobileNumber: d.mobileNumber,
        email: d.email,
        gender: d.gender,
        bloodGroup: d.bloodGroup,
        address: d.address,
        state: d.state,
        district: d.district,
        area: d.area,
        pincode: d.pincode,
        latitude: d.latitude,
        longitude: d.longitude,
        whatsappNumber: d.whatsappNumber,
        lastDonationDate: d.lastDonationDate,
        availabilityStatus: d.availabilityStatus,
        isVerified: d.isVerified,
        profilePhoto: d.profilePhoto,
        eligibility: {
          'is_eligible': d.markerColor == 'green',
          'marker_color': d.markerColor,
          'status_label': d.statusLabel,
        },
      );
      _isLoading = false;
      if (mounted) setState(() {});
    }

    if (targetId != null) {
      final res = await ApiService.getDonorDetails(targetId);
      if (!mounted) return;
      if (res.success && res.data != null) {
        final data = res.data!;
        final user = UserModel.fromJson(data);
        List<DonationHistoryModel> history = [];
        if (data['history'] is List) {
          history = (data['history'] as List)
              .map((h) => DonationHistoryModel.fromJson(h))
              .toList();
        }
        setState(() {
          _profile = user;
          _history = history;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _makeCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone, String name) async {
    var cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length == 10) cleanPhone = '91$cleanPhone';
    final msg = Uri.encodeComponent('Hello $name, I found your profile on BloodBridge. We need blood urgently.');
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Profile not found.')),
      );
    }

    final isGreen = _profile!.markerColor == 'green';
    final statusColor = isGreen ? AppColors.availableGreen : AppColors.recentlyDonatedRed;
    final statusBg = isGreen ? AppColors.availableGreenLight : AppColors.recentlyDonatedRedLight;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isOwnProfile ? 'My Profile' : 'Donor Profile',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          if (_isOwnProfile)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditProfileScreen(user: _profile!)),
                );
                if (updated == true) _loadProfile();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Profile Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _profile!.bloodGroup,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      if (_profile!.isVerified)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified, color: Colors.blue, size: 22),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _profile!.fullName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_profile!.area}, ${_profile!.district}, ${_profile!.state}',
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  // Availability Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 10, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          _profile!.statusLabel,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: statusColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Call & WhatsApp Action Buttons if viewing another donor
            if (!_isOwnProfile)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _makeCall(_profile!.mobileNumber),
                        icon: const Icon(Icons.call, size: 18, color: Colors.white),
                        label: const Text('Call Donor', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.callBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openWhatsApp(_profile!.whatsappNumber ?? _profile!.mobileNumber, _profile!.fullName),
                        icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
                        label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.whatsappGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Donor Information Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Donor Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),
                  _buildInfoTile(Icons.bloodtype_outlined, 'Blood Group', _profile!.bloodGroup),
                  _buildInfoTile(Icons.phone_outlined, 'Mobile Number', '+91 ${_profile!.mobileNumber}'),
                  if (_profile!.whatsappNumber != null && _profile!.whatsappNumber!.isNotEmpty)
                    _buildInfoTile(Icons.chat_outlined, 'WhatsApp Number', '+91 ${_profile!.whatsappNumber}'),
                  _buildInfoTile(Icons.calendar_today_outlined, 'Last Donation', _profile!.lastDonationDate ?? 'None / First Time'),
                  _buildInfoTile(Icons.location_on_outlined, 'Address / Area', '${_profile!.area}, Pincode: ${_profile!.pincode}'),
                  _buildInfoTile(Icons.male_outlined, 'Gender', _profile!.gender),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Donation History Timeline
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Donation History',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      if (_isOwnProfile)
                        TextButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DonationHistoryScreen()),
                            );
                            _loadProfile();
                          },
                          child: const Text('Manage History', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_history.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('No recorded donations yet.', style: TextStyle(color: AppColors.textSecondary)),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final h = _history[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(top: 5),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      h.hospitalName,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                    ),
                                    Text(
                                      '${h.donationDate} • ${h.location}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                    if (h.notes != null && h.notes!.isNotEmpty)
                                      Text(
                                        h.notes!,
                                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
