import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/user_management/widgets/user_card.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<Map<String, dynamic>> users = [
    {'title': "Huy Tuấn", 'subtitle': "huytuan@gmail.com", 'isActive': true},
    {'title': "Trung Tính", 'subtitle': "huytuan@gmail.com", 'isActive': true},
    {
      'title': "Quốc Trường",
      'subtitle': "huytuan@gmail.com",
      'isActive': false,
    },
    {'title': "Hoàng Nhân", 'subtitle': "huytuan@gmail.com", 'isActive': true},
    {'title': "Hoàng Nhân", 'subtitle': "huytuan@gmail.com", 'isActive': true},
  ];

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

              SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  iconColor: AppColors.border,
                  label: Text("Tìm theo tên..."),
                  contentPadding: EdgeInsets.symmetric(horizontal: 5),
                  prefixIcon: Icon(Icons.search_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(width: 1, color: AppColors.error),
                  ),
                ),
              ),

              SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return UserCard(
                      title: users[index]['title'],
                      subTitle: users[index]['subtitle'],
                      isActive: users[index]['isActive'],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
