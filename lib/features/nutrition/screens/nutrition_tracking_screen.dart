import 'dart:math';
import 'package:flutter/material.dart';
import '../controllers/nutrition_controller.dart';
import '../models/nutrition_entry.dart';
import '../../utils/date_helper.dart';

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
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _showGoalDialog() async {
    final textController = TextEditingController(text: _controller.goalCalo.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Mục tiêu calo'),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Nhập kcal mong muốn',
              suffixText: 'kcal',
            ),
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

    final result = await showDialog<_AddFoodResult>(
      context: context,
      builder: (_) => _AddFoodDialog(
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
                      painter: _CaloPainter(progress: _controller.progress),
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

class _AddFoodDialog extends StatefulWidget {
  final MealType mealType;
  final List<FoodItem> Function(String query) suggestFood;

  const _AddFoodDialog({
    required this.mealType,
    required this.suggestFood,
  });

  @override
  State<_AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<_AddFoodDialog> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '100');
  final _caloController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbController = TextEditingController();

  FoodItem? _selectedFood;
  List<FoodItem> _suggestions = [];
  bool _isSelectingSuggestion = false;

  @override
  void initState() {
    super.initState();
    _suggestions = widget.suggestFood('');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _caloController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    super.dispose();
  }

  void _onNameChanged(String value) {
    if (_isSelectingSuggestion) return;
    setState(() {
      _suggestions = widget.suggestFood(value);
      _selectedFood = null;
      for (final food in _suggestions) {
        if (food.name.toLowerCase() == value.toLowerCase()) {
          _selectedFood = food;
          break;
        }
      }
    });
  }

  void _selectSuggestion(FoodItem food) {
    _isSelectingSuggestion = true;
    _nameController.text = food.name;
    _nameController.selection = TextSelection.collapsed(offset: _nameController.text.length);
    setState(() {
      _selectedFood = food;
      _suggestions = [];
    });
    _isSelectingSuggestion = false;
  }

  void _submit() {
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    if (quantity <= 0) return;

    if (_selectedFood != null) {
      Navigator.of(context).pop(
        _AddFoodResult.fromDatabase(
          food: _selectedFood!,
          quantity: quantity,
          mealType: widget.mealType,
        ),
      );
      return;
    }

    final foodName = _nameController.text.trim();
    if (foodName.isEmpty) return;

    final calo = double.tryParse(_caloController.text.trim()) ?? 0;
    final protein = double.tryParse(_proteinController.text.trim()) ?? 0;
    final carb = double.tryParse(_carbController.text.trim()) ?? 0;
    if (calo <= 0) return;

    Navigator.of(context).pop(
      _AddFoodResult.manual(
        foodName: foodName,
        quantity: quantity,
        calo: calo * quantity / 100,
        protein: protein * quantity / 100,
        carb: carb * quantity / 100,
        mealType: widget.mealType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thêm món - Bữa ${widget.mealType.label}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _nameController,
                        onChanged: _onNameChanged,
                        decoration: const InputDecoration(labelText: 'Tên món ăn'),
                      ),
                      const SizedBox(height: 8),
                      if (_suggestions.isNotEmpty && _nameController.text.isNotEmpty)
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            itemCount: _suggestions.length,
                            itemBuilder: (context, index) {
                              final food = _suggestions[index];
                              return ListTile(
                                dense: true,
                                title: Text(food.name),
                                subtitle: Text('${food.caloPer100g} kcal/100g'),
                                onTap: () => _selectSuggestion(food),
                              );
                            },
                          ),
                        ),
                      TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Số lượng (g)'),
                      ),
                      if (_selectedFood == null) ...[
                        TextField(
                          controller: _caloController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Calo/100g'),
                        ),
                        TextField(
                          controller: _proteinController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Protein/100g'),
                        ),
                        TextField(
                          controller: _carbController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Carb/100g'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _submit, child: const Text('Thêm')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaloPainter extends CustomPainter {
  final double progress;

  _CaloPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: const [Color(0xFF66BB6A), Color(0xFFFFA726), Color(0xFF66BB6A)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CaloPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _AddFoodResult {
  final FoodItem? food;
  final String? foodName;
  final int quantity;
  final double? calo;
  final double? protein;
  final double? carb;
  final MealType mealType;

  const _AddFoodResult._({
    required this.food,
    required this.foodName,
    required this.quantity,
    required this.calo,
    required this.protein,
    required this.carb,
    required this.mealType,
  });

  factory _AddFoodResult.fromDatabase({
    required FoodItem food,
    required int quantity,
    required MealType mealType,
  }) {
    return _AddFoodResult._(
      food: food,
      foodName: null,
      quantity: quantity,
      calo: null,
      protein: null,
      carb: null,
      mealType: mealType,
    );
  }

  factory _AddFoodResult.manual({
    required String foodName,
    required int quantity,
    required double calo,
    required double protein,
    required double carb,
    required MealType mealType,
  }) {
    return _AddFoodResult._(
      food: null,
      foodName: foodName,
      quantity: quantity,
      calo: calo,
      protein: protein,
      carb: carb,
      mealType: mealType,
    );
  }
}
