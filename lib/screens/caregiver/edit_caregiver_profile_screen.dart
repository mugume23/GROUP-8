import 'package:flutter/material.dart';
import '../../models/caregiver_model.dart';
import '../../services/caregiver_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/uganda_location_picker.dart';
import '../../widgets/photo_picker.dart';
import '../shared/location_picker_screen.dart';

class EditCaregiverProfileScreen extends StatefulWidget {
  final String userId;
  final CaregiverModel? profile;

  const EditCaregiverProfileScreen({
    super.key,
    required this.userId,
    this.profile,
  });

  @override
  State<EditCaregiverProfileScreen> createState() =>
      _EditCaregiverProfileScreenState();
}

class _EditCaregiverProfileScreenState
    extends State<EditCaregiverProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caregiverService = CaregiverService();

  late final TextEditingController _bioController;
  late final TextEditingController _rateController;
  late final TextEditingController _expController;
  late final TextEditingController _ageController;

  UgandaLocation? _selectedLocation;
  String _selectedGender = 'Male';
  List<String> _selectedSpecs = [];
  List<String> _selectedDays = [];
  bool _isAvailable = true;
  bool _saving = false;
  String? _profileImageUrl;

  final List<String> _allSpecs = [
    'Infant Care',
    'Autism',
    'Elderly',
    'Special Needs',
    'Overnight',
    'Tutoring',
    'Cooking',
    'Housekeeping',
  ];

  final List<String> _allDays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _bioController = TextEditingController(text: p?.bio ?? '');
    _rateController =
        TextEditingController(text: p?.hourlyRate.toString() ?? '');
    _expController =
        TextEditingController(text: p?.experienceYears.toString() ?? '');
    _ageController = TextEditingController(text: p?.age.toString() ?? '');
    _selectedGender = p?.gender.isNotEmpty == true ? p!.gender : 'Male';
    _selectedSpecs = List.from(p?.specializations ?? []);
    _selectedDays = List.from(p?.availability ?? []);
    _isAvailable = p?.isAvailable ?? true;
    _profileImageUrl = p?.profileImage;
    // Parse existing location string into UgandaLocation
    if (p?.location.isNotEmpty == true) {
      final parts = p!.location.split(', ');
      _selectedLocation = UgandaLocation(
        district: parts.isNotEmpty ? parts[0] : p.location,
        county: parts.length > 1 ? parts[1] : null,
        subcounty: parts.length > 2 ? parts[2] : null,
        parish: parts.length > 3 ? parts[3] : null,
        village: parts.length > 4 ? parts[4] : null,
      );
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _rateController.dispose();
    _expController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your location'),
          backgroundColor: AppTheme.accentColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _saving = true);

    final updateData = <String, dynamic>{
      'bio': _bioController.text.trim(),
      'location': _selectedLocation!.fullAddress,
      'district': _selectedLocation!.district,
      'county': _selectedLocation!.county ?? '',
      'subcounty': _selectedLocation!.subcounty ?? '',
      'parish': _selectedLocation!.parish ?? '',
      'village': _selectedLocation!.village ?? '',
      'hourlyRate': double.tryParse(_rateController.text) ?? 0,
      'experienceYears': int.tryParse(_expController.text) ?? 0,
      'age': int.tryParse(_ageController.text) ?? 0,
      'gender': _selectedGender,
      'specializations': _selectedSpecs,
      'availability': _selectedDays,
      'isAvailable': _isAvailable,
    };

    // Add profile image if it was updated
    if (_profileImageUrl != null) {
      updateData['profileImage'] = _profileImageUrl!;
    }

    await _caregiverService.updateProfile(widget.userId, updateData);

    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back,
                color: AppTheme.textDark, size: 20),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.primaryColor),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo Picker
              Center(
                child: PhotoPicker(
                  initialImageUrl: _profileImageUrl,
                  onImageUploaded: (url) {
                    setState(() => _profileImageUrl = url);
                  },
                  size: 120,
                  placeholderText: 'Add Photo',
                ),
              ),
              const SizedBox(height: 24),

              // Availability toggle
              AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available for Work',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          'Toggle your availability status',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textGrey),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isAvailable,
                      onChanged: (v) => setState(() => _isAvailable = v),
                      activeThumbColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _sectionLabel('Basic Information'),
              const SizedBox(height: 12),

              // Location picker button
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push<UgandaLocation>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LocationPickerScreen(
                        initialValue: _selectedLocation,
                      ),
                    ),
                  );
                  if (result != null) {
                    setState(() => _selectedLocation = result);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedLocation != null
                          ? AppTheme.primaryColor.withValues(alpha: 0.4)
                          : AppTheme.dividerColor,
                      width: _selectedLocation != null ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: _selectedLocation != null
                            ? AppTheme.primaryColor
                            : AppTheme.textGrey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedLocation != null
                              ? _selectedLocation!.fullAddress
                              : 'Select your location in Uganda',
                          style: TextStyle(
                            fontSize: 14,
                            color: _selectedLocation != null
                                ? AppTheme.textDark
                                : AppTheme.textGrey,
                            fontWeight: _selectedLocation != null
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppTheme.textGrey, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.cake_outlined,
                            color: AppTheme.textGrey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                      ),
                      items: ['Male', 'Female', 'Other']
                          .map((g) => DropdownMenuItem(
                                value: g,
                                child: Text(g),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedGender = v ?? 'Male'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Experience (years)',
                        prefixIcon: Icon(Icons.work_outline,
                            color: AppTheme.textGrey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _rateController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Hourly Rate (UGX)',
                        prefixIcon: Icon(Icons.attach_money,
                            color: AppTheme.textGrey),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _bioController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Bio / About Me',
                  hintText: 'Tell parents about yourself...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              _sectionLabel('Specializations'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allSpecs.map((spec) {
                  final selected = _selectedSpecs.contains(spec);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedSpecs.remove(spec);
                        } else {
                          _selectedSpecs.add(spec);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primaryColor
                            : AppTheme.cardWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppTheme.primaryColor
                              : AppTheme.dividerColor,
                        ),
                      ),
                      child: Text(
                        spec,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppTheme.textGrey,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              _sectionLabel('Available Days'),
              const SizedBox(height: 12),
              Row(
                children: _allDays.map((day) {
                  final selected = _selectedDays.contains(day);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedDays.remove(day);
                          } else {
                            _selectedDays.add(day);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.primaryColor
                              : AppTheme.cardWhite,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? AppTheme.primaryColor
                                : AppTheme.dividerColor,
                          ),
                        ),
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : AppTheme.textGrey,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Save Profile'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.textDark,
      ),
    );
  }
}
