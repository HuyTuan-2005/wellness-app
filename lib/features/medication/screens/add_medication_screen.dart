import 'package:flutter/material.dart';
import 'package:wellness_app/features/medication/controller/medication_controller.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Khai báo các Controller
  final _notesController = TextEditingController();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _durationController = TextEditingController();
  final _totalQuantityController = TextEditingController();

  String _selectedFrequency = 'Hàng ngày';
  final List<String> _frequencies = [
    'Hàng ngày',
    'Cách 1 ngày',
    'Cách 2 ngày',
    'Chỉ khi đau',
  ];

  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _durationController.dispose();
    _totalQuantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Nền xám nhạt chuẩn Premium
      appBar: AppBar(
        title: const Text(
          "Thêm lịch uống thuốc",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: SingleChildScrollView(
        // Dùng SingleChildScrollView kết hợp Column để UI mượt hơn
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // SECTION 1: Thông tin cơ bản
              _buildSectionCard(
                title: "Thông tin cơ bản",
                children: [
                  _buildModernInput(
                    controller: _nameController,
                    hint: "Tên thuốc (Ví dụ: Paracetamol)",
                    icon: Icons.medication_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildModernInput(
                    controller: _dosageController,
                    hint: "Liều lượng (Ví dụ: 1 viên)",
                    icon: Icons.scale_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // SECTION 2: Lịch trình uống
              _buildSectionCard(
                title: "Lịch trình uống",
                children: [
                  // Chọn Giờ uống
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (time != null) setState(() => _selectedTime = time);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Color(0xFF94A3B8),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Giờ uống: ${_selectedTime.format(context)}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFF009688),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chọn Tần suất
                  DropdownButtonFormField<String>(
                    value: _selectedFrequency,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF009688),
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.calendar_month_outlined,
                        color: Color(0xFF94A3B8),
                        size: 22,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _frequencies.map((String freq) {
                      return DropdownMenuItem(
                        value: freq,
                        child: Text(
                          freq,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) =>
                        setState(() => _selectedFrequency = newValue!),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // SECTION 3: Chi tiết liều trình
              _buildSectionCard(
                title: "Chi tiết liều trình",
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernInput(
                          controller: _durationController,
                          hint: "Số ngày (Ví dụ: 3)",
                          icon: Icons.date_range_outlined,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildModernInput(
                          controller: _totalQuantityController,
                          hint: "Tổng viên (VD: 6)",
                          icon: Icons.numbers_outlined,
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildModernInput(
                    controller: _notesController,
                    hint: "Ghi chú (Ví dụ: Uống sau khi ăn no)",
                    icon: Icons.info_outline,
                    isRequired: false, // Ghi chú không bắt buộc
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // NÚT LƯU GRADIENT PREMIUM
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF009688), Color(0xFF26A69A)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF009688).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // --- 1. VALIDATION NGHIỆP VỤ Y TẾ ---
                      int duration =
                          int.tryParse(_durationController.text) ?? 0;
                      int total =
                          int.tryParse(_totalQuantityController.text) ?? 0;

                      // Trích xuất con số từ chuỗi liều lượng (VD: "3 viên" -> 3)
                      int doseAmount = 1;
                      final match = RegExp(
                        r'\d+',
                      ).firstMatch(_dosageController.text);
                      if (match != null) {
                        doseAmount = int.parse(match.group(0)!);
                      }

                      // Kiểm tra 1: Phải lớn hơn 0
                      if (duration <= 0 || total <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Số ngày và Tổng số viên phải lớn hơn 0!",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return; // Dừng lại, không cho lưu
                      }

                      // Kiểm tra 2: Tổng thuốc phải >= Liều lượng 1 lần uống
                      if (total < doseAmount) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Vô lý! Tổng số viên ($total) không thể nhỏ hơn liều lượng 1 lần uống ($doseAmount).",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return; // Dừng lại, không cho lưu
                      }
                      // --- KẾT THÚC VALIDATION ---

                      // --- 2. GỌI CONTROLLER LƯU DỮ LIỆU ---
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Đang lưu dữ liệu..."),
                          duration: Duration(seconds: 1),
                        ),
                      );

                      bool isSuccess = await MedicationController.addMedication(
                        name: _nameController.text,
                        dosage: _dosageController.text,
                        time: _selectedTime,
                        durationDaysStr: _durationController.text,
                        totalQuantityStr: _totalQuantityController.text,
                        notes: _notesController.text,
                        frequency: _selectedFrequency,
                      );

                      if (isSuccess) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Lưu lịch uống thuốc thành công!"),
                              backgroundColor: Color(0xFF009688),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Lưu thất bại. Vui lòng thử lại!"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Lưu lịch uống",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- HÀM PHỤ TRỢ XÂY DỰNG GIAO DIỆN PREMIUM ---

  // 1. Tạo khối Card bo tròn cho từng Section
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  // 2. Tạo ô nhập liệu (TextField) hiện đại
  Widget _buildModernInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isNumber = false,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) return 'Bắt buộc';
        return null;
      },
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 22),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF009688), width: 1.5),
        ),
        errorStyle: const TextStyle(height: 0.8),
      ),
    );
  }
}
