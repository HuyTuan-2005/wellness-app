import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wellness_app/service/notification_service.dart';

import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/core/database/database_helper.dart';

import 'package:wellness_app/features/medication/models/medication.dart';
import 'package:wellness_app/features/medication/widget/medication_card.dart';
import 'package:wellness_app/features/medication/screens/add_medication_screen.dart';
import 'package:wellness_app/features/medication/screens/medication_detail_screen.dart';

import 'package:wellness_app/features/appointment/models/appointment.dart';
import 'package:wellness_app/features/appointment/widgets/appointment_card.dart';
import 'package:wellness_app/features/appointment/screens/add_appointment_screen.dart';
import 'package:wellness_app/features/appointment/screens/appointment_detail_screen.dart';

class MedicalScheduleScreen extends StatefulWidget {
  const MedicalScheduleScreen({super.key});

  @override
  State<MedicalScheduleScreen> createState() => _MedicalScheduleScreenState();
}

class _MedicalScheduleScreenState extends State<MedicalScheduleScreen> {
  // Data
  List<MedicationModel> _medications = [];
  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadAllData();

    // Cứ 15 giây tự động làm mới giao diện 1 lần để cập nhật trạng thái Quá giờ
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final meds = await DatabaseHelper.instance.getAllMedications();
      final appts = await DatabaseHelper.instance.getAllAppointments();
      if (mounted) {
        setState(() {
          _medications = meds;
          _appointments = appts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải dữ liệu: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Y tế',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(icon: Icon(Icons.medication), text: 'Lịch uống thuốc'),
              Tab(
                icon: Icon(Icons.medical_services), // Ống nghe y tế
                text: 'Lịch khám',
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : TabBarView(
                children: [
                  // Tab 1: Lịch uống thuốc
                  Scaffold(
                    backgroundColor: Colors.transparent,
                    body: _buildMedicationList(),
                    floatingActionButton: FloatingActionButton.extended(
                      heroTag: 'add_med',
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddMedicationScreen(),
                          ),
                        );
                        _loadAllData();
                      },
                      backgroundColor: const Color(0xFF009688),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Thêm thuốc",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Tab 2: Lịch khám
                  Scaffold(
                    backgroundColor: Colors.transparent,
                    body: _buildAppointmentList(),
                    floatingActionButton: FloatingActionButton.extended(
                      heroTag: 'add_appt',
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddAppointmentScreen(),
                          ),
                        );
                        _loadAllData();
                      },
                      backgroundColor: const Color(0xFF009688),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Thêm lịch khám",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ==================== TAB LỊCH UỐNG THUỐC ====================
  Widget _buildMedicationList() {
    if (_medications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.vaccines, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "Chưa có lịch uống thuốc nào",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        80,
      ), // Padding bottom to avoid FAB
      itemCount: _medications.length,
      itemBuilder: (context, index) {
        final med = _medications[index];
        String todayStr = DateTime.now().toIso8601String().split('T')[0];
        DateTime now = DateTime.now();

        // Tính toán liều lượng
        int doseAmount = 1;
        final match = RegExp(r'\d+').firstMatch(med.dosage);
        if (match != null) doseAmount = int.parse(match.group(0)!);

        int maxDosesWeHave = med.totalQuantity ~/ doseAmount;
        int dosesTaken = med.takenQuantity ~/ doseAmount;
        int dosesLeft = maxDosesWeHave - dosesTaken;

        // Trạng thái hoàn thành
        bool isFullyCompleted = med.status == 'completed';
        if (dosesTaken >= med.durationDays && !isFullyCompleted) {
          med.status = 'completed';
          isFullyCompleted = true;
          DatabaseHelper.instance.updateMedication(med);
        }

        // Cảnh báo hết thuốc
        bool isWarning = false;
        String warningMsg = "";
        int dosesNeededToFinish = med.durationDays - dosesTaken;

        if (!isFullyCompleted &&
            dosesLeft < dosesNeededToFinish &&
            dosesLeft <= 1) {
          isWarning = true;
          warningMsg = dosesLeft == 0
              ? "Đã hết thuốc! Cần mua thêm."
              : "Chỉ còn đủ 1 lần uống!";
        }

        bool isTakenToday = med.lastTakenDate == todayStr;
        String displayStatus = "upcoming";

        // Kiểm tra quá giờ
        if (!isFullyCompleted && !isTakenToday && med.nextDoseDate != null) {
          DateTime nextDate = DateTime.parse(med.nextDoseDate!);
          List<String> timeParts = med.time.split(':');
          DateTime medDateTime = DateTime(
            nextDate.year,
            nextDate.month,
            nextDate.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
          if (now.isAfter(medDateTime)) displayStatus = "overdue";
        }

        if (isFullyCompleted || isTakenToday) displayStatus = "completed";

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MedicationDetailScreen(
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
            ).then((_) => _loadAllData());
          },
          child: MedicationCard(
            name: med.name,
            dosage: med.dosage,
            time: med.time,
            status: displayStatus,
            takenQuantity: med.takenQuantity,
            totalQuantity: med.totalQuantity,
            isWarning: isWarning,
            warningMsg: warningMsg,
            onMarkAsTaken: () async {
              if (isTakenToday || isFullyCompleted) return;
              setState(() {
                med.takenQuantity += doseAmount;
                if (med.takenQuantity > med.totalQuantity)
                  med.takenQuantity = med.totalQuantity;
                med.lastTakenDate = todayStr;

                if (med.frequency == 'Cách 1 ngày') {
                  med.nextDoseDate = now
                      .add(const Duration(days: 2))
                      .toIso8601String()
                      .split('T')[0];
                } else if (med.frequency == 'Cách 2 ngày') {
                  med.nextDoseDate = now
                      .add(const Duration(days: 3))
                      .toIso8601String()
                      .split('T')[0];
                } else {
                  med.nextDoseDate = now
                      .add(const Duration(days: 1))
                      .toIso8601String()
                      .split('T')[0];
                }
              });
              await DatabaseHelper.instance.updateMedication(med);

              // --- ĐỒNG BỘ NOTIFICATION KHI BẤM "UỐNG" ---
              await NotificationService().cancelNotification(med.id!);

              if (med.status != 'completed') {
                DateTime nextDate = DateTime.parse(med.nextDoseDate!);
                List<String> timeParts = med.time.split(':');
                DateTime nextDoseTime = DateTime(
                  nextDate.year,
                  nextDate.month,
                  nextDate.day,
                  int.parse(timeParts[0]),
                  int.parse(timeParts[1]),
                );

                await NotificationService().scheduleNotification(
                  id: med.id!,
                  title: "💊 Đã đến giờ uống thuốc!",
                  body: "Đến giờ uống ${med.dosage} ${med.name} rồi. Nhớ uống đúng giờ nhé!",
                  scheduledTime: nextDoseTime,
                );
              }
            },
            onDelete: () =>
                _showDeleteMedicationConfirm(context, med.id!, med.name),
          ),
        );
      },
    );
  }

  // ==================== TAB LỊCH KHÁM ====================
  Widget _buildAppointmentList() {
    if (_appointments.isEmpty) {
      return const Center(child: Text("Bạn chưa có lịch hẹn nào."));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        80,
      ), // Padding bottom to avoid FAB
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appt = _appointments[index];
        String displayDate = appt.dateTime.split(' ')[0];
        String displayTime = appt.dateTime.contains(' ')
            ? appt.dateTime.split(' ')[1]
            : appt.dateTime;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AppointmentDetailScreen(
                  doctorName: appt.doctorName,
                  location: appt.location,
                  date: displayDate,
                  time: displayTime,
                  status: appt.status,
                ),
              ),
            ).then((_) => _loadAllData());
          },
          child: AppointmentCard(
            doctorName: appt.doctorName,
            location: appt.location,
            date: displayDate,
            time: displayTime,
            status: appt.status,
            onViewDetails: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AppointmentDetailScreen(
                    doctorName: appt.doctorName,
                    location: appt.location,
                    date: displayDate,
                    time: displayTime,
                    status: appt.status,
                  ),
                ),
              ).then((_) => _loadAllData());
            },
          ),
        );
      },
    );
  }

  // ==================== HÀM HỖ TRỢ ====================
  void _showDeleteMedicationConfirm(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Xóa lịch uống thuốc '$name'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseHelper.instance.deleteMedication(id);
              await NotificationService().cancelNotification(id); // Xóa cả báo thức khi xóa thuốc
              _loadAllData();
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
