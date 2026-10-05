import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _areaController;
  late TextEditingController _pincodeController;
  late TextEditingController _whatsappController;

  late String _selectedBloodGroup;
  late String _availabilityStatus;
  DateTime? _lastDonationDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
    _areaController = TextEditingController(text: widget.user.area);
    _pincodeController = TextEditingController(text: widget.user.pincode);
    _whatsappController = TextEditingController(text: widget.user.whatsappNumber ?? widget.user.mobileNumber);
    _selectedBloodGroup = widget.user.bloodGroup;
    _availabilityStatus = widget.user.availabilityStatus;
    if (widget.user.lastDonationDate != null && widget.user.lastDonationDate!.isNotEmpty) {
      _lastDonationDate = DateTime.tryParse(widget.user.lastDonationDate!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _pincodeController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final payload = {
      'full_name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'blood_group': _selectedBloodGroup,
      'address': _addressController.text.trim(),
      'area': _areaController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'whatsapp_number': _whatsappController.text.trim(),
      'availability_status': _availabilityStatus,
      'last_donation_date': _lastDonationDate?.toIso8601String().substring(0, 10),
    };

    final res = await ApiService.updateProfile(payload);
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.availableGreen,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
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
              CustomTextField(
                label: 'Full Name *',
                controller: _nameController,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Email Address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'WhatsApp Number',
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              const Text('Blood Group', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.bloodGroups.map((bg) {
                  final isSel = _selectedBloodGroup == bg;
                  return ChoiceChip(
                    label: Text(bg, style: TextStyle(fontWeight: FontWeight.w800, color: isSel ? Colors.white : AppColors.textPrimary)),
                    selected: isSel,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    onSelected: (sel) {
                      if (sel) setState(() => _selectedBloodGroup = bg);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Availability Dropdown
              const Text('Availability Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
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
                    value: _availabilityStatus,
                    isExpanded: true,
                    items: ['Available', 'Busy', 'Unavailable'].map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _availabilityStatus = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Area / Landmark',
                controller: _areaController,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Pincode',
                controller: _pincodeController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Address',
                controller: _addressController,
                maxLines: 2,
              ),
              const SizedBox(height: 28),

              CustomButton(
                text: 'Save Changes',
                isLoading: _isLoading,
                onPressed: _handleSave,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
