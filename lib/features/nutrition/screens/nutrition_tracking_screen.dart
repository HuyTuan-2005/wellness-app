import 'package:flutter/material.dart';
import '../controllers/nutrition_controller.dart';
import '../widgets/add_food_dialog.dart';
import '../widgets/calo_painter.dart';
import '../models/nutrition_entry.dart';
import 'package:wellness_app/core/utils/date_helper.dart';

class NutritionTrackingScreen extends StatefulWidget {
  const NutritionTrackingScreen({super.key});

  @override
  State<NutritionTrackingScreen> createState() => _NutritionTrackingScreenState();
}

class _NutritionTrackingScreenState extends State<NutritionTrackingScreen> {
  final NutritionController _controller = NutritionController();
  MealType _selectedMeal = MealType.sang;
  bool _isAddFoodDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _showGoalDialog() async {
    final suggested = _controller.getSuggestedCalories();
    final textController = TextEditingController(text: _controller.goalCalo.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Mục tiêu calo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nhập kcal mong muốn',
                  suffixText: 'kcal',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gợi ý từ tỉ lệ cơ thể: $suggested kcal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.green.shade800,
                            ),
                          ),
                          const Text(
                            '(Theo chiều cao, cân nặng, tuổi và giới tính của bạn)',
                            style: TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    textController.text = suggested.toString();
                  },
                  child: const Text('Sử dụng mức calo gợi ý'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                final value = int.tryParse(textController.text);
                if (value != null) {
                  Navigator.of(dialogContext).pop(value);
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    if (!mounted || result == null) return;
    _controller.updateGoal(result);
  }

  Future<void> _openAddFoodDialog() async {
    if (_isAddFoodDialogOpen) return;
    _isAddFoodDialogOpen = true;

    final result = await showDialog<AddFoodResult>(
      context: context,
      builder: (_) => AddFoodDialog(
        mealType: _selectedMeal,
        suggestFood: _controller.suggestFood,
      ),
    );

    _isAddFoodDialogOpen = false;
    if (!mounted || result == null) return;

    if (result.food != null) {
      _controller.addFromDatabase(
        food: result.food!,
        quantity: result.quantity,
        mealType: result.mealType,
      );
      return;
    }

    _controller.addEntry(
      foodName: result.foodName!,
      quantity: result.quantity,
      calo: result.calo!,
      protein: result.protein!,
      carb: result.carb!,
      mealType: result.mealType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F6EF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ghi nhận thức ăn',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateHelper.getDateString(),
                        style: TextStyle(fontSize: 14, color: Colors.green.shade300),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings_outlined, color: Color(0xFF1B5E20)),
                      onPressed: _showGoalDialog,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: CaloPainter(progress: _controller.progress),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department, size: 36, color: Colors.orange.shade700),
                            const SizedBox(height: 8),
                            Text(
                              _controller.totalCalo.round().toString(),
                              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                            ),
                            const Text('kcal', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tiến độ hôm nay', style: TextStyle(fontSize: 15, color: Colors.black87)),
                        Text(
                          '${_controller.totalCalo.round()} / ${_controller.goalCalo} kcal',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _controller.progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF66BB6A)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_controller.percent}% hoàn thành', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        Text(
                          'Còn ${_controller.remainingCalo.round()} kcal',
                          style: TextStyle(fontSize: 13, color: Colors.green.shade400, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: MealType.values.map((type) {
                  final isSelected = type == _selectedMeal;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMeal = type),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSelected ? null : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(type.icon, size: 24, color: isSelected ? Colors.white : Colors.grey.shade600),
                              const SizedBox(height: 4),
                              Text(
                                type.label,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openAddFoodDialog,
                  icon: const Icon(Icons.add),
                  label: Text('Thêm món ăn - Bữa ${_selectedMeal.label}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lịch sử hôm nay',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                    ),
                    const SizedBox(height: 12),
                    if (_controller.history.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text('Chưa có dữ liệu. Hãy ghi nhận bữa ăn!', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                        ),
                      )
                    else
                      ..._controller.history.asMap().entries.map(
                        (mapEntry) {
                          final index = mapEntry.key;
                          final entry = mapEntry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(entry.mealType.icon, color: Colors.green.shade400, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.foodName,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20)),
                                      ),
                                      Text(
                                        '${entry.quantity}g - ${entry.calo.round()} kcal',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  DateHelper.formatTime(entry.time),
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _controller.removeEntry(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

