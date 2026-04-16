// lib/features/profile/utils/data_helper.dart

class UserProfile {
  // ==================== THÔNG TIN CÁ NHÂN ====================
  static String userName = "Nguyễn Quốc Trường";
  static String email = "truong.nguyen@example.com";
  static int age = 28;
  static String gender = "Nam";
  static double height = 172.0; // cm
  static double weight = 68.5; // kg
  static double targetWeight = 65.0;

  // ==================== THÔNG TIN SỨC KHỎE ====================
  static String bloodType = "O+";
  static String allergies = "Không có";
  static int dailyWaterGoal = 2500; // ml
  static String exerciseGoal = "Tập gym 5 buổi/tuần";

  // ==================== HÀM CẬP NHẬT DỮ LIỆU ====================
  static void updateProfile({
    String? newName,
    String? newEmail,
    int? newAge,
    String? newGender,
    double? newHeight,
    double? newWeight,
    double? newTargetWeight,
    String? newBloodType,
    String? newAllergies,
    int? newWaterGoal,
    String? newExerciseGoal,
  }) {
    if (newName != null) userName = newName;
    if (newEmail != null) email = newEmail;
    if (newAge != null) age = newAge;
    if (newGender != null) gender = newGender;
    if (newHeight != null) height = newHeight;
    if (newWeight != null) weight = newWeight;
    if (newTargetWeight != null) targetWeight = newTargetWeight;
    if (newBloodType != null) bloodType = newBloodType;
    if (newAllergies != null) allergies = newAllergies;
    if (newWaterGoal != null) dailyWaterGoal = newWaterGoal;
    if (newExerciseGoal != null) exerciseGoal = newExerciseGoal;
  }

  // Reset về giá trị mặc định (nếu cần)
  static void resetToDefault() {
    userName = "Nguyễn Quốc Trường";
    email = "truong.nguyen@example.com";
    age = 28;
    gender = "Nam";
    height = 172.0;
    weight = 68.5;
    targetWeight = 65.0;
    bloodType = "O+";
    allergies = "Không có";
    dailyWaterGoal = 2500;
    exerciseGoal = "Tập gym 5 buổi/tuần";
  }

  // Getter tiện lợi (tùy chọn)
  static double get bmi => weight / ((height / 100) * (height / 100));
}
