import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/system_notifications/screens/user_notification_screen.dart';

class NotificationIconBadge extends StatefulWidget {
  const NotificationIconBadge({super.key});

  @override
  State<NotificationIconBadge> createState() => _NotificationIconBadgeState();
}

class _NotificationIconBadgeState extends State<NotificationIconBadge> {
  DateTime? _lastReadTime;

  @override
  void initState() {
    super.initState();
    _loadLastReadTime();
  }

  Future<void> _loadLastReadTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('last_notification_read_time');
    if (timestamp != null && mounted) {
      setState(() {
        _lastReadTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      });
    }
  }

  Future<void> _markAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_notification_read_time', DateTime.now().millisecondsSinceEpoch);
    if (mounted) {
      setState(() {
        _lastReadTime = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
      builder: (context, snapshot) {
        int unreadCount = 0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final createdAt = data['createdAt'] as Timestamp?;
            if (createdAt != null) {
              final notificationDate = createdAt.toDate();
              if (_lastReadTime == null || notificationDate.isAfter(_lastReadTime!)) {
                unreadCount++;
              }
            }
          }
        }

        Widget iconWidget = const Icon(
          Icons.notifications_none,
          color: AppColors.textPrimary,
        );

        if (unreadCount > 0) {
          iconWidget = Badge(
            label: Text('$unreadCount'),
            backgroundColor: Colors.redAccent,
            child: iconWidget,
          );
        }

        return IconButton(
          icon: iconWidget,
          onPressed: () async {
            await _markAsRead();
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UserNotificationScreen(),
              ),
            );
          },
        );
      },
    );
  }
}
