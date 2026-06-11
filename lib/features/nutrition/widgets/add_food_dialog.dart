import 'package:flutter/material.dart';
import '../models/nutrition_entry.dart';
import '../controllers/nutrition_controller.dart';
import '../data/food_database.dart';

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

class _AddFoodDialogState extends State<AddFoodDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Manual Tab Controllers
  final _manualNameController = TextEditingController();
  final _manualQuantityController = TextEditingController(text: '100');
  final _manualCaloController = TextEditingController();
  final _manualProteinController = TextEditingController();
  final _manualCarbController = TextEditingController();

  // Library Tab Controllers & State
  final _librarySearchController = TextEditingController();
  final _libraryQuantityController = TextEditingController(text: '100');
  FoodItem? _selectedLibraryFood;
  List<FoodItem> _libraryFoods = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize library foods with empty query (which returns frequent foods first) or all foods if empty
    _updateLibraryFoods('');
    
    _librarySearchController.addListener(() {
      _updateLibraryFoods(_librarySearchController.text);
    });

    _libraryQuantityController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _updateLibraryFoods(String query) {
    setState(() {
      // suggestFood(query) returns frequent foods first, then database foods matching the query
      final results = widget.suggestFood(query);
      if (results.isEmpty && query.isEmpty) {
        // If there are no frequent foods yet, fall back to the entire database list
        _libraryFoods = FoodDatabase.foods;
      } else {
        _libraryFoods = results;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _manualNameController.dispose();
    _manualQuantityController.dispose();
    _manualCaloController.dispose();
    _manualProteinController.dispose();
    _manualCarbController.dispose();
    _librarySearchController.dispose();
    _libraryQuantityController.dispose();
    super.dispose();
  }

  void _submitLibrary() {
    if (_selectedLibraryFood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn một món ăn từ danh sách.')),
      );
      return;
    }
    final quantity = int.tryParse(_libraryQuantityController.text.trim()) ?? 0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số lượng hợp lệ (lớn hơn 0).')),
      );
      return;
    }

    Navigator.of(context).pop(
      AddFoodResult.fromDatabase(
        food: _selectedLibraryFood!,
        quantity: quantity,
        mealType: widget.mealType,
      ),
    );
  }

  void _submitManual() {
    final foodName = _manualNameController.text.trim();
    if (foodName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên món ăn.')),
      );
      return;
    }

    final quantity = int.tryParse(_manualQuantityController.text.trim()) ?? 0;
    final calo = double.tryParse(_manualCaloController.text.trim()) ?? 0.0;
    final protein = double.tryParse(_manualProteinController.text.trim()) ?? 0.0;
    final carb = double.tryParse(_manualCarbController.text.trim()) ?? 0.0;

    if (quantity <= 0 || calo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ số lượng và calo/100g.')),
      );
      return;
    }

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

  Widget _buildLibraryTab() {
    final quantity = int.tryParse(_libraryQuantityController.text.trim()) ?? 100;
    final double factor = quantity / 100.0;

    return Column(
      children: [
        // Library Search Field
        TextField(
          controller: _librarySearchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm món ăn trong thư viện...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF1B5E20)),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        const SizedBox(height: 10),
        // Scrollable List of Foods
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _libraryFoods.isEmpty
                ? Center(
                    child: Text(
                      'Không tìm thấy món ăn nào.',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.builder(
                    itemCount: _libraryFoods.length,
                    itemBuilder: (context, index) {
                      final food = _libraryFoods[index];
                      final isSelected = _selectedLibraryFood == food;
                      final isFrequent = NutritionController().isFrequent(food.name);

                      return ListTile(
                        dense: true,
                        selected: isSelected,
                        selectedColor: const Color(0xFF1B5E20),
                        selectedTileColor: const Color(0xFFE8F5E9),
                        title: Row(
                          children: [
                            Text(
                              food.name,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (isFrequent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, size: 10, color: Colors.amber.shade800),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Hay dùng',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text('${food.caloPer100g} kcal/100g'),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Color(0xFF1B5E20))
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedLibraryFood = food;
                          });
                        },
                      );
                    },
                  ),
          ),
        ),
        const SizedBox(height: 12),
        // Quantity input & calculated nutrition preview
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 4,
              child: TextField(
                controller: _libraryQuantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số lượng (g)',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ước tính dinh dưỡng:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedLibraryFood == null
                          ? 'Calo: -- kcal'
                          : 'Calo: ${(_selectedLibraryFood!.caloPer100g * factor).toStringAsFixed(1)} kcal',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20)),
                    ),
                    Text(
                      _selectedLibraryFood == null
                          ? 'Đạm: --g | Carb: --g'
                          : 'Đạm: ${(_selectedLibraryFood!.proteinPer100g * factor).toStringAsFixed(1)}g | Carb: ${(_selectedLibraryFood!.carbPer100g * factor).toStringAsFixed(1)}g',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManualTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: _manualNameController,
            decoration: const InputDecoration(
              labelText: 'Tên món ăn',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _manualQuantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Số lượng (g)',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _manualCaloController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Calo/100g',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _manualProteinController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Protein/100g',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _manualCarbController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Carb/100g',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thêm món - Bữa ${widget.mealType.label}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
              ),
              const SizedBox(height: 8),
              // TabBar definition
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF1B5E20),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF1B5E20),
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Thư viện món', icon: Icon(Icons.menu_book, size: 20)),
                  Tab(text: 'Tự nhập tay', icon: Icon(Icons.edit_note, size: 20)),
                ],
              ),
              const SizedBox(height: 16),
              // TabBarView Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLibraryTab(),
                    _buildManualTab(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Bottom Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      if (_tabController.index == 0) {
                        _submitLibrary();
                      } else {
                        _submitManual();
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                    ),
                    child: const Text('Thêm'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
