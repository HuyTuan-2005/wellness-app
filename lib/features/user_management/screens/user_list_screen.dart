import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/user_management/widgets/user_card.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Quản lý người dùng",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),

              UserCard(
                title: "Huy Tuấn",
                subTitle: "Huytuan.learn@gmail.com",
                isActive: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
