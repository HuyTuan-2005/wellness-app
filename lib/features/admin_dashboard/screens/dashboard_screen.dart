<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:wellness_app/features/user_management/screens/user_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 1;

  final List<Widget> _page = [
    Container(),
    UserListScreen(),
    Container(),
    Container(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _page[_currentIndex]),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTap,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          selectedIconTheme: IconThemeData(size: 30),
          unselectedIconTheme: IconThemeData(size: 30),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: "Thống kê",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              label: "Thành viên",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none),
              label: "Thông báo",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: "Góp ý",
            ),
          ],
        ),
      ),
    );
  }
}
=======

>>>>>>> 419a040 (add user_card)
