import 'package:flutter/material.dart';

// Light mode
class AppColors {
  // Màu chủ đạo (Primary) - Xanh lam đậm tạo sự tin cậy, công nghệ (Đặc trưng của Asklepios)
  static const Color primary = Color(0xFF0F67FE);

  // Màu phụ (Secondary) - Xanh nhạt dùng làm nền phụ, điểm nhấn mềm mại
  static const Color secondary = Color(0xFFE6F0FF);

  // Màu nhấn (Accent) - Xanh ngọc dùng cho các module sức khỏe
  static const Color teal = Color(0xFF009688);

  // Hệ thống màu nền (Background & Surface)
  static const Color background = Color(
    0xFFF4F6FA,
  ); // Màu nền của toàn bộ màn hình
  static const Color surface = Color(
    0xFFFFFFFF,
  ); // Màu nền của các thẻ (Card) nổi lên

  // Màu đường viền
  static const Color border = Color.fromARGB(
    255,
    238,
    238,
    238,
  ); // Đường viền nhẹ cho Card và Divider

  // Hệ thống màu chữ (Text)
  static const Color textPrimary = Color.fromARGB(
    255,
    5,
    98,
    173,
  ); // Chữ tiêu đề
  static const Color textSecondary = Color(0xFF6B7280); // Chữ chú thích
  static const Color textDark = Colors.black; // Chữ tiêu đề đậm, nội dung chính

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

// import 'package:flutter/material.dart';

// // Dark mode - Orange Theme
// class AppColors {
//   // Màu chủ đạo (Primary) - Màu cam nổi bật, năng động
//   static const Color primary = Color(0xFFFF6D00); // Cam rực rỡ (Deep Orange)

//   // Màu phụ (Secondary) - Cam nhạt / Nâu trầm dùng làm nền phụ hoặc hiệu ứng nhấn
//   static const Color secondary = Color(0xFF3E2723);

//   // Hệ thống màu nền (Background & Surface)
//   static const Color background = Color(
//     0xFF121212,
//   ); // Màu nền của toàn bộ màn hình (Đen nhạt)

//   static const Color surface = Color(
//     0xFF1E1E1E,
//   ); // Màu nền của các thẻ (Card) nổi lên

//   // Màu đường viền
//   static const Color border = Color(0xFF2C2C2C); // Đường viền mờ cho Dark Mode

//   // Hệ thống màu chữ (Text)
//   static const Color textPrimary = Color(0xFFE0E0E0); // Chữ tiêu đề (Trắng xám)
//   static const Color textSecondary = Color(0xFF9E9E9E); // Chữ chú thích
//   static const Color textDark = Color(
//     0xFFF5F5F5,
//   ); // Chữ chính, trước kia là đen nay đổi thành sáng

//   // Màu trạng thái (Semantic) - Giữ tone sáng để dễ nhìn trên nền tối
//   static const Color success = Color(0xFF00E676); // Đạt mục tiêu
//   static const Color warning = Color(0xFFFFCA28); // Nhắc nhở
//   static const Color error = Color(0xFFEF5350); // Cảnh báo
// }
