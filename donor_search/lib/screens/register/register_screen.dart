import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';
import '../../services/api_service.dart';
import '../../navigation/main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String prefilledMobile;

  const RegisterScreen({super.key, required this.prefilledMobile});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _areaController;
  late TextEditingController _pincodeController;
  late TextEditingController _whatsappController;

  String _selectedBloodGroup = 'O+';
  String _selectedGender = 'Male';
  String _selectedState = 'Tamil Nadu';
  String _selectedDistrict = 'Madurai';
  DateTime? _dob;
  DateTime? _lastDonationDate;
  bool _neverDonated = false;
  String _availabilityStatus = 'Available';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _mobileController = TextEditingController(text: widget.prefilledMobile);
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _areaController = TextEditingController();
    _pincodeController = TextEditingController(text: '625020');
    _whatsappController = TextEditingController(text: widget.prefilledMobile);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _pincodeController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isDob}) async {
    final now = DateTime.now();
    final firstDate = isDob ? DateTime(1950) : DateTime(2020);
    final lastDate = isDob ? DateTime(now.year - 18, now.month, now.day) : now;

    final picked = await showDatePicker(
      context: context,
      initialDate: isDob ? DateTime(now.year - 25) : now,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDob) {
          _dob = picked;
        } else {
          _lastDonationDate = picked;
          _neverDonated = false;
        }
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final payload = {
      'full_name': _nameController.text.trim(),
      'mobile_number': _mobileController.text.trim(),
      'blood_group': _selectedBloodGroup,
      'gender': _selectedGender,
      'date_of_birth': _dob?.toIso8601String().substring(0, 10),
      'email': _emailController.text.trim(),
      'address': _addressController.text.trim(),
      'state': _selectedState,
      'district': _selectedDistrict,
      'area': _areaController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'whatsapp_number': _whatsappController.text.trim(),
      'last_donation_date': !_neverDonated && _lastDonationDate != null
          ? _lastDonationDate!.toIso8601String().substring(0, 10)
          : null,
      'availability_status': _availabilityStatus,
      'latitude': 9.9252,
      'longitude': 78.1198,
    };

    final res = await ApiService.register(payload);
    if (!mounted) return;

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: AppColors.availableGreen,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = res.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final districts = AppConstants.stateDistricts[_selectedState] ?? ['Madurai'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Donor Registration',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.volunteer_activism, size: 36, color: Colors.white),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Become a Life Saver',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Your donation can save up to 3 precious lives in emergencies.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section: Personal Details
              _buildSectionTitle('Personal Details'),
              CustomTextField(
                label: 'Full Name *',
                hint: 'e.g. Anandha Krishnan',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Full Name is required' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Mobile Number *',
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                readOnly: true,
                prefix: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Text(
                    '+91',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Blood Group Selection Grid
              const Text(
                'Select Blood Group *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.bloodGroups.map((bg) {
                  final isSelected = _selectedBloodGroup == bg;
                  return ChoiceChip(
                    label: Text(
                      bg,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.cardBorder,
                      width: 1.5,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedBloodGroup = bg);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Gender Selector
              const Text(
                'Gender *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Male', 'Female', 'Other'].map((g) {
                  final isSelected = _selectedGender == g;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        onPressed: () => setState(() => _selectedGender = g),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected ? AppColors.primarySoft : Colors.white,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.cardBorder,
                            width: isSelected ? 1.8 : 1,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          g,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Date of Birth Picker
              CustomTextField(
                label: 'Date of Birth',
                hint: _dob != null ? _dob!.toIso8601String().substring(0, 10) : 'Tap to select DOB',
                readOnly: true,
                onTap: () => _pickDate(isDob: true),
                prefixIcon: Icons.cake_outlined,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Email (Optional)',
                hint: 'e.g. donor@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 24),

              // Section: Location Details
              _buildSectionTitle('Location Details'),
              // State Dropdown
              const Text(
                'State *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedState,
                    isExpanded: true,
                    items: AppConstants.indianStates.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
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
              const SizedBox(height: 16),

              // District Dropdown
              const Text(
                'District *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: districts.contains(_selectedDistrict) ? _selectedDistrict : districts.first,
                    isExpanded: true,
                    items: districts.map((d) {
                      return DropdownMenuItem(value: d, child: Text(d));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDistrict = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Area / Landmark *',
                hint: 'e.g. Anna Nagar / Simmakkal',
                controller: _areaController,
                prefixIcon: Icons.place_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Area is required' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Pincode *',
                hint: 'e.g. 625020',
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.pin_drop_outlined,
                validator: (v) => (v == null || v.trim().length != 6) ? 'Enter valid 6-digit Pincode' : null,
              ),
              const SizedBox(height: 24),

              // Section: Donation & Contact Details
              _buildSectionTitle('Donation & Availability'),
              CustomTextField(
                label: 'WhatsApp Number',
                hint: 'e.g. 9876543210',
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.chat_bubble_outline,
              ),
              const SizedBox(height: 16),

              // Last Blood Donation Date Picker
              CustomTextField(
                label: 'Last Blood Donation Date',
                hint: _neverDonated
                    ? 'Never donated yet'
                    : (_lastDonationDate != null
                        ? _lastDonationDate!.toIso8601String().substring(0, 10)
                        : 'Tap to pick last donation date'),
                readOnly: true,
                onTap: () => _pickDate(isDob: false),
                prefixIcon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _neverDonated,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() {
                        _neverDonated = val ?? false;
                        if (_neverDonated) _lastDonationDate = null;
                      });
                    },
                  ),
                  const Text('I am donating for the first time', style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 16),

              // Availability Status
              const Text(
                'Current Availability *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildAvailabilityChip('Available', AppColors.availableGreen),
                  const SizedBox(width: 8),
                  _buildAvailabilityChip('Busy', AppColors.busyOrange),
                  const SizedBox(width: 8),
                  _buildAvailabilityChip('Unavailable', AppColors.recentlyDonatedRed),
                ],
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ),
              ],

              const SizedBox(height: 32),
              CustomButton(
                text: 'Register as Donor',
                isLoading: _isLoading,
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildAvailabilityChip(String label, Color color) {
    final isSelected = _availabilityStatus == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _availabilityStatus = label),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? color : AppColors.cardBorder, width: isSelected ? 1.8 : 1),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
