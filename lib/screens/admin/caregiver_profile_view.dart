import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';

class CaregiverProfileView extends StatelessWidget {
  final String userId;

  const CaregiverProfileView({super.key, required this.userId});

  Future<Map<String, dynamic>> _getCaregiverData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    final caregiverDoc = await FirebaseFirestore.instance
        .collection('caregivers')
        .doc(userId)
        .get();

    return {
      'user': userDoc.data() ?? {},
      'caregiver': caregiverDoc.data() ?? {},
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Profile'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getCaregiverData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userData = snapshot.data?['user'] as Map<String, dynamic>? ?? {};
          final caregiverData = snapshot.data?['caregiver'] as Map<String, dynamic>? ?? {};

          final isVerified = userData['isVerified'] == true;
          final profileImage = caregiverData['profileImage'];

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with profile image
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      // Profile Image
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 58,
                              backgroundColor: Colors.white,
                              backgroundImage: profileImage != null
                                  ? NetworkImage(profileImage)
                                  : null,
                              child: profileImage == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppTheme.primaryColor,
                                    )
                                  : null,
                            ),
                          ),
                          if (isVerified)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        userData['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Phone
                      Text(
                        userData['phone'] ?? 'No phone',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isVerified
                              ? Colors.green
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isVerified ? 'VERIFIED' : 'UNVERIFIED',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),

                // Details sections
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      _SectionTitle(title: 'Basic Information'),
                      const SizedBox(height: 12),
                      _InfoCard(
                        children: [
                          _InfoRow(
                            icon: Icons.cake_outlined,
                            label: 'Age',
                            value: '${caregiverData['age'] ?? 'Not set'} years',
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.person_outline,
                            label: 'Gender',
                            value: caregiverData['gender'] ?? 'Not specified',
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'Location',
                            value: userData['district'] ?? 'Not specified',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Professional Information
                      _SectionTitle(title: 'Professional Information'),
                      const SizedBox(height: 12),
                      _InfoCard(
                        children: [
                          _InfoRow(
                            icon: Icons.work_outline,
                            label: 'Experience',
                            value: caregiverData['experience'] ?? 'Not specified',
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.attach_money,
                            label: 'Hourly Rate',
                            value: 'UGX ${caregiverData['hourlyRate'] ?? 'Not set'}',
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.star_outline,
                            label: 'Rating',
                            value: '${caregiverData['rating'] ?? 0.0} ⭐',
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.reviews_outlined,
                            label: 'Reviews',
                            value: '${caregiverData['reviewCount'] ?? 0} reviews',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Bio
                      if (caregiverData['bio'] != null && 
                          caregiverData['bio'].toString().isNotEmpty) ...[
                        _SectionTitle(title: 'About'),
                        const SizedBox(height: 12),
                        _InfoCard(
                          children: [
                            Text(
                              caregiverData['bio'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Specializations
                      if (caregiverData['specializations'] != null &&
                          (caregiverData['specializations'] as List).isNotEmpty) ...[
                        _SectionTitle(title: 'Specializations'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (caregiverData['specializations'] as List)
                              .map((spec) => Chip(
                                    label: Text(spec.toString()),
                                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                                    labelStyle: const TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: 12,
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Account Information
                      _SectionTitle(title: 'Account Information'),
                      const SizedBox(height: 12),
                      _InfoCard(
                        children: [
                          _InfoRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Joined',
                            value: userData['createdAt'] != null
                                ? _formatDate(userData['createdAt'])
                                : 'Unknown',
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.badge_outlined,
                            label: 'User ID',
                            value: userId,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      final date = (timestamp as Timestamp).toDate();
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textDark,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
