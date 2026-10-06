import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../components/donor_card.dart';
import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';
import '../../models/donor_model.dart';
import '../../services/api_service.dart';
import '../profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialBloodGroup;

  const SearchScreen({super.key, this.initialBloodGroup});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Manual Search State
  String _selectedState = 'Tamil Nadu';
  String _selectedDistrict = 'Madurai';
  final _areaController = TextEditingController();
  final _pincodeController = TextEditingController();
  String _selectedBloodGroup = 'ALL';
  final String _selectedGender = 'ALL';
  final String _selectedAvailability = 'ALL';
  List<DonorModel> _manualResults = [];
  bool _isManualLoading = false;
  bool _manualSearched = false;

  // Live Location Search State
  final double _liveLat = 9.9252; // Default Madurai Center
  final double _liveLng = 78.1198;
  double _searchRadius = 5.0; // 5 KM Default
  String _liveBloodGroup = 'ALL';
  List<DonorModel> _liveResults = [];
  bool _isLiveLoading = false;
  bool _liveSearched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.initialBloodGroup != null) {
      _selectedBloodGroup = widget.initialBloodGroup!;
      _liveBloodGroup = widget.initialBloodGroup!;
    }
    // Auto-perform initial live search
    _handleLiveSearch();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _areaController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _handleManualSearch() async {
    setState(() {
      _isManualLoading = true;
      _manualSearched = true;
    });

    final filters = {
      'state': _selectedState,
      'district': _selectedDistrict,
      'area': _areaController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'blood_group': _selectedBloodGroup,
      'gender': _selectedGender,
      'availability': _selectedAvailability,
      'latitude': _liveLat,
      'longitude': _liveLng,
    };

    final res = await ApiService.searchManual(filters);
    if (!mounted) return;
    setState(() {
      _manualResults = res.data ?? [];
      _isManualLoading = false;
    });
  }

  Future<void> _handleLiveSearch() async {
    setState(() {
      _isLiveLoading = true;
      _liveSearched = true;
    });

    final res = await ApiService.searchLiveLocation(
      latitude: _liveLat,
      longitude: _liveLng,
      radius: _searchRadius,
      bloodGroup: _liveBloodGroup != 'ALL' ? _liveBloodGroup : null,
    );

    if (!mounted) return;
    setState(() {
      _liveResults = res.data ?? [];
      _isLiveLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Find Blood Donors',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.pin_drop_outlined), text: 'Manual Location'),
            Tab(icon: Icon(Icons.my_location), text: 'Live Location (GPS)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildManualSearchTab(),
          _buildLiveSearchTab(),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: MANUAL LOCATION SEARCH
  // ==========================================
  Widget _buildManualSearchTab() {
    final districts = AppConstants.stateDistricts[_selectedState] ?? ['Madurai'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Form Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_city, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hierarchical Search: India → State → District',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Country Fixed: India
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.flag_outlined, size: 18, color: AppColors.textSecondary),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Country: India',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // State Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedState,
                            isExpanded: true,
                            items: AppConstants.indianStates.map((s) {
                              return DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedState = val;
                                  final list = AppConstants.stateDistricts[val];
                                  if (list != null && list.isNotEmpty) {
                                    _selectedDistrict = list.first;
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // District Dropdown & Pincode
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: districts.contains(_selectedDistrict) ? _selectedDistrict : districts.first,
                            isExpanded: true,
                            items: districts.map((d) {
                              return DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13)));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedDistrict = val);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _pincodeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Pincode (e.g. 625020)',
                          hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.cardBorder),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  label: 'Area / Landmark (Optional)',
                  hint: 'e.g. Anna Nagar / Simmakkal',
                  controller: _areaController,
                  prefixIcon: Icons.place_outlined,
                ),
                const SizedBox(height: 14),
                // Blood Group Selector
                const Text(
                  'Blood Group',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ['ALL', ...AppConstants.bloodGroups].map((bg) {
                    final isSel = _selectedBloodGroup == bg;
                    return ChoiceChip(
                      label: Text(
                        bg,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSel ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      selected: isSel,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      onSelected: (_) => setState(() => _selectedBloodGroup = bg),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                CustomButton(
                  text: 'Search Donors',
                  icon: Icons.search,
                  isLoading: _isManualLoading,
                  onPressed: _handleManualSearch,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Results Section
          if (_isManualLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (_manualSearched)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: Text(
                    'Search Results (${_manualResults.length} Found)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ),
                if (_manualResults.isEmpty)
                  _buildNoResults('No donors found matching your exact criteria. Try broadening your area or blood group.')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _manualResults.length,
                    itemBuilder: (context, index) {
                      final donor = _manualResults[index];
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
              ],
            ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: LIVE LOCATION SEARCH (GPS)
  // ==========================================
  Widget _buildLiveSearchTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GPS Controls Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
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
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.gps_fixed, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Live GPS Coordinates',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.availableGreenLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'GPS Active',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.availableGreen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Center: ${_liveLat.toStringAsFixed(4)}° N, ${_liveLng.toStringAsFixed(4)}° E (Madurai)',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // Radius Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Search Radius Zone',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    Text(
                      '${_searchRadius.toInt()} KM',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ],
                ),
                Slider(
                  value: _searchRadius,
                  min: 2.0,
                  max: 25.0,
                  divisions: 23,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.primaryLight,
                  onChanged: (val) {
                    setState(() => _searchRadius = val);
                  },
                  onChangeEnd: (_) => _handleLiveSearch(),
                ),
                const SizedBox(height: 10),

                // Blood Group Chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ['ALL', ...AppConstants.bloodGroups].map((bg) {
                    final isSel = _liveBloodGroup == bg;
                    return ChoiceChip(
                      label: Text(
                        bg,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSel ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      selected: isSel,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      onSelected: (_) {
                        setState(() => _liveBloodGroup = bg);
                        _handleLiveSearch();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Use My Live Location',
                  icon: Icons.my_location,
                  isLoading: _isLiveLoading,
                  onPressed: _handleLiveSearch,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Results List (Sorted by Distance)
          if (_isLiveLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (_liveSearched)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: Text(
                    'Donors Near You (${_liveResults.length} within ${_searchRadius.toInt()} KM)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ),
                if (_liveResults.isEmpty)
                  _buildNoResults('No donors found within ${_searchRadius.toInt()} KM. Try increasing the search radius slider.')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _liveResults.length,
                    itemBuilder: (context, index) {
                      final donor = _liveResults[index];
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
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNoResults(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.person_search, size: 52, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
