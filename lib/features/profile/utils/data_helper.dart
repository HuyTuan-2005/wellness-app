// lib/features/profile/utils/data_helper.dart

class UserProfile {
  // ==================== THÔNG TIN CÁ NHÂN ====================
  static String userName = "";
  static String email = "";
  static int age = 0;
  static String gender = "Nam";
  static double height = 0.0; // cm
  static double weight = 0.0; // kg
  static double targetWeight = 0.0;

  // ==================== THÔNG TIN SỨC KHỎE ====================
  static String bloodType = "Chưa rõ";
  static String allergies = "Không có";
  static int dailyWaterGoal = 2000; // ml
  static int dailyCaloGoal = 2000; // kcal
  static String exerciseGoal = "Chưa rõ";
  static double sleepGoalHours = 8.0;
  static int targetSystolic = 120;
  static int targetDiastolic = 80;

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
    double? newSleepGoalHours,
    int? newTargetSystolic,
    int? newTargetDiastolic,
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
    if (newSleepGoalHours != null) sleepGoalHours = newSleepGoalHours;
    if (newTargetSystolic != null) targetSystolic = newTargetSystolic;
    if (newTargetDiastolic != null) targetDiastolic = newTargetDiastolic;
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
    if (data['sleepGoalHours'] != null) sleepGoalHours = (data['sleepGoalHours'] as num).toDouble();
    if (data['targetSystolic'] != null) targetSystolic = data['targetSystolic'];
    if (data['targetDiastolic'] != null) targetDiastolic = data['targetDiastolic'];
  }

  // Reset về giá trị mặc định (nếu cần)
  static void resetToDefault() {
    userName = "";
    email = "";
    age = 0;
    gender = "Nam";
    height = 0.0;
    weight = 0.0;
    targetWeight = 0.0;
    bloodType = "Chưa rõ";
    allergies = "Không có";
    dailyWaterGoal = 2000;
    dailyCaloGoal = 2000;
    exerciseGoal = "Chưa rõ";
    sleepGoalHours = 8.0;
    targetSystolic = 120;
    targetDiastolic = 80;
  }

  // Getter tiện lợi (tùy chọn)
  static double get bmi => height > 0 ? (weight / ((height / 100) * (height / 100))) : 0.0;

  static int getSuggestedCaloriesFor({
    required double weight,
    required double height,
    required int age,
    required String gender,
  }) {
    double bmr;
    if (gender == "Nam") {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else if (gender == "Nữ") {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 78;
    }
    return (bmr * 1.375).round();
  }
}
