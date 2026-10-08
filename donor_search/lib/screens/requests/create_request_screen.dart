import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _patientController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _addressController = TextEditingController();
  final _areaController = TextEditingController();
  final _pincodeController = TextEditingController(text: '625020');
  final _descriptionController = TextEditingController();

  String _selectedBloodGroup = 'O+';
  int _units = 2;
  String _selectedUrgency = 'Critical';
  final String _selectedState = 'Tamil Nadu';
  String _selectedDistrict = 'Madurai';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _patientController.dispose();
    _hospitalController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _pincodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final isLoggedIn = await StorageService.isLoggedIn();
    if (!isLoggedIn) {
      setState(() {
        _errorMessage = 'Please log in to your account to post an emergency blood request.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final payload = {
      'patient_name': _patientController.text.trim(),
      'blood_group': _selectedBloodGroup,
      'required_units': _units,
      'hospital_name': _hospitalController.text.trim(),
      'hospital_address': _addressController.text.trim(),
      'state': _selectedState,
      'district': _selectedDistrict,
      'area': _areaController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'urgency': _selectedUrgency,
      'description': _descriptionController.text.trim(),
      'latitude': 9.9320,
      'longitude': 78.1450,
    };

    final res = await ApiService.createRequest(payload);
    if (!mounted) return;

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: AppColors.availableGreen,
        ),
      );
      Navigator.pop(context, true);
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
        title: const Text('Post Emergency Request', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
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
                label: 'Patient Name *',
                hint: 'e.g. Ramesh Kumar',
                controller: _patientController,
                prefixIcon: Icons.person_outline,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Patient name is required' : null,
              ),
              const SizedBox(height: 16),

              // Blood Group Selection
              const Text('Blood Group Needed *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.bloodGroups.map((bg) {
                  final isSel = _selectedBloodGroup == bg;
                  return ChoiceChip(
                    label: Text(
                      bg,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isSel ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedBloodGroup = bg);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Required Units Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Required Units (Bags) *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: _units > 1 ? () => setState(() => _units--) : null,
                        ),
                        Text(
                          '$_units',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: _units < 10 ? () => setState(() => _units++) : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Urgency Level
              const Text('Urgency Level *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildUrgencyChip('Critical', AppColors.criticalUrgency),
                  const SizedBox(width: 8),
                  _buildUrgencyChip('Urgent', AppColors.highUrgency),
                  const SizedBox(width: 8),
                  _buildUrgencyChip('Standard', AppColors.standardUrgency),
                ],
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Hospital Name *',
                hint: 'e.g. Government Rajaji Hospital / Apollo',
                controller: _hospitalController,
                prefixIcon: Icons.local_hospital_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Hospital name is required' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Hospital Address *',
                hint: 'e.g. Panagal Road, Shenoy Nagar',
                controller: _addressController,
                prefixIcon: Icons.location_on_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Address is required' : null,
              ),
              const SizedBox(height: 16),

              // District & Area
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: districts.contains(_selectedDistrict) ? _selectedDistrict : districts.first,
                          isExpanded: true,
                          items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13)))).toList(),
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
                      controller: _areaController,
                      decoration: InputDecoration(
                        hintText: 'Area (e.g. KK Nagar)',
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.cardBorder),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Area required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Description / Notes',
                hint: 'e.g. Operation scheduled tomorrow at 9 AM. ICU Ward 3.',
                controller: _descriptionController,
                maxLines: 3,
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],

              const SizedBox(height: 28),
              CustomButton(
                text: 'Broadcast Request to Donors',
                icon: Icons.send,
                isLoading: _isLoading,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrgencyChip(String label, Color color) {
    final isSel = _selectedUrgency == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedUrgency = label),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? color.withValues(alpha: 0.15) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSel ? color : AppColors.cardBorder, width: isSel ? 2 : 1),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                color: isSel ? color : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
