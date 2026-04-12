import 'package:flutter/material.dart';

// Light mode
class AppColors {
  // Màu chủ đạo (Primary) - Xanh lam đậm tạo sự tin cậy, công nghệ (Đặc trưng của Asklepios)
  static const Color primary = Color(0xFF0F67FE);

  // Màu phụ (Secondary) - Xanh nhạt dùng làm nền phụ, điểm nhấn mềm mại
  static const Color secondary = Color(0xFFE6F0FF);

  // Hệ thống màu nền (Background & Surface)
  static const Color background = Color(
    0xFFF4F6FA,
  ); // Màu nền của toàn bộ màn hình
  static const Color surface = Color(
    0xFFFFFFFF,
  ); // Màu nền của các thẻ (Card) nổi lên

  // Hệ thống màu chữ (Text)
  static const Color textPrimary = Color(0xFF111827); // Chữ tiêu đề
  static const Color textSecondary = Color(0xFF6B7280); // Chữ chú thích

  // Màu trạng thái (Semantic) - Cực kỳ quan trọng cho app sức khỏe
  static const Color success = Color(
    0xFF00D27B,
  ); // Đạt mục tiêu (uống đủ nước, đi đủ bước)
  static const Color warning = Color(
    0xFFFFC107,
  ); // Nhắc nhở (tới giờ uống thuốc)
  static const Color error = Color(
    0xFFF44336,
  ); // Cảnh báo chỉ số nguy hiểm (nhịp tim cao)
}
