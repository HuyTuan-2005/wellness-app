import 'package:flutter/material.dart';
import 'package:wellness_app/features/admin/services/admin_user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/user_management/widgets/user_card.dart';
import 'package:wellness_app/features/admin/controllers/admin_user_controller.dart';

/// Trang quản lý người dùng – search bar cố định + danh sách cuộn.
class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final AdminUserService _userService = AdminUserService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Hàm cập nhật trạng thái khóa tài khoản
  Future<void> _toggleLockStatus(String uid, bool currentStatus) async {
    await AdminUserController.handleToggleLockStatus(
      context: context,
      uid: uid,
      currentStatus: currentStatus,
      userService: _userService,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: StreamBuilder<QuerySnapshot>(
                stream: _userService.getUsersStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  
                  // Filter by search query
                  final filteredDocs = AdminUserController.filterUsersBySearchQuery(docs, _searchQuery);

                  if (filteredDocs.isEmpty) {
                    return Center(
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
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        child: Text(
                          '${docs.length} tài khoản trong hệ thống',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            final doc = filteredDocs[index];
                            final data = doc.data() as Map<String, dynamic>;

                            final email = data['email'] ?? 'Không có email';
                            final name = data['displayName'] ?? 'Người dùng';
                            final photoUrl = data['photoURL'];
                            final isLocked = data['isLocked'] ?? false;

                            final lockReason = data['lockReason'] as String?;

                            return UserCard(
                              name: name,
                              email: email,
                              isActive: !isLocked,
                              avatarUrl: photoUrl,
                              lockReason: lockReason,
                              onTap: () => _toggleLockStatus(doc.id, isLocked),
                            );
                          },
                        ),
                      ),
                    ],
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
