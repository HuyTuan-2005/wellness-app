import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/user_management/widgets/user_card.dart';

/// Trang quản lý người dùng – search bar cố định + danh sách cuộn.
class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ──── Mock Data dài để test scroll ────
  final List<Map<String, dynamic>> _allUsers = [
    {'name': 'Nguyễn Huy Tuấn', 'email': 'huytuan@gmail.com', 'isActive': true, 'role': 'Admin'},
    {'name': 'Trần Trung Tính', 'email': 'truntinh@gmail.com', 'isActive': true, 'role': 'Người dùng'},
    {'name': 'Lê Quốc Trường', 'email': 'quoctruong@gmail.com', 'isActive': false, 'role': 'Người dùng'},
    {'name': 'Phạm Hoàng Nhân', 'email': 'hoangnhan@gmail.com', 'isActive': true, 'role': 'Người dùng'},
    {'name': 'Võ Thị Lan', 'email': 'vothilan@gmail.com', 'isActive': true, 'role': 'Người dùng'},
    {'name': 'Đặng Minh Quân', 'email': 'minhquan@gmail.com', 'isActive': false, 'role': 'Người dùng'},
    {'name': 'Huỳnh Thị Mai', 'email': 'thmai@gmail.com', 'isActive': true, 'role': 'Người dùng'},
    {'name': 'Bùi Văn Hùng', 'email': 'vanhung@gmail.com', 'isActive': true, 'role': 'Người dùng'},
    {'name': 'Ngô Thanh Tùng', 'email': 'thanhtung@gmail.com', 'isActive': false, 'role': 'Người dùng'},
    {'name': 'Lý Hoàng Long', 'email': 'hoanglong@gmail.com', 'isActive': true, 'role': 'Người dùng'},
    {'name': 'Trịnh Ngọc Hân', 'email': 'ngochan@gmail.com', 'isActive': true, 'role': 'Bác sĩ'},
    {'name': 'Dương Minh Trí', 'email': 'minhtri@gmail.com', 'isActive': true, 'role': 'Người dùng'},
    {'name': 'Phan Thị Hương', 'email': 'thihuong@gmail.com', 'isActive': false, 'role': 'Người dùng'},
    {'name': 'Cao Đức Anh', 'email': 'ducanh@gmail.com', 'isActive': true, 'role': 'Bác sĩ'},
    {'name': 'Mai Xuân Bách', 'email': 'xuanbach@gmail.com', 'isActive': true, 'role': 'Người dùng'},
  ];

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _allUsers;
    return _allUsers.where((user) {
      final name = (user['name'] as String).toLowerCase();
      final email = (user['email'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header + Search (cố định) ──────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quản lý người dùng',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_allUsers.length} tài khoản trong hệ thống',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tìm theo tên hoặc email...',
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ─── Danh sách người dùng (scrollable) ──
            Expanded(
              child: users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Không tìm thấy người dùng',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return UserCard(
                          name: user['name'],
                          email: user['email'],
                          isActive: user['isActive'],
                          role: user['role'],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
