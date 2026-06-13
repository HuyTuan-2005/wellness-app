import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'package:wellness_app/features/health/weight/models/weight_record.dart';
import 'package:wellness_app/core/theme/app_colors.dart';

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({super.key});

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  double? _bmi;
  String _bmiCategory = "";
  Color _bmiColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _heightController.text = UserProfile.height.toString();
    _weightController.text = UserProfile.weight.toString();
    if (UserProfile.height > 0 && UserProfile.weight > 0) {
      _calculateBMI(silent: true);
    }
  }

  void _calculateBMI({bool silent = false}) {
    // If silent is true, we skip form validation check because controllers are pre-populated.
    if (silent || (_formKey.currentState != null && _formKey.currentState!.validate())) {
      double? parsedHeight = double.tryParse(_heightController.text);
      double? parsedWeight = double.tryParse(_weightController.text);
      if (parsedHeight == null || parsedWeight == null || parsedHeight == 0) return;
      
      double heightInMeters = parsedHeight / 100; // cm -> m

      setState(() {
        _bmi = parsedWeight / (heightInMeters * heightInMeters);

        if (_bmi! < 18.5) {
          _bmiCategory = "Thiếu cân";
          _bmiColor = Colors.blue;
        } else if (_bmi! < 23.0) {
          _bmiCategory = "Bình thường";
          _bmiColor = Colors.green;
        } else if (_bmi! < 25.0) {
          _bmiCategory = "Thừa cân";
          _bmiColor = Colors.orange;
        } else {
          _bmiCategory = "Béo phì";
          _bmiColor = Colors.red;
        }
      });

      // Update static profile only if calculated by user interaction (not silent init)
      if (!silent) {
        UserProfile.height = parsedHeight;
        UserProfile.weight = parsedWeight;

        // Recalculate daily calorie goal
        final int caloGoal = UserProfile.getSuggestedCaloriesFor(
          weight: parsedWeight,
          height: parsedHeight,
          age: UserProfile.age,
          gender: UserProfile.gender,
        );
        UserProfile.dailyCaloGoal = caloGoal;

        // Sync weight to local DB & Firestore
        final record = WeightRecord(
          weight: parsedWeight,
          date: DateTime.now(),
        );

        DatabaseHelper.instance.insertWeightRecord(record).then((id) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            // Sync new weight record to Firestore weight_records collection
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('weight_records')
                .doc(id.toString())
                .set(record.toMap()..['id'] = id);
          }
        }).catchError((e) {
          debugPrint("Error saving weight log: $e");
        });

        // Sync user profile stats to Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'height': parsedHeight,
            'weight': parsedWeight,
            'dailyCaloGoal': caloGoal,
          }).catchError((e) {
            debugPrint("Error syncing BMI metrics to Firestore: $e");
          });
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lưu kết quả BMI thành công!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tính BMI'),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chỉ số khối cơ thể (BMI)',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'giúp bạn đánh giá tình trạng sức khỏe',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),

              // Input Chiều cao
              _buildPickerField(
                label: 'Chiều cao',
                value: '${_heightController.text} cm',
                icon: Icons.height,
                onTap: () => _showPickerBottomsheet(context, false),
              ),
              const SizedBox(height: 20),

              // Input Cân nặng
              _buildPickerField(
                label: 'Cân nặng',
                value: '${_weightController.text} kg',
                icon: Icons.monitor_weight_outlined,
                onTap: () => _showPickerBottomsheet(context, true),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _calculateBMI,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lưu kết quả BMI',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Kết quả
              if (_bmi != null) ...[
                Center(
                  child: Column(
                    children: [
                      Text(
                        _bmi!.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: _bmiColor,
                        ),
                      ),
                      Text(
                        _bmiCategory,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: _bmiColor,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Thanh màu phân loại
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [
                              Colors.blue,
                              Colors.green,
                              Colors.orange,
                              Colors.red,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Thiếu cân', style: TextStyle(fontSize: 12)),
                          Text('Bình thường', style: TextStyle(fontSize: 12)),
                          Text('Thừa cân', style: TextStyle(fontSize: 12)),
                          Text('Béo phì', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Bảng phân loại BMI
              _buildSectionTitle('Bảng phân loại BMI'),
              const SizedBox(height: 12),
              _buildBMICard('Dưới 18.5', 'Thiếu cân', Colors.blue),
              _buildBMICard('18.5 - 22.9', 'Bình thường', Colors.green),
              _buildBMICard('23.0 - 24.9', 'Thừa cân', Colors.orange),
              _buildBMICard('Từ 25.0 trở lên', 'Béo phì', Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.secondary),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showPickerBottomsheet(BuildContext context, bool isWeight) {
    double currentVal = isWeight 
        ? (double.tryParse(_weightController.text) ?? UserProfile.weight)
        : (double.tryParse(_heightController.text) ?? UserProfile.height);

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
                        isWeight ? 'Chọn Cân Nặng' : 'Chọn Chiều Cao',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      TextButton(
                        onPressed: () {
                          double newVal = isWeight 
                              ? selectedInteger + (selectedDecimal / 10.0)
                              : selectedInteger.toDouble();
                          
                          setState(() {
                            if (isWeight) {
                              _weightController.text = newVal.toString();
                            } else {
                              _heightController.text = newVal.toInt().toString();
                            }
                          });
                          Navigator.pop(context);
                          _calculateBMI(silent: true); // Auto update visual UI but don't save to DB yet
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
                                      initialItem: isWeight ? (selectedInteger - 30) : (selectedInteger - 100)),
                                  itemExtent: 40,
                                  onSelectedItemChanged: (index) {
                                    setModalState(() {
                                      selectedInteger = isWeight ? (index + 30) : (index + 100);
                                    });
                                  },
                                  children: List.generate(isWeight ? 171 : 151, (index) {
                                    int val = isWeight ? (index + 30) : (index + 100);
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildBMICard(String range, String status, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.surface,
      child: ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.circle, size: 12, color: color),
        ),
        title: Text(range),
        trailing: Text(
          status,
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
