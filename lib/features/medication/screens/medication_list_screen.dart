import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/medication/controller/medication_controller.dart';
import 'package:wellness_app/features/medication/models/medication.dart';
import 'package:wellness_app/features/medication/screens/medication_detail_screen.dart';
import 'package:wellness_app/features/medication/widget/medication_card.dart';
import 'package:wellness_app/service/notification_service.dart';
import 'add_medication_screen.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  List<MedicationModel> _medications = [];
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadMedications();
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

  Future<void> _loadMedications() async {
    try {
      setState(() => _isLoading = true);
      final data = await DatabaseHelper.instance.getAllMedications();
      // Kiểm tra và cập nhật trạng thái hoàn thành (thay vì kiểm tra trong build)
      await MedicationController.checkAndUpdateCompletionStatus(data);
      setState(() {
        _medications = data;
        _isLoading = false;
      });
    } catch (e, stack) {
      debugPrint("===== SQLITE ERROR =====");
      debugPrint(e.toString());
      debugPrint(stack.toString());
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String todayStr = DateTime.now().toIso8601String().split('T')[0];

    int total = _medications.length;
    int completedToday =
        _medications.where((m) => m.lastTakenDate == todayStr).length;
    int upcomingToday = total - completedToday;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Thẻ thống kê tổng quan hôm nay
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  "Tổng số thuốc",
                                  total.toString(),
                                  Icons.medication,
                                  AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  "Đã uống",
                                  completedToday.toString(),
                                  Icons.check_circle,
                                  AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  "Chưa uống",
                                  upcomingToday.toString(),
                                  Icons.schedule,
                                  AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            "Lịch trình hôm nay",
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

                  // Danh sách thuốc hoặc trạng thái rỗng
                  _medications.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.vaccines,
                                  size: 64,
                                  color: AppColors.border,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Chưa có thuốc nào",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final med = _medications[index];

                            // Sử dụng Controller cho toàn bộ logic nghiệp vụ
                            String displayStatus =
                                MedicationController.calculateDisplayStatus(
                                    med);
                            final warning =
                                MedicationController.calculateWarning(med);

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 8.0,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MedicationDetailScreen(
                                            name: med.name,
                                            dosage: med.dosage,
                                            time: med.time,
                                            status: displayStatus,
                                            frequency: med.frequency,
                                            notes: med.notes,
                                            takenQuantity: med.takenQuantity,
                                            totalQuantity: med.totalQuantity,
                                          ),
                                    ),
                                  ).then((_) => _loadMedications());
                                },
                                child: MedicationCard(
                                  name: med.name,
                                  dosage: med.dosage,
                                  time: med.time,
                                  status: displayStatus,
                                  takenQuantity: med.takenQuantity,
                                  totalQuantity: med.totalQuantity,
                                  isWarning: warning['isWarning'] as bool,
                                  warningMsg: warning['warningMsg'] as String,
                                  onMarkAsTaken: () async {
                                    if (displayStatus == "completed") return;
                                    await MedicationController.markAsTaken(med);
                                    if (mounted) setState(() {});
                                  },
                                  onDelete: () {
                                    _showDeleteConfirm(
                                      context,
                                      med.id!,
                                      med.name,
                                    );
                                  },
                                ),
                              ),
                            );
                          }, childCount: _medications.length),
                        ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMedicationScreen(),
            ),
          );
          _loadMedications();
        },
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.add, color: AppColors.surface),
        label: Text(
          "Thêm thuốc",
          style: TextStyle(
            color: AppColors.surface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Thẻ thống kê với icon, số lượng và tiêu đề
  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
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
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Hiển thị dialog xác nhận xóa thuốc và hủy báo thức liên quan
  void _showDeleteConfirm(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Xóa lịch uống thuốc '$name'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Hủy",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseHelper.instance.deleteMedication(id);
              await NotificationService().cancelNotification(id);
              _loadMedications();
            },
            child: Text(
              "Xóa",
              style: TextStyle(color: AppColors.surface),
            ),
          ),
        ],
      ),
    );
  }
}
