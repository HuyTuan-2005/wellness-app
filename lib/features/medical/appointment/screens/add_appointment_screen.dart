import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/medical/appointment/controllers/appointment_controller.dart';
import 'package:wellness_app/core/utils/app_helpers.dart';

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _doctorNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  String _selectedReminder = '1 giờ';
  final List<String> _reminders = [
    '15 phút',
    '30 phút',
    '1 giờ',
    '2 giờ',
    '1 ngày',
  ];

  bool _isProcessing = false;

  @override
  void dispose() {
    _doctorNameController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int _getReminderOffset(String reminder) {
    switch (reminder) {
      case '15 phút':
        return 15;
      case '30 phút':
        return 30;
      case '1 giờ':
        return 60;
      case '2 giờ':
        return 120;
      case '1 ngày':
        return 1440;
      default:
        return 60;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Thêm lịch hẹn",
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
              _buildSectionCard(
                title: "Thông tin phòng khám",
                children: [
                  _buildModernInput(
                    controller: _doctorNameController,
                    hint: "Tên bác sĩ / Chuyên khoa",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildModernInput(
                    controller: _locationController,
                    hint: "Địa chỉ phòng khám",
                    icon: Icons.location_on_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionCard(
                title: "Thời gian",
                children: [
                  // Chọn ngày
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => _selectedDate = date);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: AppColors.textSecondary, size: 22),
                          const SizedBox(width: 12),
                          Text(
                            "Ngày: ${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}",
                            style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Icon(Icons.edit_outlined,
                              color: AppColors.primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chọn giờ
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (time != null) {
                        setState(() => _selectedTime = time);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time,
                              color: AppColors.textSecondary, size: 22),
                          const SizedBox(width: 12),
                          Text(
                            "Giờ khám: ${_selectedTime.format(context)}",
                            style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Icon(Icons.edit_outlined,
                              color: AppColors.primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionCard(
                title: "Chi tiết bổ sung",
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedReminder,
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary),
                    decoration: InputDecoration(
                      labelText: "Nhắc nhở trước",
                      prefixIcon: Icon(Icons.notifications_active_outlined,
                          color: AppColors.textSecondary, size: 22),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _reminders.map((String rem) {
                      return DropdownMenuItem(
                        value: rem,
                        child: Text(rem,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (newValue) =>
                        setState(() => _selectedReminder = newValue!),
                  ),
                  const SizedBox(height: 16),
                  _buildModernInput(
                    controller: _notesController,
                    hint: "Ghi chú (Không bắt buộc)",
                    icon: Icons.info_outline,
                    isRequired: false,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Nút lưu
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.75)
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
                  onPressed: _isProcessing
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isProcessing = true);
                            try {
                              DateTime combinedDateTime = DateTime(
                                _selectedDate.year,
                                _selectedDate.month,
                                _selectedDate.day,
                                _selectedTime.hour,
                                _selectedTime.minute,
                              );

                              if (combinedDateTime.isBefore(DateTime.now())) {
                                AppHelpers.showSnackBar(
                                  context,
                                  "Thời gian khám không được ở trong quá khứ!",
                                  isError: true,
                                );
                                setState(() => _isProcessing = false);
                                return;
                              }

                              AppHelpers.showSnackBar(
                                  context, "Đang lưu lịch hẹn...");

                              bool isSuccess =
                                  await AppointmentController.addAppointment(
                                doctorName: _doctorNameController.text,
                                location: _locationController.text,
                                dateTime: combinedDateTime.toIso8601String(),
                                reminderOffset:
                                    _getReminderOffset(_selectedReminder),
                                notes: _notesController.text,
                              );

                              if (isSuccess && context.mounted) {
                                AppHelpers.showSnackBar(
                                    context, "Lưu lịch hẹn thành công!");
                                Navigator.pop(context);
                              } else if (context.mounted) {
                                AppHelpers.showSnackBar(
                                    context, "Lưu thất bại. Vui lòng thử lại!",
                                    isError: true);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                AppHelpers.showSnackBar(
                                    context, "Đã xảy ra lỗi: $e",
                                    isError: true);
                              }
                            } finally {
                              if (mounted) setState(() => _isProcessing = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          "Lưu lịch khám",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
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

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
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
                color: AppColors.textDark),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'Bắt buộc nhập';
        }
        return null;
      },
      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: AppColors.textSecondary, fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 22),
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
