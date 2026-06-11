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
  static int dailyCaloGoal = 2000; // kcal
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
    int? newCaloGoal,
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
    if (newCaloGoal != null) dailyCaloGoal = newCaloGoal;
    if (newExerciseGoal != null) exerciseGoal = newExerciseGoal;
  }

  static void updateProfileFromMap(Map<String, dynamic> data) {
    if (data['displayName'] != null) userName = data['displayName'];
    if (data['email'] != null) email = data['email'];
    if (data['age'] != null) age = data['age'];
    if (data['gender'] != null) gender = data['gender'];
    if (data['height'] != null) height = (data['height'] as num).toDouble();
    if (data['weight'] != null) weight = (data['weight'] as num).toDouble();
    if (data['targetWeight'] != null) targetWeight = (data['targetWeight'] as num).toDouble();
    if (data['bloodType'] != null) bloodType = data['bloodType'];
    if (data['allergies'] != null) allergies = data['allergies'];
    if (data['dailyWaterGoal'] != null) dailyWaterGoal = data['dailyWaterGoal'];
    if (data['dailyCaloGoal'] != null) dailyCaloGoal = data['dailyCaloGoal'];
    if (data['exerciseGoal'] != null) exerciseGoal = data['exerciseGoal'];
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
    dailyCaloGoal = 2000;
    exerciseGoal = "Tập gym 5 buổi/tuần";
  }

  // Getter tiện lợi (tùy chọn)
  static double get bmi => weight / ((height / 100) * (height / 100));
}
