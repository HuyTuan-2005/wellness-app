import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/core/theme/app_colors.dart';

enum UserFilter { all, locked, inactive }

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserFilter _currentFilter = UserFilter.all;

  /// Tính toán thời gian hoạt động cuối (Hiển thị dạng: 2 ngày trước, 5 phút trước...)
  String _formatTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Chưa từng hoạt động';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }

  /// Lọc danh sách users ở client-side (tránh giới hạn query phức tạp của Firestore)
  List<QueryDocumentSnapshot> _filterUsers(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final bool isLocked = data['isLocked'] ?? false;
      final Timestamp? lastActive = data['lastActive'];

      switch (_currentFilter) {
        case UserFilter.locked:
          return isLocked;
        case UserFilter.inactive:
          if (lastActive == null) return true; // Chưa từng hđ cũng coi là inactive
          final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
          return lastActive.toDate().isBefore(sevenDaysAgo);
        case UserFilter.all:
          return true;
      }
    }).toList();
  }

  /// Hàm cập nhật trạng thái khóa tài khoản
  Future<void> _toggleLockStatus(String uid, bool currentStatus) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isLocked': !currentStatus,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!currentStatus ? 'Đã khóa tài khoản' : 'Đã mở khóa tài khoản'),
            backgroundColor: !currentStatus ? AppColors.error : Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Thanh Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: _currentFilter == UserFilter.all,
                  onSelected: (selected) {
                    if (selected) setState(() => _currentFilter = UserFilter.all);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Đã khóa'),
                  selected: _currentFilter == UserFilter.locked,
                  onSelected: (selected) {
                    if (selected) setState(() => _currentFilter = UserFilter.locked);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Lâu không hoạt động'),
                  selected: _currentFilter == UserFilter.inactive,
                  onSelected: (selected) {
                    if (selected) setState(() => _currentFilter = UserFilter.inactive);
                  },
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),

          // Danh sách người dùng
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Query tất cả user không phải admin
              stream: _firestore
                  .collection('users')
                  .where('role', isNotEqualTo: 'admin')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                final filteredDocs = _filterUsers(docs);

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text('Không tìm thấy người dùng nào.'));
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final email = data['email'] ?? 'Không có email';
                    final name = data['displayName'] ?? 'Người dùng';
                    final photoUrl = data['photoURL'];
                    final isLocked = data['isLocked'] ?? false;
                    final lastActive = data['lastActive'] as Timestamp?;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: photoUrl != null && photoUrl.toString().isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl == null || photoUrl.toString().isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isLocked ? Colors.grey : Colors.black87,
                            decoration: isLocked ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(email, style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              'Hoạt động: ${_formatTimeAgo(lastActive)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isLocked ? AppColors.error : Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Switch(
                          value: isLocked,
                          activeThumbColor: AppColors.error,
                          onChanged: (value) => _toggleLockStatus(doc.id, isLocked),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
