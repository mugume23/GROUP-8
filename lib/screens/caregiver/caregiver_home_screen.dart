import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_theme.dart';
import 'caregiver_dashboard_tab.dart';
import 'caregiver_chats_screen.dart';
import 'caregiver_profile_screen.dart';
import 'caregiver_requests_screen.dart';
import '../../widgets/custom_navigation_bar.dart';

class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
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
    setState(() {
      _name = prefs.getString('name') ?? 'Caregiver';
      _userId = prefs.getString('userId') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      CaregiverDashboardTab(name: _name, userId: _userId),
      CaregiverRequestsScreen(userId: _userId),
      CaregiverChatsScreen(userId: _userId),
      CaregiverProfileScreen(userId: _userId),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: screens[_currentIndex],
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          CustomNavBarItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
          ),
          CustomNavBarItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment,
            label: 'Requests',
          ),
          CustomNavBarItem(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            label: 'Chats',
          ),
          CustomNavBarItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

