import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/caregiver_model.dart';
import '../../services/caregiver_service.dart';
import '../../utils/app_theme.dart';
import 'edit_caregiver_profile_screen.dart';

class CaregiverDashboardTab extends StatefulWidget {
  final String name;
  final String userId;

  const CaregiverDashboardTab(
      {super.key, required this.name, required this.userId});

  @override
  State<CaregiverDashboardTab> createState() => _CaregiverDashboardTabState();
}

class _CaregiverDashboardTabState extends State<CaregiverDashboardTab> {
  final _caregiverService = CaregiverService();
  CaregiverModel? _profile;
  bool _loading = true;
  int _messageCount = 0;
  int _profileViews = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadStats();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    if (widget.userId.isEmpty) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    try {
      final profile =
          await _caregiverService.getCaregiverByUserId(widget.userId);
      if (!mounted) return;
      
      if (profile == null) {
        // Profile doesn't exist yet - show message
        setState(() => _loading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Caregiver profile not found. Please complete your registration.'),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }
      
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile: ${e.toString()}'),
          backgroundColor: AppTheme.accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _loadStats() async {
    try {
      // Get message count from chats collection
      final chatsSnap = await FirebaseFirestore.instance
          .collection('chats')
          .where('caregiverId', isEqualTo: widget.userId)
          .get();

      int totalMessages = 0;
      for (final chatDoc in chatsSnap.docs) {
        final messagesSnap = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatDoc.id)
            .collection('messages')
            .where('receiverId', isEqualTo: widget.userId)
            .get();
        totalMessages += messagesSnap.docs.length;
      }

      // Profile views - placeholder for now (implement view tracking later)
      if (!mounted) return;
      setState(() {
        _messageCount = totalMessages;
        _profileViews = 0; // Will be dynamic when you add view tracking
      });
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  Future<void> _toggleAvailability() async {
    if (_profile == null) return;
    try {
      await _caregiverService.updateProfile(widget.userId, {
        'isAvailable': !_profile!.isAvailable,
      });
      await _loadProfile();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update availability: ${e.toString()}'),
          backgroundColor: AppTheme.accentColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _profile == null
              ? _buildNoProfileView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${widget.name.split(' ').first}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const Text(
                            'Manage your caregiver profile',
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.textGrey),
                          ),
                        ],
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Profile summary card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          backgroundImage: _profile?.profileImage != null
                              ? NetworkImage(_profile!.profileImage!)
                              : null,
                          child: _profile?.profileImage == null
                              ? Text(
                                  widget.name.isNotEmpty
                                      ? widget.name[0].toUpperCase()
                                      : 'C',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 14,
                                      color: AppTheme.orangeAccent),
                                  const SizedBox(width: 4),
                                  Text(
                                    _profile != null
                                        ? '${_profile!.rating.toStringAsFixed(1)} (${_profile!.reviewCount} reviews)'
                                        : 'No reviews yet',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _toggleAvailability,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: (_profile?.isAvailable ?? true)
                                        ? AppTheme.successColor
                                            .withValues(alpha: 0.2)
                                        : Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: (_profile?.isAvailable ?? true)
                                          ? AppTheme.successColor
                                          : Colors.white30,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: (_profile?.isAvailable ??
                                                  true)
                                              ? AppTheme.successColor
                                              : Colors.white38,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        (_profile?.isAvailable ?? true)
                                            ? 'Available'
                                            : 'Unavailable',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: (_profile?.isAvailable ??
                                                  true)
                                              ? AppTheme.successColor
                                              : Colors.white54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_profile?.isVerified == true)
                          const Icon(Icons.verified,
                              color: AppTheme.successColor, size: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.visibility_outlined,
                          label: 'Profile Views',
                          value: _profileViews.toString(),
                          color: AppTheme.purpleAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.message_outlined,
                          label: 'Messages',
                          value: _messageCount.toString(),
                          color: AppTheme.accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.star_outline,
                          label: 'Rating',
                          value: _profile != null
                              ? _profile!.rating.toStringAsFixed(1)
                              : '0.0',
                          color: AppTheme.orangeAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Profile completeness
                  const Text(
                    'Profile Completeness',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Complete your profile to get more clients',
                              style: TextStyle(
                                  fontSize: 13, color: AppTheme.textGrey),
                            ),
                            Text(
                              _getCompleteness(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _getCompletenessValue(),
                            backgroundColor: AppTheme.dividerColor,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._getMissingItems(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.edit_outlined,
                          label: 'Edit Profile',
                          color: AppTheme.primaryColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditCaregiverProfileScreen(
                                  userId: widget.userId,
                                  profile: _profile,
                                ),
                              ),
                            ).then((_) => _loadProfile());
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.schedule_outlined,
                          label: 'Set Schedule',
                          color: AppTheme.purpleAccent,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.add_a_photo_outlined,
                          label: 'Upload Photo',
                          color: AppTheme.accentColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditCaregiverProfileScreen(
                                  userId: widget.userId,
                                  profile: _profile,
                                ),
                              ),
                            ).then((_) => _loadProfile());
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNoProfileView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Profile Not Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your caregiver profile hasn\'t been created yet. Please contact support or complete your registration.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCompleteness() {
    if (_profile == null) return '20%';
    int score = 20;
    if (_profile!.bio.isNotEmpty) score += 20;
    if (_profile!.location.isNotEmpty) score += 15;
    if (_profile!.specializations.isNotEmpty) score += 20;
    if (_profile!.availability.isNotEmpty) score += 15;
    if (_profile!.hourlyRate > 0) score += 10;
    return '$score%';
  }

  double _getCompletenessValue() {
    if (_profile == null) return 0.2;
    double score = 0.2;
    if (_profile!.bio.isNotEmpty) score += 0.2;
    if (_profile!.location.isNotEmpty) score += 0.15;
    if (_profile!.specializations.isNotEmpty) score += 0.2;
    if (_profile!.availability.isNotEmpty) score += 0.15;
    if (_profile!.hourlyRate > 0) score += 0.1;
    return score.clamp(0.0, 1.0);
  }

  List<Widget> _getMissingItems() {
    if (_profile == null) return [];
    final items = <Widget>[];
    if (_profile!.bio.isEmpty) {
      items.add(_MissingItem(label: 'Add a bio'));
    }
    if (_profile!.location.isEmpty) {
      items.add(_MissingItem(label: 'Set your location'));
    }
    if (_profile!.specializations.isEmpty) {
      items.add(_MissingItem(label: 'Add specializations'));
    }
    if (_profile!.availability.isEmpty) {
      items.add(_MissingItem(label: 'Set availability days'));
    }
    return items;
  }
}

class _MissingItem extends StatelessWidget {
  final String label;
  const _MissingItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.radio_button_unchecked,
              size: 16, color: AppTheme.textGrey),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textGrey)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppTheme.textGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
