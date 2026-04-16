import '../models/nutrition_entry.dart';

class FoodDatabase {
  static const List<FoodItem> foods = [
    FoodItem(name: 'Cơm trắng', caloPer100g: 130, proteinPer100g: 2.7, carbPer100g: 28),
    FoodItem(name: 'Phở bò', caloPer100g: 110, proteinPer100g: 8, carbPer100g: 16),
    FoodItem(name: 'Bún chả', caloPer100g: 150, proteinPer100g: 10, carbPer100g: 18),
    FoodItem(name: 'Bánh mì', caloPer100g: 265, proteinPer100g: 9, carbPer100g: 49),
    FoodItem(name: 'Trứng gà', caloPer100g: 155, proteinPer100g: 13, carbPer100g: 1.1),
    FoodItem(name: 'Thịt gà', caloPer100g: 239, proteinPer100g: 27, carbPer100g: 0),
    FoodItem(name: 'Thịt heo', caloPer100g: 242, proteinPer100g: 27, carbPer100g: 0),
    FoodItem(name: 'Thịt bò', caloPer100g: 250, proteinPer100g: 26, carbPer100g: 0),
    FoodItem(name: 'Cá hồi', caloPer100g: 208, proteinPer100g: 20, carbPer100g: 0),
    FoodItem(name: 'Tôm', caloPer100g: 99, proteinPer100g: 24, carbPer100g: 0.2),
    FoodItem(name: 'Đậu hũ', caloPer100g: 76, proteinPer100g: 8, carbPer100g: 1.9),
    FoodItem(name: 'Rau cải', caloPer100g: 25, proteinPer100g: 2.6, carbPer100g: 3.6),
    FoodItem(name: 'Khoai lang', caloPer100g: 86, proteinPer100g: 1.6, carbPer100g: 20),
    FoodItem(name: 'Chuối', caloPer100g: 89, proteinPer100g: 1.1, carbPer100g: 23),
    FoodItem(name: 'Táo', caloPer100g: 52, proteinPer100g: 0.3, carbPer100g: 14),
    FoodItem(name: 'Sữa tươi', caloPer100g: 42, proteinPer100g: 3.4, carbPer100g: 5),
  ];

  static FoodItem? search(String name) {
    final lower = name.toLowerCase();
    try {
      return foods.firstWhere((f) => f.name.toLowerCase() == lower);
    } catch (_) {
      return null;
    }
  }

  static List<FoodItem> suggest(String query) {
    if (query.isEmpty) return foods;
    final lower = query.toLowerCase();
    return foods.where((f) => f.name.toLowerCase().contains(lower)).toList();
  }
}
