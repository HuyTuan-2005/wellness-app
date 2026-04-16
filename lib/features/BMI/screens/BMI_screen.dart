import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

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

  void _calculateBMI() {
    if (_formKey.currentState!.validate()) {
      double heightCm = double.parse(_heightController.text);
      double weight = double.parse(_weightController.text);
      double heightM = heightCm / 100;

      setState(() {
        _bmi = weight / (heightM * heightM);

        if (_bmi! < 18.5) {
          _bmiCategory = "Thiếu cân";
          _bmiColor = Colors.orange;
        } else if (_bmi! < 25) {
          _bmiCategory = "Bình thường";
          _bmiColor = Colors.green;
        } else if (_bmi! < 30) {
          _bmiCategory = "Thừa cân";
          _bmiColor = Colors.orange;
        } else {
          _bmiCategory = "Béo phì";
          _bmiColor = Colors.red;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4FD), // Đồng bộ với Water Tracking
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tính chỉ số BMI',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chỉ số khối cơ thể',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade300,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.calculate_rounded,
                      size: 36,
                      color: Color(0xFF1A237E),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Input Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _buildInputField(
                        label: 'Chiều cao (cm)',
                        controller: _heightController,
                        hint: 'Ví dụ: 172',
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        label: 'Cân nặng (kg)',
                        controller: _weightController,
                        hint: 'Ví dụ: 68.5',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Nút tính
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _calculateBMI,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Tính BMI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Kết quả
                if (_bmi != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                        const Divider(),
                        const SizedBox(height: 12),
                        _buildBMIRow('Thiếu cân', '< 18.5', Colors.orange),
                        _buildBMIRow(
                          'Bình thường',
                          '18.5 - 24.9',
                          Colors.green,
                        ),
                        _buildBMIRow('Thừa cân', '25.0 - 29.9', Colors.orange),
                        _buildBMIRow('Béo phì', '> 30', Colors.red),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Vui lòng nhập $label' : null,
    );
  }

  Widget _buildBMIRow(String status, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: color),
              const SizedBox(width: 8),
              Text(status, style: const TextStyle(fontSize: 15)),
            ],
          ),
          Text(
            range,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
