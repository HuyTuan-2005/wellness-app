import 'package:flutter/material.dart';
// Import Widget item chúng ta vừa tạo (đảm bảo đường dẫn import của bạn đúng nhé)
import '../widgets/notification_item.dart';

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({super.key});

  @override
  State<AdminNotificationScreen> createState() =>
      _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  // 1. Tạo một danh sách dữ liệu giả (Mock data)
  final List<Map<String, String>> _notifications = [
    {
      'title': 'Bảo trì hệ thống máy chủ',
      'content':
          'Hệ thống sẽ bảo trì từ 2h-4h sáng ngày 15/04. Mong quý khách thông cảm.',
      'date': '10:00 14/04/2026',
    },
    {
      'title': 'Mẹo giữ gìn sức khỏe mùa dịch',
      'content':
          'Hãy uống đủ nước và tập thể dục thường xuyên ít nhất 30 phút mỗi ngày nhé!',
      'date': '08:00 13/04/2026',
    },
  ];

  // 2. Hàm hiển thị Modal Bottom Sheet (Khung trượt từ dưới lên để soạn thông báo)
  void _showCreateNotificationModal() {
    // Tạo 2 controller để lấy dữ liệu từ ô nhập liệu
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Cho phép khung trượt cao lên khi bàn phím xuất hiện
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(
              context,
            ).viewInsets.bottom, // Đẩy UI lên khi hiện bàn phím
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Chỉ chiếm chiều cao vừa đủ nội dung
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thanh gạch ngang nhỏ ở trên cùng (UI Handle)
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tiêu đề
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tạo thông báo mới',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Ô nhập Tiêu đề
                const Text(
                  'Tiêu đề',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tiêu đề thông báo...',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF246BFD)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Ô nhập Nội dung
                const Text(
                  'Nội dung',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Nhập nội dung chi tiết...',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF246BFD)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Nút Phát thông báo
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty &&
                          contentController.text.isNotEmpty) {
                        // Thêm thông báo mới vào đầu danh sách
                        setState(() {
                          _notifications.insert(0, {
                            'title': titleController.text,
                            'content': contentController.text,
                            // Demo lấy giờ hiện tại
                            'date':
                                '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                          });
                        });
                        Navigator.pop(context); // Đóng BottomSheet

                        // Hiện thông báo (Toast/Snackbar) thành công
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã gửi thông báo thành công!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF246BFD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Phát thông báo ngay',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Khoảng trống an toàn dưới cùng
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Quản lý thông báo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      // 3. Sử dụng ListView.builder để render danh sách Widget
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notif = _notifications[index];
          return NotificationItem(
            title: notif['title']!,
            content: notif['content']!,
            date: notif['date']!,
          );
        },
      ),

      // Nút (+) nổi để tạo thông báo mới
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateNotificationModal, // Gọi hàm mở Modal
        backgroundColor: const Color(0xFF246BFD),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
