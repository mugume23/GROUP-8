import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_theme.dart';
import 'parent_search_screen.dart';
import 'parent_chats_screen.dart';
import 'parent_profile_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  int _currentIndex = 0;
  String _name = '';
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _name = prefs.getString('name') ?? 'Parent';
      _userId = prefs.getString('userId') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _HomeTab(name: _name, userId: _userId),
      ParentSearchScreen(userId: _userId),
      ParentChatsScreen(userId: _userId),
      ParentProfileScreen(userId: _userId),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ── Home tab ─────────────────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  final String name;
  final String userId;
  const _HomeTab({required this.name, required this.userId});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  int _totalCaregivers = 0;
  int _verifiedCaregivers = 0;
  double _avgRating = 0.0;
  bool _statsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('caregivers')
          .get();
      if (!mounted) return;
      final docs = snap.docs;
      final total = docs.length;
      final verified =
          docs.where((d) => d.data()['isVerified'] == true).length;
      double ratingSum = 0;
      int ratingCount = 0;
      for (final d in docs) {
        final r = (d.data()['rating'] ?? 0.0) as num;
        if (r > 0) {
          ratingSum += r;
          ratingCount++;
        }
      }
      setState(() {
        _totalCaregivers = total;
        _verifiedCaregivers = verified;
        _avgRating = ratingCount > 0 ? ratingSum / ratingCount : 0.0;
        _statsLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _statsLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header — no emoji
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
                      'Find the perfect caregiver',
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

            // Hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(26, 31, 60, 0.30),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find Trusted\nCaregivers Near You',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Verified professionals ready to help',
                    style: TextStyle(
                        fontSize: 13, color: Colors.white60),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Search Now',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward,
                            color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Dynamic stats
            Row(
              children: [
                Expanded(
                    child: _StatCard(
                        icon: Icons.people_outline,
                        label: 'Caregivers',
                        value: _statsLoaded
                            ? '$_totalCaregivers'
                            : '...',
                        color: AppTheme.purpleAccent)),
                const SizedBox(width: 12),
                Expanded(
                    child: _StatCard(
                        icon: Icons.verified_outlined,
                        label: 'Verified',
                        value: _statsLoaded
                            ? '$_verifiedCaregivers'
                            : '...',
                        color: AppTheme.successColor)),
                const SizedBox(width: 12),
                Expanded(
                    child: _StatCard(
                        icon: Icons.star_outline,
                        label: 'Avg Rating',
                        value: _statsLoaded
                            ? _avgRating > 0
                                ? _avgRating.toStringAsFixed(1)
                                : 'N/A'
                            : '...',
                        color: AppTheme.orangeAccent)),
              ],
            ),
            const SizedBox(height: 28),

            // Categories
            const Text(
              'Browse by Specialization',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _CategoryChip(
                      label: 'Infant Care',
                      icon: Icons.child_friendly),
                  _CategoryChip(
                      label: 'Autism',
                      icon: Icons.psychology_outlined),
                  _CategoryChip(
                      label: 'Elderly',
                      icon: Icons.elderly_outlined),
                  _CategoryChip(
                      label: 'Special Needs',
                      icon: Icons.accessibility_new),
                  _CategoryChip(
                      label: 'Overnight',
                      icon: Icons.nightlight_outlined),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Safety tips
            const Text(
              'Safety Tips',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: const Column(
                children: [
                  _TipRow(
                      icon: Icons.verified_user_outlined,
                      text: 'Always check caregiver verification badge'),
                  Divider(height: 20, color: AppTheme.dividerColor),
                  _TipRow(
                      icon: Icons.rate_review_outlined,
                      text: 'Read reviews from other parents'),
                  Divider(height: 20, color: AppTheme.dividerColor),
                  _TipRow(
                      icon: Icons.chat_outlined,
                      text: 'Chat before booking to confirm fit'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

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
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textGrey)),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _CategoryChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(26, 31, 60, 0.06),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark)),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

// ── Bottom nav ────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardWhite,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(26, 31, 60, 0.08),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0)),
              _NavItem(
                  icon: Icons.search_outlined,
                  activeIcon: Icons.search,
                  label: 'Search',
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1)),
              _NavItem(
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: 'Chats',
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2)),
              _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  isActive: currentIndex == 3,
                  onTap: () => onTap(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryColor.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? AppTheme.primaryColor
                  : AppTheme.textGrey,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: isActive
                    ? AppTheme.primaryColor
                    : AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
