import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../models/request_model.dart';
import '../../services/request_service.dart';
import 'package:intl/intl.dart';

class CaregiverRequestsScreen extends StatefulWidget {
  final String userId;
  const CaregiverRequestsScreen({super.key, required this.userId});

  @override
  State<CaregiverRequestsScreen> createState() =>
      _CaregiverRequestsScreenState();
}

class _CaregiverRequestsScreenState extends State<CaregiverRequestsScreen> {
  final _requestService = RequestService();
  int _selectedTab = 0;

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hrs ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  List<RequestModel> _filterRequests(List<RequestModel> requests) {
    if (_selectedTab == 0) {
      return requests.where((r) => r.status == 'pending').toList();
    } else if (_selectedTab == 1) {
      return requests.where((r) => r.status == 'accepted').toList();
    } else {
      return requests.where((r) => r.status == 'declined').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<RequestModel>>(
        stream: _requestService.getRequestsForCaregiver(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 60, color: AppTheme.accentColor),
                  const SizedBox(height: 12),
                  Text(
                    'Error loading requests',
                    style: const TextStyle(
                        color: AppTheme.textGrey, fontSize: 15),
                  ),
                ],
              ),
            );
          }

          final allRequests = snapshot.data ?? [];
          final filtered = _filterRequests(allRequests);
          final pendingCount =
              allRequests.where((r) => r.status == 'pending').length;

          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Requests',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    if (pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$pendingCount New',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _buildTab('Pending', 0),
                      _buildTab('Accepted', 1),
                      _buildTab('Declined', 2),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedTab == 0
                                  ? Icons.inbox_outlined
                                  : _selectedTab == 1
                                      ? Icons.check_circle_outline
                                      : Icons.cancel_outlined,
                              size: 60,
                              color: AppTheme.textGrey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _selectedTab == 0
                                  ? 'No pending requests'
                                  : _selectedTab == 1
                                      ? 'No accepted requests'
                                      : 'No declined requests',
                              style: const TextStyle(
                                  color: AppTheme.textGrey, fontSize: 15),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final req = filtered[i];
                          return _RequestCard(
                            request: req,
                            timeText: _formatTime(req.createdAt),
                            onAccept: req.status == 'pending'
                                ? () async {
                                    await _requestService
                                        .acceptRequest(req.id);
                                  }
                                : null,
                            onDecline: req.status == 'pending'
                                ? () async {
                                    await _requestService
                                        .declineRequest(req.id);
                                  }
                                : null,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppTheme.textGrey,
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RequestModel request;
  final String timeText;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const _RequestCard({
    required this.request,
    required this.timeText,
    this.onAccept,
    this.onDecline,
  });

  Color get _statusColor {
    switch (request.status) {
      case 'accepted':
        return AppTheme.successColor;
      case 'declined':
        return AppTheme.accentColor;
      default:
        return AppTheme.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  request.parentName.isNotEmpty
                      ? request.parentName[0].toUpperCase()
                      : 'P',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.parentName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      timeText,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textGrey),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.message,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textGrey,
              height: 1.5,
            ),
          ),
          if (onAccept != null && onDecline != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.accentColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
