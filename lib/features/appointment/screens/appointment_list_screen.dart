import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/appointment/controllers/appointment_controller.dart';
import 'package:wellness_app/features/appointment/models/appointment.dart';
import 'package:wellness_app/features/appointment/screens/appointment_detail_screen.dart';
import 'package:wellness_app/features/appointment/screens/add_appointment_screen.dart';
import 'package:wellness_app/features/appointment/widgets/appointment_card.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    // Tự động refresh UI mỗi 15 giây để cập nhật trạng thái quá giờ
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() => _isLoading = true);
      final data = await DatabaseHelper.instance.getAllAppointments();
      setState(() {
        _appointments = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Lỗi tải danh sách lịch khám: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int total = _appointments.length;
    int completed = _appointments.where((a) => a.status == 'completed').length;
    int upcoming = total - completed; 

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Thẻ thống kê
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  "Tổng số lịch",
                                  total.toString(),
                                  Icons.medical_services,
                                  AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  "Đã khám",
                                  completed.toString(),
                                  Icons.check_circle,
                                  AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  "Sắp tới",
                                  upcoming.toString(),
                                  Icons.schedule,
                                  AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            "Danh sách lịch hẹn",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // Danh sách Appointment
                  _appointments.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_busy, size: 64, color: AppColors.border),
                                const SizedBox(height: 16),
                                Text(
                                  "Chưa có lịch hẹn nào",
                                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            final appointment = _appointments[index];
                            final displayStatus = AppointmentController.calculateDisplayStatus(appointment);
                            
                            // Parse ngày giờ để hiển thị
                            String dateStr = "";
                            String timeStr = "";
                            try {
                                DateTime dt = DateTime.parse(appointment.dateTime);
                                dateStr = "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
                                timeStr = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                            } catch(e) {
                                dateStr = appointment.dateTime; // Fallback an toàn
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: AppointmentCard(
                                doctorName: appointment.doctorName,
                                location: appointment.location,
                                date: dateStr,
                                time: timeStr,
                                status: displayStatus,
                                onViewDetails: () {
                                  if (_isProcessing) return;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AppointmentDetailScreen(
                                        appointment: appointment,
                                      ), 
                                    ),
                                  ).then((_) => _loadAppointments());
                                },
                                onNavigate: () async {
                                  if (_isProcessing) return;
                                  setState(() => _isProcessing = true);
                                  await AppointmentController.mapsToClinic(appointment.location);
                                  setState(() => _isProcessing = false);
                                },
                              ),
                            );
                          }, childCount: _appointments.length),
                        ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_isProcessing) return;
          setState(() => _isProcessing = true);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAppointmentScreen(),
            ),
          );
          _loadAppointments();
          setState(() => _isProcessing = false);
        },
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.add, color: AppColors.surface),
        label: Text(
          "Thêm lịch hẹn",
          style: TextStyle(color: AppColors.surface, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Thẻ thống kê
  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
