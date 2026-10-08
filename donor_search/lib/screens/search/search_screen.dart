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

class _SearchScreenState extends State<SearchScreen> {
  // Manual Search State: Nullable so they display as watermark placeholders initially
  String? _selectedState;
  String? _selectedDistrict;
  final _areaController = TextEditingController();
  final _pincodeController = TextEditingController();
  String _selectedBloodGroup = 'ALL';
  final String _selectedGender = 'ALL';
  final String _selectedAvailability = 'ALL';
  List<DonorModel> _manualResults = [];
  bool _isManualLoading = false;
  bool _manualSearched = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialBloodGroup != null) {
      _selectedBloodGroup = widget.initialBloodGroup!;
    }
    _loadUser();
  }

  Future<void> _loadUser() async {
    // Only search automatically if initial blood group was explicitly passed
    if (widget.initialBloodGroup != null) {
      _handleManualSearch();
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    // Ensure in-memory state resets to watermark placeholders upon hot reload if not custom
    if (_selectedState == 'Tamil Nadu') _selectedState = null;
    if (_selectedDistrict == 'Madurai') _selectedDistrict = null;
  }

  @override
  void dispose() {
    _areaController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _areaController.clear();
    _pincodeController.clear();
    setState(() {
      _selectedState = null;
      _selectedDistrict = null;
      _selectedBloodGroup = 'ALL';
      _manualSearched = false;
      _manualResults = [];
    });
  }

  Future<void> _handleManualSearch() async {
    setState(() {
      _isManualLoading = true;
      _manualSearched = true;
    });

    final filters = {
      'state': _selectedState ?? 'Tamil Nadu',
      'district': _selectedDistrict ?? 'Madurai',
      'area': _areaController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'blood_group': _selectedBloodGroup,
      'gender': _selectedGender,
      'availability': _selectedAvailability,
      'latitude': 9.9252,
      'longitude': 78.1198,
    };

    final res = await ApiService.searchManual(filters);
    if (!mounted) return;
    setState(() {
      _manualResults = res.data ?? [];
      _isManualLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        _manualSearched ||
        _selectedState != null ||
        _selectedDistrict != null ||
        _areaController.text.isNotEmpty ||
        _pincodeController.text.isNotEmpty ||
        _selectedBloodGroup != 'ALL';

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
        actions: [
          if (hasActiveFilters)
            TextButton.icon(
              icon: const Icon(
                Icons.refresh,
                size: 18,
                color: AppColors.primary,
              ),
              label: const Text(
                'Clear',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
              onPressed: _clearSearch,
            ),
        ],
      ),
      body: _buildManualSearch(hasActiveFilters),
    );
  }

  Widget _buildManualSearch(bool hasActiveFilters) {
    final districts = _selectedState != null
        ? (AppConstants.stateDistricts[_selectedState] ?? ['Madurai'])
        : (AppConstants.stateDistricts['Tamil Nadu'] ?? ['Madurai']);

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
                Row(
                  children: [
                    const Icon(
                      Icons.location_city,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Location: India → State → District',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasActiveFilters) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _clearSearch,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                // Country Fixed: India
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Country: India',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // State Dropdown with Watermark Hint
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
                            hint: const Text(
                              'Tamil Nadu',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            isExpanded: true,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.textMuted,
                            ),
                            items: AppConstants.indianStates.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedState =
                                    (val == null || val == 'Tamil Nadu')
                                    ? null
                                    : val;
                                _selectedDistrict = null;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // District Dropdown with Watermark Hint & Pincode
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
                            value:
                                (_selectedDistrict != null &&
                                    districts.contains(_selectedDistrict))
                                ? _selectedDistrict
                                : null,
                            hint: Text(
                              (_selectedState != null &&
                                      _selectedState != 'Tamil Nadu')
                                  ? 'Select District'
                                  : 'Madurai',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            isExpanded: true,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.textMuted,
                            ),
                            items: districts.map((d) {
                              return DropdownMenuItem(
                                value: d,
                                child: Text(
                                  d,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedDistrict =
                                    (val == null || val == 'Madurai')
                                    ? null
                                    : val;
                              });
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
                          hintStyle: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.cardBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.cardBorder,
                            ),
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
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
                      onSelected: (_) =>
                          setState(() => _selectedBloodGroup = bg),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // Button Row: Clear Option + Search Donors
                Row(
                  children: [
                    if (hasActiveFilters) ...[
                      OutlinedButton.icon(
                        icon: const Icon(
                          Icons.refresh,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        label: const Text(
                          'Clear',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                        ),
                        onPressed: _clearSearch,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: CustomButton(
                        text: 'Search Donors',
                        icon: Icons.search,
                        isLoading: _isManualLoading,
                        onPressed: _handleManualSearch,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Results Section
          if (_isManualLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_manualSearched)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Search Results (${_manualResults.length} Found)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        label: const Text(
                          'Clear Results',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _clearSearch,
                      ),
                    ],
                  ),
                ),
                if (_manualResults.isEmpty)
                  _buildNoResults(
                    'No donors found matching your exact criteria. Try broadening your area or blood group.',
                  )
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
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(donor: donor, donorId: donor.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            )
          else
            // Initial Clean State (No Unnecessary Results Shown)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_search_outlined,
                        size: 38,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ready to Search',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Select your location and blood group, then tap "Search Donors" to view matching donors.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
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
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
