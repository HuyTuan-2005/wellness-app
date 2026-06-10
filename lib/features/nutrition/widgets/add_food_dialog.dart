import 'package:flutter/material.dart';
import '../data/food_database.dart';
import '../models/nutrition_entry.dart';

class AddFoodResult {
  final FoodItem? food;
  final String? foodName;
  final int quantity;
  final double? calo;
  final double? protein;
  final double? carb;
  final MealType mealType;

  const AddFoodResult._({
    required this.food,
    required this.foodName,
    required this.quantity,
    required this.calo,
    required this.protein,
    required this.carb,
    required this.mealType,
  });

  factory AddFoodResult.fromDatabase({
    required FoodItem food,
    required int quantity,
    required MealType mealType,
  }) {
    return AddFoodResult._(
      food: food,
      foodName: null,
      quantity: quantity,
      calo: null,
      protein: null,
      carb: null,
      mealType: mealType,
    );
  }

  factory AddFoodResult.manual({
    required String foodName,
    required int quantity,
    required double calo,
    required double protein,
    required double carb,
    required MealType mealType,
  }) {
    return AddFoodResult._(
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

class AddFoodDialog extends StatefulWidget {
  final MealType mealType;
  final List<FoodItem> Function(String query) suggestFood;

  const AddFoodDialog({
    super.key,
    required this.mealType,
    required this.suggestFood,
  });

  @override
  State<AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
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
        AddFoodResult.fromDatabase(
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
      AddFoodResult.manual(
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
