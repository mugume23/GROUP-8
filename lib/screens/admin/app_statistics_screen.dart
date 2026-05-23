import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';

class AppStatisticsScreen extends StatelessWidget {
  const AppStatisticsScreen({super.key});

  Future<Map<String, dynamic>> _getDetailedStats() async {
    final caregivers = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'caregiver')
        .get();

    final parents = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'parent')
        .get();

    final requests = await FirebaseFirestore.instance
        .collection('requests')
        .get();

    final chats = await FirebaseFirestore.instance
        .collection('chats')
        .get();

    final verifiedCaregivers = caregivers.docs
        .where((doc) => doc.data()['isVerified'] == true)
        .length;

    final pendingCaregivers = caregivers.docs
        .where((doc) => doc.data()['isVerified'] != true)
        .length;

    // Calculate average rating
    double totalRating = 0;
    int ratedCaregivers = 0;
    for (var doc in caregivers.docs) {
      final rating = doc.data()['rating'];
      if (rating != null && rating > 0) {
        totalRating += rating;
        ratedCaregivers++;
      }
    }
    final avgRating = ratedCaregivers > 0 ? totalRating / ratedCaregivers : 0.0;

    // Count requests by status
    final pendingRequests = requests.docs
        .where((doc) => doc.data()['status'] == 'pending')
        .length;
    final acceptedRequests = requests.docs
        .where((doc) => doc.data()['status'] == 'accepted')
        .length;
    final rejectedRequests = requests.docs
        .where((doc) => doc.data()['status'] == 'rejected')
        .length;

    return {
      'totalCaregivers': caregivers.docs.length,
      'verifiedCaregivers': verifiedCaregivers,
      'pendingCaregivers': pendingCaregivers,
      'totalParents': parents.docs.length,
      'totalRequests': requests.docs.length,
      'pendingRequests': pendingRequests,
      'acceptedRequests': acceptedRequests,
      'rejectedRequests': rejectedRequests,
      'totalChats': chats.docs.length,
      'averageRating': avgRating,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Statistics'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getDetailedStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final stats = snapshot.data ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview section
                const Text(
                  'Platform Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Users',
                        value: '${(stats['totalCaregivers'] ?? 0) + (stats['totalParents'] ?? 0)}',
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Chats',
                        value: '${stats['totalChats'] ?? 0}',
                        icon: Icons.chat,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Caregivers section
                const Text(
                  'Caregivers',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _StatCard(
                  title: 'Total Caregivers',
                  value: '${stats['totalCaregivers'] ?? 0}',
                  icon: Icons.people_outline,
                  color: Colors.blue,
                  isWide: true,
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Verified',
                        value: '${stats['verifiedCaregivers'] ?? 0}',
                        icon: Icons.verified,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Pending',
                        value: '${stats['pendingCaregivers'] ?? 0}',
                        icon: Icons.pending,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                _StatCard(
                  title: 'Average Rating',
                  value: (stats['averageRating'] ?? 0.0).toStringAsFixed(1),
                  icon: Icons.star,
                  color: Colors.amber,
                  isWide: true,
                ),
                const SizedBox(height: 30),
                
                // Parents section
                const Text(
                  'Parents',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _StatCard(
                  title: 'Total Parents',
                  value: '${stats['totalParents'] ?? 0}',
                  icon: Icons.family_restroom,
                  color: Colors.green,
                  isWide: true,
                ),
                const SizedBox(height: 30),
                
                // Requests section
                const Text(
                  'Requests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _StatCard(
                  title: 'Total Requests',
                  value: '${stats['totalRequests'] ?? 0}',
                  icon: Icons.request_page,
                  color: Colors.indigo,
                  isWide: true,
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Pending',
                        value: '${stats['pendingRequests'] ?? 0}',
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Accepted',
                        value: '${stats['acceptedRequests'] ?? 0}',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                _StatCard(
                  title: 'Rejected',
                  value: '${stats['rejectedRequests'] ?? 0}',
                  icon: Icons.cancel,
                  color: Colors.red,
                  isWide: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isWide;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isWide
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
    );
  }
}
