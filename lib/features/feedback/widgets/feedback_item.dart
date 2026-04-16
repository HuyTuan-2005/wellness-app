import 'package:flutter/material.dart';

class FeedbackItem extends StatelessWidget {
  final String name;
  final String email;
  final String content;
  final String date;
  final bool isRead; // Trạng thái đã đọc hay chưa
  final VoidCallback onTap;

  const FeedbackItem({
    super.key,
    required this.name,
    required this.email,
    required this.content,
    required this.date,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // Nếu chưa đọc thì nền màu xanh nhạt, đọc rồi thì nền trắng
            color: isRead ? Colors.white : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead ? Colors.grey.shade200 : const Color(0xFFBFDBFE),
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      // Chưa đọc thì in đậm tên người gửi
                      fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                      fontSize: 14,
                      color: isRead
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 12,
                      color: isRead
                          ? Colors.grey.shade600
                          : const Color(0xFF1E293B),
                      fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
                    ),
                    maxLines: 2, // Chỉ hiện tối đa 2 dòng ngoài danh sách
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      date,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              // Dấu chấm xanh báo hiệu "Chưa đọc" nằm ở góc phải trên cùng
              if (!isRead)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF246BFD),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF246BFD).withOpacity(0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
