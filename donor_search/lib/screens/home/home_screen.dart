import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../components/donor_card.dart';
import '../../components/blood_request_card.dart';
import '../../models/donor_model.dart';
import '../../models/request_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onTabChange;

  const HomeScreen({super.key, this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _currentUser;
  List<DonorModel> _donors = [];
  List<BloodRequestModel> _requests = [];
  String _selectedBloodFilter = 'ALL';
  bool _isLoading = true;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = await StorageService.getUser();
    _currentUser = user;

    // Load donors
    final donorsRes = await ApiService.getDonors(
      bloodGroup: _selectedBloodFilter != 'ALL' ? _selectedBloodFilter : null,
      district: user?.district ?? 'Madurai',
      latitude: user?.latitude ?? 9.9252,
      longitude: user?.longitude ?? 78.1198,
    );

    // Load requests
    final requestsRes = await ApiService.getRequests(status: 'Active');

    // Load notification count
    final notifRes = await ApiService.getNotifications();

    if (!mounted) return;
    setState(() {
      _donors = donorsRes.data ?? [];
      _requests = requestsRes.data ?? [];
      _unreadNotifications = notifRes.data?['unread_count'] ?? 0;
      _isLoading = false;
    });
  }

  void _onBloodGroupChipTap(String bg) {
    setState(() {
      _selectedBloodFilter = (_selectedBloodFilter == bg) ? 'ALL' : bg;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final availableCount = _donors.where((d) => d.markerColor == 'green').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Custom Header
                _buildHeader(context),

                // Main CTA Search Card
                _buildSearchCard(context),

                // Quick Blood Group Filter Chips
                _buildBloodGroupChips(),

                // Live Impact Counter Row
                _buildStatsBanner(availableCount),

                // Emergency Requests Section (Horizontal Carousel)
                _buildEmergencySection(context),

                // Nearby Donors Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_alt_outlined, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _selectedBloodFilter == 'ALL'
                                ? 'Nearby Donors (${_donors.length})'
                                : '$_selectedBloodFilter Donors (${_donors.length})',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => widget.onTabChange?.call(1),
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Donor List
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (_donors.isEmpty)
                  _buildEmptyState('No donors found for this blood group nearby.')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _donors.length,
                    itemBuilder: (context, index) {
                      final donor = _donors[index];
                      return DonorCard(
                        donor: donor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProfileScreen(donorId: donor.id)),
                          );
                        },
                      );
                    },
                  ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF5252), AppColors.primaryDark],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.water_drop, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'Blood',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text: 'Connect',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _currentUser != null ? 'Hello, ${_currentUser!.fullName.split(' ').first}' : 'Find Donors Nearby',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              // Notification Icon with Badge
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary, size: 26),
                    onPressed: () => _showNotificationsDialog(context),
                  ),
                  if (_unreadNotifications > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$_unreadNotifications',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              // User Avatar
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(
                    _currentUser?.bloodGroup ?? 'O+',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFC62828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Blood Donor',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Search by live location or manual area',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search, color: Colors.white, size: 26),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => widget.onTabChange?.call(1), // Go to Search Tab
                  icon: const Icon(Icons.location_searching, size: 16, color: AppColors.primary),
                  label: const Text(
                    'Find Blood Donor',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => widget.onTabChange?.call(2), // Go to Live Map
                icon: const Icon(Icons.map_outlined, size: 16, color: Colors.white),
                label: const Text(
                  'Live Map',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBloodGroupChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'Quick Blood Group Filter',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: AppConstants.bloodGroups.length,
            itemBuilder: (context, index) {
              final bg = AppConstants.bloodGroups[index];
              final isSelected = _selectedBloodFilter == bg;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(
                    bg,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.cardBorder,
                      width: 1.2,
                    ),
                  ),
                  onSelected: (_) => _onBloodGroupChipTap(bg),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBanner(int availableCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Registered', '${_donors.length}', AppColors.textPrimary),
          Container(width: 1, height: 28, color: AppColors.divider),
          _buildStatItem('Available Now', '$availableCount', AppColors.availableGreen),
          Container(width: 1, height: 28, color: AppColors.divider),
          _buildStatItem('Requests', '${_requests.length}', AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEmergencySection(BuildContext context) {
    if (_requests.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.emergency, color: AppColors.criticalUrgency, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Emergency Blood Requests',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => widget.onTabChange?.call(3), // Go to Requests Tab
                child: const Text('All Requests', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 185,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _requests.take(4).length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 310,
                child: BloodRequestCard(
                  request: _requests[index],
                  onTap: () => widget.onTabChange?.call(3),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off, size: 54, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) async {
    final notifRes = await ApiService.getNotifications();
    if (!context.mounted) return;

    final notifs = (notifRes.data?['notifications'] as List?) ?? [];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  if (_unreadNotifications > 0)
                    TextButton(
                      onPressed: () {
                        setState(() => _unreadNotifications = 0);
                        Navigator.pop(context);
                      },
                      child: const Text('Mark all read'),
                    ),
                ],
              ),
              const Divider(),
              if (notifs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No notifications right now.')),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: notifs.length,
                    itemBuilder: (ctx, idx) {
                      final n = notifs[idx];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primarySoft,
                          child: const Icon(Icons.notifications, color: AppColors.primary, size: 20),
                        ),
                        title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text(n.message, style: const TextStyle(fontSize: 12)),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
