import 'package:flutter/material.dart';
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
  ];

  // 2. Hàm mở khung Chi tiết & Trả lời
  void _openFeedbackDetail(int index) {
    // Đánh dấu là đã đọc ngay khi mở
    setState(() {
      _feedbacks[index]['isRead'] = true;
    });

    final fb = _feedbacks[index];
    final replyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // Cần dùng StatefulBuilder để UI trong BottomSheet cập nhật ngay khi ấn "Gửi phản hồi"
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header của popup (Avatar + Tên + Nút tắt)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue.shade50,
                          child: Text(
                            fb['name'][0].toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF246BFD),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fb['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                fb['email'],
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Nội dung góp ý của user
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        fb['content'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Khu vực Admin trả lời
                    if (fb['reply'].toString().isNotEmpty)
                      // Đã trả lời -> Hiện đoạn chat
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.mail_outline,
                                  size: 14,
                                  color: Color(0xFF246BFD),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Admin đã phản hồi:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF246BFD),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              fb['reply'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1E3A8A),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Chưa trả lời -> Hiện ô nhập liệu
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextField(
                            controller: replyController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Viết câu trả lời để gửi qua Email...',
                              hintStyle: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF246BFD),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (replyController.text.isNotEmpty) {
                                // Cập nhật dữ liệu
                                setState(() {
                                  _feedbacks[index]['reply'] =
                                      replyController.text;
                                });
                                // Cập nhật luôn UI của BottomSheet hiện tại
                                setModalState(() {});
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF246BFD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(
                              Icons.send,
                              size: 14,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Gửi phản hồi',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
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
            onTap: () => _openFeedbackDetail(index), // Mở popup khi ấn
          );
        },
      ),
    );
  }
}
