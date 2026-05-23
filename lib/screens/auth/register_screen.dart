import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../screens/parent/parent_home_screen.dart';
import '../../screens/caregiver/caregiver_home_screen.dart';
import '../../widgets/uganda_location_picker.dart';
import '../shared/location_picker_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  bool _loading = false;
  bool _obscurePin = true;
  bool _obscureConfirm = true;
  String _selectedRole = 'parent';
  UgandaLocation? _selectedLocation;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
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

    setState(() => _loading = true);

    final result = await _authService.register(
      phone: _phoneController.text.trim(),
      pin: _pinController.text.trim(),
      name: _nameController.text.trim(),
      role: _selectedRole,
      location: _selectedLocation!.fullAddress,
      district: _selectedLocation!.district,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => _selectedRole == 'parent'
              ? const ParentHomeScreen()
              : const CaregiverHomeScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Registration failed'),
          backgroundColor: AppTheme.accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [
          // Dark header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 56, 28, 36),
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Join HomeCare and connect with\ntrusted caregivers today.',
                  style: TextStyle(
                      fontSize: 13, color: Colors.white60, height: 1.5),
                ),
              ],
            ),
          ),

          // Scrollable form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role selector
                    const Text('I am a...',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _RoleCard(
                            label: 'Parent',
                            icon: Icons.family_restroom,
                            isSelected: _selectedRole == 'parent',
                            onTap: () =>
                                setState(() => _selectedRole = 'parent'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _RoleCard(
                            label: 'Caregiver',
                            icon: Icons.health_and_safety_outlined,
                            isSelected: _selectedRole == 'caregiver',
                            onTap: () =>
                                setState(() => _selectedRole = 'caregiver'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Full name
                    _InputField(
                      controller: _nameController,
                      hint: 'Full Name',
                      icon: Icons.person_outline,
                      textCapitalization: TextCapitalization.words,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter your name';
                        if (v.length < 2) return 'Name too short';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Phone
                    _InputField(
                      controller: _phoneController,
                      hint: 'Phone Number e.g. 0700000000',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Enter phone number';
                        }
                        if (v.length < 10) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // PIN
                    _InputField(
                      controller: _pinController,
                      hint: 'Create 4-digit PIN',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePin,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePin
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.textGrey,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePin = !_obscurePin),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Create a PIN';
                        if (v.length != 4) {
                          return 'PIN must be exactly 4 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Confirm PIN
                    _InputField(
                      controller: _confirmPinController,
                      hint: 'Confirm PIN',
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirm,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.textGrey,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Confirm your PIN';
                        }
                        if (v != _pinController.text) {
                          return 'PINs do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Location section
                    const Text('Your Location',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 4),
                    const Text(
                      'Required to match you with nearby caregivers',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textGrey),
                    ),
                    const SizedBox(height: 10),

                    // Location picker button
                    GestureDetector(
                      onTap: () async {
                        final result =
                            await Navigator.push<UgandaLocation>(
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
                                ? AppTheme.primaryColor
                                    .withValues(alpha: 0.5)
                                : AppTheme.dividerColor,
                            width: _selectedLocation != null ? 1.5 : 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(26, 31, 60, 0.05),
                              blurRadius: 8,
                              offset: Offset(0, 2),
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
                            Icon(
                              _selectedLocation != null
                                  ? Icons.check_circle
                                  : Icons.chevron_right,
                              color: _selectedLocation != null
                                  ? AppTheme.successColor
                                  : AppTheme.textGrey,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Register button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? ',
                              style: TextStyle(
                                  color: AppTheme.textGrey,
                                  fontSize: 14)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Input field ───────────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLength;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.suffixIcon,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(26, 31, 60, 0.06),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        validator: validator,
        textCapitalization: textCapitalization,
        style: const TextStyle(
            fontSize: 15,
            color: AppTheme.textDark,
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppTheme.textGrey, fontSize: 14),
          counterText: '',
          prefixIcon: Icon(icon, color: AppTheme.textGrey, size: 20),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
                color: AppTheme.primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
                color: AppTheme.accentColor, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
                color: AppTheme.accentColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

// ── Role card ─────────────────────────────────────────────────────────────────
class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.dividerColor,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : AppTheme.textGrey,
                size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
