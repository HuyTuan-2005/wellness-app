import 'package:flutter/material.dart';
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
      body: UserCard(
        title: "Huy Tuấn",
        subTitle: "Huytuan.learn@gmail.com",
        isActive: false,
      ),
    );
  }
}
