# GIỚI THIỆU DỰ ÁN (PROJECT OVERVIEW)
- Tên dự án: Wellness App
- Nền tảng: Flutter (iOS, Android)
- Dịch vụ Backend: Firebase (Authentication, Firestore, Storage)
- Mục tiêu: Ứng dụng chăm sóc và theo dõi sức khỏe tổng hợp (Huyết áp, Giấc ngủ, Thuốc, Lịch hẹn, Quản trị viên).

# KIẾN TRÚC THƯ MỤC (ARCHITECTURE)
Dự án áp dụng cấu trúc Feature-First (chia theo tính năng). Mọi code mới phải tuân thủ nghiêm ngặt cấu trúc này:
- `lib/core/`: Chứa các cấu hình toàn cục (Theme, Colors, Constants, Enums).
- `lib/data/`: Chứa các Models dùng chung.
- `lib/features/`: Chứa các module tính năng độc lập (vd: `home`, `admin_dashboard`, `user_management`, `blood_pressure`...).
  - Trong mỗi feature sẽ chia thành: `/screens`, `/widgets`, `/controllers`, `/models`.

# QUY TẮC VIẾT CODE (CODING STANDARDS)
1. Clean Code & Tái sử dụng: 
   - Không viết các file UI quá dài (quá 300 dòng). 
   - Tách các thành phần UI nhỏ thành các file riêng trong thư mục `widgets/` của feature đó.
2. Quản lý Trạng thái & Điều hướng:
   - Ưu tiên sử dụng cách quản lý trạng thái hiện tại của dự án.
   - Khi chuyển đổi qua lại giữa các tab chính, sử dụng `IndexedStack` và `BottomNavigationBar` để giữ state.
   - Navigation: Sử dụng `Navigator.push` và `Navigator.pop` đúng luồng.
3. UI/UX & Thiết kế:
   - TUYỆT ĐỐI KHÔNG hardcode mã màu (hex code) hoặc TextStyles trong các file UI.
   - BẮT BUỘC gọi màu sắc từ `lib/core/theme/app_colors.dart` và font chữ từ `lib/core/theme/app_theme.dart`.
   - Giao diện phải theo phong cách Modern, Clean, padding/margin rộng rãi, thoáng mắt. Sử dụng bóng đổ (box-shadow) và bo góc mềm mại cho các thẻ (Cards).
4. Xử lý Dữ liệu:
   - Khi tạo UI mới cho danh sách (`ListView`, `GridView`), luôn luôn tạo dữ liệu giả tĩnh (Mock Data) để kiểm tra giao diện và trải nghiệm cuộn (scroll) trước khi liên kết với Firebase.

# QUY TẮC FIREBASE
- Phải có khối `try-catch` để bắt lỗi (FirebaseAuthException, FirebaseException) và hiển thị thông báo bằng `ScaffoldMessenger` (SnackBar) thân thiện cho người dùng.
- Hiển thị `CircularProgressIndicator` (Trạng thái loading) mỗi khi gọi API hoặc tương tác với Firebase.

# THÔNG TẦN SUẤT & ĐẦU RA (OUTPUT RULES)
- Luôn cung cấp mã nguồn Flutter hoàn chỉnh, không cắt bớt các phần quan trọng.
- Trình bày code rõ ràng, thêm comment (bằng tiếng Việt) giải thích ở các hàm logic quan trọng.