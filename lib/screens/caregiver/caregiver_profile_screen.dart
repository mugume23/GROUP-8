import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/caregiver_model.dart';
import '../../services/auth_service.dart';
import '../../services/caregiver_service.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';
import 'edit_caregiver_profile_screen.dart';

class CaregiverProfileScreen extends StatefulWidget {
  final String userId;
  const CaregiverProfileScreen({super.key, required this.userId});

  @override
  State<CaregiverProfileScreen> createState() =>
      _CaregiverProfileScreenState();
}

class _CaregiverProfileScreenState extends State<CaregiverProfileScreen> {
  final _caregiverService = CaregiverService();
  CaregiverModel? _profile;
  String _phone = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    _phone = prefs.getString('phone') ?? '';
    final profile =
        await _caregiverService.getCaregiverByUserId(widget.userId);
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService().logout();
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Profile',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark)),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditCaregiverProfileScreen(
                          userId: widget.userId,
                          profile: _profile,
                        ),
                      ),
                    );
                    _loadData();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(26, 31, 60, 0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit_outlined,
                        color: AppTheme.textDark, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Profile card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.20),
                        backgroundImage: _profile?.profileImage != null
                            ? NetworkImage(_profile!.profileImage!)
                            : null,
                        child: _profile?.profileImage == null
                            ? Text(
                                _profile?.name.isNotEmpty == true
                                    ? _profile!.name[0].toUpperCase()
                                    : 'C',
                                style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white))
                            : null,
                      ),
                      if (_profile?.isVerified == true)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                                color: AppTheme.successColor,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.check,
                                color: Colors.white, size: 14),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(_profile?.name ?? '',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(_phone,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.white60)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _Badge('Caregiver'),
                      if (_profile?.location.isNotEmpty == true)
                        _Badge(_profile!.location,
                            icon: Icons.location_on_outlined),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ProfileStat(
                          value: _profile?.rating.toStringAsFixed(1) ??
                              '0.0',
                          label: 'Rating'),
                      Container(
                          width: 1, height: 30, color: Colors.white24),
                      _ProfileStat(
                          value: '${_profile?.reviewCount ?? 0}',
                          label: 'Reviews'),
                      Container(
                          width: 1, height: 30, color: Colors.white24),
                      _ProfileStat(
                          value:
                              '${_profile?.experienceYears ?? 0} yrs',
                          label: 'Experience'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bio
            if (_profile?.bio.isNotEmpty == true) ...[
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('About Me',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 8),
                    Text(_profile!.bio,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textGrey,
                            height: 1.6)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Specializations
            if (_profile?.specializations.isNotEmpty == true) ...[
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Specializations',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _profile!.specializations
                          .map((s) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(s,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Settings
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                      icon: Icons.person_outline,
                      title: 'Account Settings',
                      subtitle: 'Privacy, Security, Change number',
                      onTap: () {}),
                  const Divider(
                      height: 1, color: AppTheme.dividerColor),
                  _SettingsTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Manage notification preferences',
                      onTap: () {}),
                  const Divider(
                      height: 1, color: AppTheme.dividerColor),
                  _SettingsTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'FAQs, Contact us',
                      onTap: () {}),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout,
                    color: AppTheme.accentColor),
                label: const Text('Sign Out',
                    style: TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.accentColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData? icon;
  const _Badge(this.label, {this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.white70),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: Colors.white60)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 11, color: AppTheme.textGrey)),
      trailing: const Icon(Icons.chevron_right,
          color: AppTheme.textGrey, size: 20),
    );
  }
}
