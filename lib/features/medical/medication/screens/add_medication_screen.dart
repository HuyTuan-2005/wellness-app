import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/medical/medication/controller/medication_controller.dart';
import 'package:wellness_app/core/utils/app_helpers.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Thêm lịch uống thuốc",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Section 1: Thông tin cơ bản
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

              // Section 2: Lịch trình uống
              _buildSectionCard(
                title: "Lịch trình uống",
                children: [
                  // Chọn giờ uống
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
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: AppColors.textSecondary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Giờ uống: ${_selectedTime.format(context)}",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chọn tần suất
                  DropdownButtonFormField<String>(
                    initialValue: _selectedFrequency,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.calendar_month_outlined,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
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

              // Section 3: Chi tiết liều trình
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
                    isRequired: false,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Nút lưu gradient
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.75),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() { _isSaving = true; });
                      try {
                        // Validation nghiệp vụ y tế
                        int duration = int.tryParse(_durationController.text) ?? 0;
                        int total = int.tryParse(_totalQuantityController.text) ?? 0;

                        // Dùng Controller để parse liều lượng
                        int doseAmount = MedicationController.parseDoseAmount(
                          _dosageController.text,
                        );

                        if (duration <= 0 || total <= 0) {
                          AppHelpers.showSnackBar(
                            context,
                            "Số ngày và Tổng số viên phải lớn hơn 0!",
                            isError: true,
                          );
                          return;
                        }

                        if (total < doseAmount) {
                          AppHelpers.showSnackBar(
                            context,
                            "Vô lý! Tổng số viên ($total) không thể nhỏ hơn liều lượng 1 lần uống ($doseAmount).",
                            isError: true,
                          );
                          return;
                        }

                        // Gọi Controller lưu dữ liệu
                        AppHelpers.showSnackBar(context, "Đang lưu dữ liệu...");

                        bool isSuccess = await MedicationController.addMedication(
                          name: _nameController.text,
                          dosage: _dosageController.text,
                          time: _selectedTime,
                          durationDaysStr: _durationController.text,
                          totalQuantityStr: _totalQuantityController.text,
                          notes: _notesController.text,
                          frequency: _selectedFrequency,
                        );

                        if (!mounted) return;

                        if (isSuccess) {
                          AppHelpers.showSnackBar(
                            context,
                            "Lưu lịch uống thuốc thành công!",
                          );
                          Navigator.pop(context);
                        } else {
                          AppHelpers.showSnackBar(
                            context,
                            "Lưu thất bại. Vui lòng thử lại!",
                            isError: true,
                          );
                        }
                      } finally {
                        if (mounted) setState(() { _isSaving = false; });
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
                  child: _isSaving 
                      ? const SizedBox(
                          height: 24, 
                          width: 24, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                        )
                      : Text(
                          "Lưu lịch uống",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.surface,
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

  // --- HÀM PHỤ TRỢ XÂY DỰNG GIAO DIỆN ---

  /// Tạo khối Card bo tròn cho từng Section
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  /// Tạo ô nhập liệu (TextField) hiện đại
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
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 22),
        filled: true,
        fillColor: AppColors.background,
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
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorStyle: const TextStyle(height: 0.8),
      ),
    );
  }
}
