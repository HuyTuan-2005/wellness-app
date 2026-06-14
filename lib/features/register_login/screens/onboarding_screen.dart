import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'package:wellness_app/features/health/weight/models/weight_record.dart';
import 'package:wellness_app/core/utils/app_helpers.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  String _selectedGender = "Nam";
  final List<String> genders = ["Nam", "Nữ", "Khác"];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      final user = FirebaseAuth.instance.currentUser;
      double newWeight = double.parse(_weightController.text);
      double newHeight = double.parse(_heightController.text);
      int newAge = int.parse(_ageController.text);

      int caloGoal = UserProfile.getSuggestedCaloriesFor(
        weight: newWeight,
        height: newHeight,
        age: newAge,
        gender: _selectedGender,
      );

      if (user != null) {
        try {
          // Lưu vào SQLite
          final record = WeightRecord(
            weight: newWeight,
            date: DateTime.now(),
          );
          final id = await DatabaseHelper.instance.insertWeightRecord(record);
          
          // Ghi đè weight lên Firebase
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('weight_records')
              .doc(id.toString())
              .set(record.toMap()..['id'] = id);

          // Cập nhật User Profile
          final profileData = {
            'age': newAge,
            'gender': _selectedGender,
            'height': newHeight,
            'weight': newWeight,
            'targetWeight': newWeight, // Tạm thời bằng cân nặng hiện tại
            'dailyCaloGoal': caloGoal,
          };

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(profileData, SetOptions(merge: true));

          // Firebase Stream trong AuthWrapper sẽ tự động nhận diện và chuyển trang
        } catch (e) {
          if (mounted) {
            AppHelpers.showSnackBar(context, 'Lỗi lưu dữ liệu: $e');
            setState(() => _isSaving = false);
          }
        }
      } else {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showAdvancedPickerBottomsheet({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    required bool isWeight,
  }) {
    double currentVal = double.tryParse(controller.text) ?? (isWeight ? 65.0 : 170.0);

    int selectedInteger = currentVal.truncate();
    int selectedDecimal = ((currentVal - selectedInteger) * 10).round();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext builderContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 300,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy', style: TextStyle(color: Colors.red, fontSize: 16)),
                      ),
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      TextButton(
                        onPressed: () {
                          double newVal = isWeight 
                              ? selectedInteger + (selectedDecimal / 10.0)
                              : selectedInteger.toDouble();
                          
                          setState(() {
                            controller.text = isWeight ? newVal.toString() : newVal.toInt().toString();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Xác nhận', style: TextStyle(color: AppColors.primary, fontSize: 16)),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Positioned.fill(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(
                                      initialItem: isWeight ? (selectedInteger - 10) : (selectedInteger - 50)),
                                  itemExtent: 40,
                                  onSelectedItemChanged: (index) {
                                    setModalState(() {
                                      selectedInteger = isWeight ? (index + 10) : (index + 50);
                                    });
                                  },
                                  children: List.generate(isWeight ? 291 : 201, (index) {
                                    int val = isWeight ? (index + 10) : (index + 50);
                                    return Center(
                                      child: Text(
                                        '$val',
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              if (isWeight) ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(',', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: CupertinoPicker(
                                    scrollController: FixedExtentScrollController(initialItem: selectedDecimal),
                                    itemExtent: 40,
                                    onSelectedItemChanged: (index) {
                                      setModalState(() {
                                        selectedDecimal = index;
                                      });
                                    },
                                    children: List.generate(10, (index) {
                                      return Center(
                                        child: Text(
                                          '$index',
                                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 10),
                              Text(
                                isWeight ? 'kg' : 'cm',
                                style: const TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAgePicker() {
    int selectedAge = int.tryParse(_ageController.text) ?? 20;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.red))),
                    const Text('Chọn Tuổi', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        setState(() => _ageController.text = selectedAge.toString());
                        Navigator.pop(context);
                      },
                      child: const Text('Xong', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(initialItem: selectedAge - 1),
                  onSelectedItemChanged: (int index) {
                    selectedAge = index + 1;
                  },
                  children: List.generate(100, (index) => Center(child: Text('${index + 1}'))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập $label';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Center(
                  child: Icon(Icons.health_and_safety, size: 80, color: AppColors.primary),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Chào mừng bạn đến với Wellness!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Để ứng dụng có thể đưa ra các gợi ý chính xác nhất cho sức khỏe của bạn, vui lòng cung cấp một số thông tin cơ bản.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),

                // Gender
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Giới tính',
                    prefixIcon: const Icon(Icons.wc, color: AppColors.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.secondary),
                    ),
                  ),
                  items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (val) => setState(() => _selectedGender = val!),
                ),
                const SizedBox(height: 20),

                // Age
                _buildTextField(
                  'Tuổi',
                  _ageController,
                  Icons.cake_outlined,
                  readOnly: true,
                  onTap: _showAgePicker,
                ),
                const SizedBox(height: 20),

                // Height & Weight
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Chiều cao (cm)',
                        _heightController,
                        Icons.height,
                        readOnly: true,
                        onTap: () => _showAdvancedPickerBottomsheet(
                          context: context,
                          title: 'Chọn Chiều Cao',
                          controller: _heightController,
                          isWeight: false,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        'Cân nặng (kg)',
                        _weightController,
                        Icons.monitor_weight_outlined,
                        readOnly: true,
                        onTap: () => _showAdvancedPickerBottomsheet(
                          context: context,
                          title: 'Chọn Cân Nặng',
                          controller: _weightController,
                          isWeight: true,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),
                
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Bắt đầu sử dụng',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
