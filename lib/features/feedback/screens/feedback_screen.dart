import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/feedback/screens/feedback_details_screen.dart';
import '../widgets/feedback_item.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  // 1. Dữ liệu giả (Mock data) có thêm trường isRead và reply
  final List<Map<String, dynamic>> _feedbacks = [
    {
      'id': 1,
      'name': 'Nguyễn Văn A',
      'email': 'nva123@gmail.com',
      'content':
          'Ứng dụng rất hữu ích, nhưng phần biểu đồ hiển thị hơi chậm trên điện thoại cũ của tôi.' +
          'Ứng dụng rất hữu ích, nhưng phần biểu đồ hiển thị hơi chậm trên điện thoại cũ của tôi.' +
          'Ứng dụng rất hữu ích, nhưng phần biểu đồ hiển thị hơi chậm trên điện thoại cũ của tôi.' +
          'Ứng dụng rất hữu ích, nhưng phần biểu đồ hiển thị hơi chậm trên điện thoại cũ của tôi.' +
          'Ứng dụng rất hữu ích, nhưng phần biểu đồ hiển thị hơi chậm trên điện thoại cũ của tôi.' +
          'Ứng dụng rất hữu ích, nhưng phần biểu đồ hiển thị hơi chậm trên điện thoại cũ của tôi.' +
          'Ứng dụng rất hữu ích, nhưng phần biểu đồ hiển thị hơi chậm trên điện thoại cũ của tôi.' +
          'Ứng dụng rất hữu ích, nhưng phần biểu đồ hiển thị hơi chậm trên điện thoại cũ của tôi.' +
          'Ứng dụng rất hữu ích, nhưng phần biểu đồ hiển thị hơi chậm trên điện thoại cũ của tôi.',
      'date': '14/04/2026',
      'isRead': false,
      'reply': '',
    },
    {
      'id': 2,
      'name': 'Trần Quốc Trường',
      'email': 'truong@gmail.com',
      'content':
          'Tôi muốn đề xuất thêm tính năng kết nối và đồng bộ nhịp tim qua Apple Health.',
      'date': '12/04/2026',
      'isRead': true,
      'reply':
          'Cảm ơn bạn, đội ngũ phát triển đã ghi nhận và sẽ nghiên cứu tích hợp trong phiên bản sắp tới.',
    },

    {
      'id': 2,
      'name': 'Trần Quốc Trường',
      'email': 'truong@gmail.com',
      'content':
          'Tôi muốn đề xuất thêm tính năng kết nối và đồng bộ nhịp tim qua Apple Health.',
      'date': '12/04/2026',
      'isRead': false,
      'reply':
          'Cảm ơn bạn, đội ngũ phát triển đã ghi nhận và sẽ nghiên cứu tích hợp trong phiên bản sắp tới.',
    },

    {
      'id': 2,
      'name': 'Trần Quốc Trường',
      'email': 'truong@gmail.com',
      'content':
          'Tôi muốn đề xuất thêm tính năng kết nối và đồng bộ nhịp tim qua Apple Health.',
      'date': '12/04/2026',
      'isRead': true,
      'reply':
          'Cảm ơn bạn, đội ngũ phát triển đã ghi nhận và sẽ nghiên cứu tích hợp trong phiên bản sắp tới.',
    },
  ];

  // 2. Hàm mở khung Chi tiết & Trả lời
  void _openFeedbackDetail(int index) {
    // Đánh dấu là đã đọc ngay khi mở
    setState(() {
      _feedbacks[index]['isRead'] = true;
    });

    final fb = _feedbacks[index];
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // scrollable: true,
          backgroundColor: AppColors.surface,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Phản hồi nhanh"),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.close),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: AppColors.background,
                ),
                child: Column(
                  children: [
                    ListTile(
                      visualDensity: VisualDensity.compact,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 22,
                        child: Text(fb['name'].split(" ").last[0]),
                      ),
                      title: Text(
                        fb["name"],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(fb["email"]),
                    ),
                    // Row(
                    //   children: [
                    //     CircleAvatar(
                    //       radius: 22,
                    //       child: Text(fb['name'].split(" ").last[0]),
                    //     ),
                    //     const SizedBox(width: 12),
                    //     Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text(
                    //           fb["name"],
                    //           style: TextStyle(fontWeight: FontWeight.bold),
                    //         ),
                    //         Text(fb["email"]),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        color: AppColors.surface,

                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fb['date'],
                            style: TextStyle(
                              color: AppColors.textDark.withValues(alpha: 0.4),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FeedbackDetailsScreen(),
                                  fullscreenDialog: false,
                                ),
                              );
                            },
                            child: Text(
                              fb['content'],
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Phản hồi của bạn",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              TextField(
                maxLines: 3,
                controller: replyController,
                decoration: InputDecoration(
                  hintText: "Nhập phản hồi",
                  hintStyle: TextStyle(
                    color: AppColors.textDark.withAlpha(90),
                    fontSize: 15,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: AppColors.border),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },

              label: Text("Gửi"),
              icon: const Icon(Icons.send, color: Colors.blue),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
              ),
              iconAlignment: IconAlignment.end,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Đếm số lượng thư chưa đọc
    final unreadCount = _feedbacks.where((fb) => !fb['isRead']).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Góp ý từ người dùng',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 8),
            // Hiện Badge màu đỏ báo số lượng chưa đọc
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadCount chưa đọc',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _feedbacks.length,
        itemBuilder: (context, index) {
          final fb = _feedbacks[index];
          return FeedbackItem(
            name: fb['name'],
            email: fb['email'],
            content: fb['content'],
            date: fb['date'],
            isRead: fb['isRead'],
            onTap: () => _openFeedbackDetail(index),
          );
        },
      ),
    );
  }
}
