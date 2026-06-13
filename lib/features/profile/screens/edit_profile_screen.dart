import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'package:wellness_app/features/weight/models/weight_record.dart';
import '../../../core/theme/app_colors.dart';
import 'package:wellness_app/core/utils/app_helpers.dart';

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

  String? _selectedGender;
  String? _selectedBloodType;

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

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _targetWeightController = TextEditingController();
    _allergiesController = TextEditingController();
    _waterGoalController = TextEditingController();
    _exerciseGoalController = TextEditingController();

    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && mounted) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _nameController.text = data['displayName'] ?? '';
            _emailController.text = data['email'] ?? '';
            _ageController.text = data['age']?.toString() ?? '';
            _heightController.text = data['height']?.toString() ?? '';
            _weightController.text = data['weight']?.toString() ?? '';
            _targetWeightController.text =
                data['targetWeight']?.toString() ?? '';
            _allergiesController.text = data['allergies'] ?? '';
            _waterGoalController.text =
                data['dailyWaterGoal']?.toString() ?? '';
            _exerciseGoalController.text = data['exerciseGoal'] ?? '';

            _selectedGender = data['gender'] as String?;
            if (_selectedGender != null && !genders.contains(_selectedGender)) {
              _selectedGender = null;
            }

            _selectedBloodType = data['bloodType'] as String?;
            if (_selectedBloodType != null &&
                !bloodTypes.contains(_selectedBloodType)) {
              _selectedBloodType = null;
            }
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        debugPrint("Lỗi load profile: $e");
      }
    }

    // Nếu lỗi hoặc không có user, dùng tạm dữ liệu từ UserProfile
    if (mounted) {
      setState(() {
        _nameController.text = UserProfile.userName;
        _emailController.text = UserProfile.email;
        _ageController.text = UserProfile.age.toString();
        _heightController.text = UserProfile.height.toString();
        _weightController.text = UserProfile.weight.toString();
        _targetWeightController.text = UserProfile.targetWeight.toString();
        _allergiesController.text = UserProfile.allergies;
        _waterGoalController.text = UserProfile.dailyWaterGoal.toString();
        _exerciseGoalController.text = UserProfile.exerciseGoal;
        _selectedGender = null;
        _selectedBloodType = null;
        _isLoading = false;
      });
    }
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

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      double? newWeightVal = double.tryParse(_weightController.text);
      double? newHeightVal = double.tryParse(_heightController.text);
      int? newAgeVal = int.tryParse(_ageController.text);
      String newGenderVal = _selectedGender ?? UserProfile.gender;

      int? caloGoal;
      if (newWeightVal != null && newHeightVal != null && newAgeVal != null) {
        caloGoal = UserProfile.getSuggestedCaloriesFor(
          weight: newWeightVal,
          height: newHeightVal,
          age: newAgeVal,
          gender: newGenderVal,
        );
      }

      if (user != null) {
        try {
          AppHelpers.showLoading(context);

          // Nếu có thay đổi cân nặng -> Lưu bản ghi cân nặng mới vào SQLite & Firestore
          if (newWeightVal != null && newWeightVal != UserProfile.weight) {
            final record = WeightRecord(
              weight: newWeightVal,
              date: DateTime.now(),
            );
            final id = await DatabaseHelper.instance.insertWeightRecord(record);
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('weight_records')
                .doc(id.toString())
                .set(record.toMap()..['id'] = id)
                .catchError((e) => debugPrint("Error syncing profile weight update to Firestore: $e"));
          }

          final profileData = {
            'displayName': _nameController.text.trim(),
            'age': newAgeVal,
            'gender': newGenderVal,
            'height': newHeightVal,
            'weight': newWeightVal,
            'targetWeight': double.tryParse(_targetWeightController.text),
            'bloodType': _selectedBloodType,
            'allergies': _allergiesController.text.trim().isEmpty
                ? "Không có"
                : _allergiesController.text.trim(),
            'dailyWaterGoal': int.tryParse(_waterGoalController.text),
            'exerciseGoal': _exerciseGoalController.text.trim(),
            if (caloGoal != null) 'dailyCaloGoal': caloGoal,
          };

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(profileData, SetOptions(merge: true));

          UserProfile.updateProfileFromMap(profileData);

          if (mounted) {
            AppHelpers.hideLoading(context);
            AppHelpers.showSnackBar(context, 'Đã lưu thông tin thành công!');
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) {
            AppHelpers.hideLoading(context);
            AppHelpers.showSnackBar(
              context,
              'Lỗi khi lưu thông tin lên Firestore: $e',
            );
          }
        }
      } else {
        // Fallback lưu cục bộ nếu không có user (phát triển/test)
        if (newWeightVal != null && newWeightVal != UserProfile.weight) {
          final record = WeightRecord(
            weight: newWeightVal,
            date: DateTime.now(),
          );
          await DatabaseHelper.instance.insertWeightRecord(record);
        }

        UserProfile.updateProfile(
          newName: _nameController.text.trim(),
          newEmail: _emailController.text.trim(),
          newAge: newAgeVal,
          newGender: newGenderVal,
          newHeight: newHeightVal,
          newWeight: newWeightVal,
          newTargetWeight: double.tryParse(_targetWeightController.text),
          newBloodType: _selectedBloodType,
          newAllergies: _allergiesController.text.trim().isEmpty
              ? "Không có"
              : _allergiesController.text.trim(),
          newWaterGoal: int.tryParse(_waterGoalController.text),
          newCaloGoal: caloGoal,
          newExerciseGoal: _exerciseGoalController.text.trim(),
        );
        AppHelpers.showSnackBar(
          context,
          'Đã lưu thông tin thành công (cục bộ)!',
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  backgroundImage:
                      FirebaseAuth.instance.currentUser?.photoURL != null
                      ? NetworkImage(
                          FirebaseAuth.instance.currentUser!.photoURL!,
                        )
                      : null,
                  child: FirebaseAuth.instance.currentUser?.photoURL == null
                      ? const Icon(
                          Icons.person,
                          size: 65,
                          color: AppColors.primary,
                        )
                      : null,
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
                enabled: false,
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
                      readOnly: true,
                      isRequired: true,
                      onTap: () {
                        _showPicker(
                          'Tuổi',
                          List.generate(
                            100,
                            (index) => (index + 1).toString(),
                          ), // 1 - 100
                          _ageController.text.isNotEmpty
                              ? _ageController.text
                              : '20',
                          (val) => setState(() => _ageController.text = val),
                        );
                      },
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
                      readOnly: true,
                      isRequired: true,
                      onTap: () {
                        _showAdvancedPickerBottomsheet(
                          context: context,
                          title: 'Chọn Chiều Cao',
                          controller: _heightController,
                          isWeight: false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Cân nặng (kg)',
                      _weightController,
                      Icons.monitor_weight_outlined,
                      readOnly: true,
                      isRequired: true,
                      onTap: () {
                        _showAdvancedPickerBottomsheet(
                          context: context,
                          title: 'Chọn Cân Nặng',
                          controller: _weightController,
                          isWeight: true,
                        );
                      },
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
                readOnly: true,
                onTap: () {
                  _showAdvancedPickerBottomsheet(
                    context: context,
                    title: 'Chọn Mục Tiêu Cân Nặng',
                    controller: _targetWeightController,
                    isWeight: true,
                  );
                },
              ),
              const SizedBox(height: 20),

              _buildTextField(
                'Lượng nước mục tiêu (ml/ngày)',
                _waterGoalController,
                Icons.water_drop_outlined,
                readOnly: true,
                onTap: () {
                  _showPicker(
                    'Lượng nước (ml)',
                    List.generate(
                      41,
                      (index) => (1000 + index * 100).toString(),
                    ),
                    _waterGoalController.text.isNotEmpty
                        ? _waterGoalController.text
                        : '2000',
                    (val) => setState(() => _waterGoalController.text = val),
                  );
                },
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

  void _showPicker(
    String title,
    List<String> items,
    String initialValue,
    ValueChanged<String> onSelectedItemChanged,
  ) {
    int initialIndex = items.indexOf(initialValue);
    if (initialIndex < 0) initialIndex = 0;
    String selectedValue = items[initialIndex];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        onSelectedItemChanged(selectedValue);
                        Navigator.pop(context);
                      },
                      child: const Text('Xong'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(
                    initialItem: initialIndex,
                  ),
                  onSelectedItemChanged: (int index) {
                    selectedValue = items[index];
                  },
                  children: items.map((String item) {
                    return Center(child: Text(item));
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
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
                            color: Colors.grey.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Positioned.fill(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Integer Picker
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
                                // Decimal Picker
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

  // ==================== WIDGET HỖ TRỢ ====================
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    bool readOnly = false,
    bool isRequired = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
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
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Vui lòng nhập $label';
        }
        return null;
      },
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
