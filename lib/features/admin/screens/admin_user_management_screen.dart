import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_user_service.dart';
import 'package:wellness_app/core/theme/app_colors.dart';

enum UserFilter { all, locked, inactive }

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final AdminUserService _userService = AdminUserService();
  UserFilter _currentFilter = UserFilter.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

      final String name = (data['displayName'] ?? '').toString().toLowerCase();
      final String email = (data['email'] ?? '').toString().toLowerCase();

      // Lọc theo tìm kiếm
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!name.contains(query) && !email.contains(query)) {
          return false;
        }
      }

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
    String? lockReason;

    // Nếu chuẩn bị khóa (currentStatus == false), hiện dialog nhập lý do
    if (!currentStatus) {
      final TextEditingController reasonController = TextEditingController();
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận khóa tài khoản', style: TextStyle(color: AppColors.error)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bạn có chắc chắn muốn khóa tài khoản này không?'),
              const SizedBox(height: 12),
              const Text('Lý do khóa (Bắt buộc):', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: 'Nhập lý do khóa...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), 
              child: const Text('Hủy')
            ),
            TextButton(
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập lý do!')),
                  );
                  return;
                }
                Navigator.pop(context, true);
              }, 
              child: const Text('Khóa', style: TextStyle(color: AppColors.error))
            ),
          ],
        ),
      );

      if (confirm != true) return; // Hủy
      lockReason = reasonController.text.trim();
    } else {
      // Nếu chuẩn bị mở khóa
      final bool? confirmUnlock = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận mở khóa', style: TextStyle(color: Colors.green)),
          content: const Text('Bạn có chắc chắn muốn mở khóa tài khoản này không? Người dùng sẽ có thể đăng nhập lại vào hệ thống.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), 
              child: const Text('Hủy')
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), 
              child: const Text('Mở khóa', style: TextStyle(color: Colors.green))
            ),
          ],
        ),
      );

      if (confirmUnlock != true) return; // Hủy
    }

    try {
      await _userService.toggleLockStatus(uid, currentStatus, reason: lockReason);
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

  /// Gửi email đặt lại mật khẩu
  Future<void> _resetPassword(String email) async {
    try {
      await _userService.sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã gửi email đặt lại mật khẩu đến $email'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi gửi email: $e'), backgroundColor: AppColors.error),
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
          // Thanh Tìm kiếm
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên hoặc email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear), 
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      }
                    ) 
                  : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

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
              // Query tất cả user không phải admin thông qua Service
              stream: _userService.getUsersStream(),
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
                    final lockReason = data['lockReason'] as String?;
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
                            if (isLocked && lockReason != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Lý do: $lockReason',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'toggle_lock':
                                _toggleLockStatus(doc.id, isLocked);
                                break;
                              case 'reset_password':
                                _resetPassword(email);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'toggle_lock',
                              child: ListTile(
                                leading: Icon(isLocked ? Icons.lock_open : Icons.lock, color: isLocked ? Colors.green : AppColors.warning),
                                title: Text(isLocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            PopupMenuItem(
                              value: 'reset_password',
                              child: ListTile(
                                leading: const Icon(Icons.password, color: AppColors.primary),
                                title: const Text('Đặt lại mật khẩu'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
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
