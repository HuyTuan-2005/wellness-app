import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/medical/appointment/models/appointment.dart';
import 'package:wellness_app/features/medical/appointment/controllers/appointment_controller.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const AppointmentDetailScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  bool _isProcessing = false;

  void _markAsCompleted() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    await AppointmentController.markAsCompleted(widget.appointment);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _deleteAppointment() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận hủy lịch hẹn"),
        content: const Text("Bạn có chắc chắn muốn hủy lịch khám này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Không"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hủy lịch", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    await AppointmentController.deleteAppointment(widget.appointment);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _navigateToClinic() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    await AppointmentController.mapsToClinic(widget.appointment.location);
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateStr = AppointmentController.formatDateTime(widget.appointment.dateTime)
        .split(' - ')
        .last;
    String timeStr = AppointmentController.formatDateTime(widget.appointment.dateTime)
        .split(' - ')
        .first;
    bool isCompleted = widget.appointment.status == 'completed';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Chi tiết lịch hẹn",
          style: TextStyle(
              color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: _deleteAppointment,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person,
                            color: AppColors.primary, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.appointment.doctorName,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark),
                            ),
                            Text(
                              "Chuyên khoa / Bác sĩ",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildDetailRow(Icons.calendar_today, "Ngày khám", dateStr),
                  _buildDetailRow(Icons.access_time, "Giờ khám", timeStr),
                  _buildDetailRow(Icons.location_on_outlined, "Địa điểm",
                      widget.appointment.location),
                  _buildDetailRow(Icons.notifications_active_outlined,
                      "Nhắc trước", "${widget.appointment.reminderOffset} phút"),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (widget.appointment.notes.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ghi chú",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    Text(
                      widget.appointment.notes,
                      style: TextStyle(
                          color: AppColors.textSecondary, height: 1.5),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 40),

            // Nút chỉ đường
            OutlinedButton.icon(
              onPressed: _navigateToClinic,
              icon: Icon(Icons.directions, color: AppColors.primary),
              label: Text("Chỉ đường đến phòng khám",
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),

            const SizedBox(height: 16),

            // Nút đánh dấu hoàn thành
            if (!isCompleted)
              ElevatedButton.icon(
                onPressed: _markAsCompleted,
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text("Đã khám xong",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text("$label: ", style: TextStyle(color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.textDark),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
