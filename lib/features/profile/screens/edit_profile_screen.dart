import 'package:flutter/material.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';
import '../../../core/theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _targetWeightController;
  late TextEditingController _allergiesController;
  late TextEditingController _waterGoalController;
  late TextEditingController _exerciseGoalController;

  String _selectedGender = "Nam";
  String _selectedBloodType = "O+";

  final List<String> genders = ["Nam", "Nữ", "Khác"];
  final List<String> bloodTypes = [
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-",
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: UserProfile.userName);
    _emailController = TextEditingController(text: UserProfile.email);
    _ageController = TextEditingController(text: UserProfile.age.toString());
    _heightController = TextEditingController(
      text: UserProfile.height.toString(),
    );
    _weightController = TextEditingController(
      text: UserProfile.weight.toString(),
    );
    _targetWeightController = TextEditingController(
      text: UserProfile.targetWeight.toString(),
    );
    _allergiesController = TextEditingController(text: UserProfile.allergies);
    _waterGoalController = TextEditingController(
      text: UserProfile.dailyWaterGoal.toString(),
    );
    _exerciseGoalController = TextEditingController(
      text: UserProfile.exerciseGoal,
    );

    _selectedGender = UserProfile.gender;
    _selectedBloodType = UserProfile.bloodType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _allergiesController.dispose();
    _waterGoalController.dispose();
    _exerciseGoalController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      UserProfile.updateProfile(
        newName: _nameController.text.trim(),
        newEmail: _emailController.text.trim(),
        newAge: int.tryParse(_ageController.text),
        newGender: _selectedGender,
        newHeight: double.tryParse(_heightController.text),
        newWeight: double.tryParse(_weightController.text),
        newTargetWeight: double.tryParse(_targetWeightController.text),
        newBloodType: _selectedBloodType,
        newAllergies: _allergiesController.text.trim().isEmpty
            ? "Không có"
            : _allergiesController.text.trim(),
        newWaterGoal: int.tryParse(_waterGoalController.text),
        newExerciseGoal: _exerciseGoalController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Đã lưu thông tin thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      child: const Icon(
                        Icons.person,
                        size: 65,
                        color: AppColors.primary,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _buildTextField(
                'Họ và tên',
                _nameController,
                Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Email',
                _emailController,
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildGenderDropdown()),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Tuổi',
                      _ageController,
                      Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Chiều cao (cm)',
                      _heightController,
                      Icons.height,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Cân nặng (kg)',
                      _weightController,
                      Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _buildBloodTypeDropdown(),
              const SizedBox(height: 20),

              _buildTextField(
                'Mục tiêu cân nặng (kg)',
                _targetWeightController,
                Icons.flag_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                'Lượng nước mục tiêu (ml/ngày)',
                _waterGoalController,
                Icons.water_drop_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                'Dị ứng',
                _allergiesController,
                Icons.warning_amber_outlined,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                'Mục tiêu vận động',
                _exerciseGoalController,
                Icons.fitness_center_outlined,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lưu thay đổi',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== WIDGET HỖ TRỢ ====================
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.secondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Vui lòng nhập $label' : null,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Giới tính',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.secondary),
        ),
      ),
      items: genders
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
      onChanged: (val) => setState(() => _selectedGender = val!),
    );
  }

  Widget _buildBloodTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBloodType,
      decoration: InputDecoration(
        labelText: 'Nhóm máu',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.secondary),
        ),
      ),
      items: bloodTypes
          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
          .toList(),
      onChanged: (val) => setState(() => _selectedBloodType = val!),
    );
  }
}
