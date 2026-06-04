import 'package:flutter/material.dart';
import 'package:wellness_app/data/models/local/database_helper.dart';
import 'package:wellness_app/data/models/medication.dart';
import 'package:wellness_app/features/medication/screens/medication_detail_screen.dart';
import 'package:wellness_app/features/medication/widget/medication_card.dart';
import 'add_medication_screen.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  List<MedicationModel> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final data = await DatabaseHelper.instance.getAllMedications();

      setState(() {
        _medications = data;
        _isLoading = false;
      });

      debugPrint("Load thành công ${data.length} thuốc");
    } catch (e, stack) {
      debugPrint("===== SQLITE ERROR =====");
      debugPrint(e.toString());
      debugPrint(stack.toString());

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TÍNH TOÁN NGHIỆP VỤ THEO NGÀY THỰC TẾ
    String todayStr = DateTime.now().toIso8601String().split('T')[0];

    int total = _medications.length;
    // Đã uống hôm nay = Thuốc có lastTakenDate trùng với ngày hôm nay
    int completedToday = _medications
        .where((m) => m.lastTakenDate == todayStr)
        .length;
    int upcomingToday = total - completedToday;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF009688)),
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // --- PHẦN DASHBOARD ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Xin chào 👋",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            "Trung Tính",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Khối thống kê theo NGÀY HÔM NAY
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  "Thuốc hôm nay",
                                  total.toString(),
                                  Icons.medication,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  "Đã uống",
                                  completedToday.toString(),
                                  Icons.check_circle,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  "Chưa uống",
                                  upcomingToday.toString(),
                                  Icons.schedule,
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            "Lịch trình hôm nay",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // --- PHẦN DANH SÁCH THUỐC ---
                  _medications.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.vaccines,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Chưa có thuốc nào",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
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

                            String todayStr = DateTime.now()
                                .toIso8601String()
                                .split('T')[0];
                            DateTime now = DateTime.now();

                            // 1. TÍNH TOÁN LIỀU LƯỢNG VÀ SỐ LẦN UỐNG (TƯ DUY MỚI)
                            int doseAmount = 1;
                            final match = RegExp(r'\d+').firstMatch(med.dosage);
                            if (match != null)
                              doseAmount = int.parse(match.group(0)!);

                            int maxDosesWeHave =
                                med.totalQuantity ~/
                                doseAmount; // Số lần uống tối đa có thể với số thuốc hiện tại
                            int dosesTaken =
                                med.takenQuantity ~/
                                doseAmount; // Số lần đã uống
                            int dosesLeft =
                                maxDosesWeHave -
                                dosesTaken; // Số lần uống còn lại

                            // 2. KIỂM TRA ĐÃ HOÀN THÀNH LIỆU TRÌNH CHƯA (Dựa vào Số ngày uống)
                            bool isFullyCompleted = med.status == 'completed';
                            if (dosesTaken >= med.durationDays &&
                                !isFullyCompleted) {
                              // Đã uống đủ số ngày quy định -> Tự động đánh dấu hoàn thành
                              med.status = 'completed';
                              isFullyCompleted = true;
                              DatabaseHelper.instance.updateMedication(
                                med,
                              ); // Lưu xuống DB ngầm
                            }

                            // 3. LOGIC CẢNH BÁO SẮP HẾT THUỐC
                            bool isWarning = false;
                            String warningMsg = "";

                            // Số lần uống CẦN THIẾT để hoàn thành liệu trình
                            int dosesNeededToFinish =
                                med.durationDays - dosesTaken;

                            // CHỈ cảnh báo khi:
                            // - Chưa hoàn thành liệu trình
                            // - VÀ Số thuốc còn lại KHÔNG ĐỦ để kết thúc liệu trình (dosesLeft < dosesNeededToFinish)
                            // - VÀ Số thuốc còn lại chạm mức báo động (<= 1 lần uống)
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

                            // 4. LOGIC ĐÁNH GIÁ BỎ LỠ LIỀU
                            if (!isFullyCompleted &&
                                !isTakenToday &&
                                med.nextDoseDate != null) {
                              DateTime nextDate = DateTime.parse(
                                med.nextDoseDate!,
                              );
                              List<String> timeParts = med.time.split(':');
                              DateTime medDateTime = DateTime(
                                nextDate.year,
                                nextDate.month,
                                nextDate.day,
                                int.parse(timeParts[0]),
                                int.parse(timeParts[1]),
                              );

                              if (now.isAfter(medDateTime)) {
                                displayStatus = "overdue";
                              }
                            }
                            if (isFullyCompleted || isTakenToday)
                              displayStatus = "completed";

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 8.0,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  // Code Navigator (Giữ nguyên)
                                },
                                child: MedicationCard(
                                  name: med.name,
                                  dosage: med.dosage,
                                  time: med.time,
                                  status: displayStatus,
                                  takenQuantity: med.takenQuantity,
                                  totalQuantity: med.totalQuantity,

                                  // Truyền 2 biến cảnh báo mới sang Card
                                  isWarning: isWarning,
                                  warningMsg: warningMsg,

                                  onMarkAsTaken: () async {
                                    if (isTakenToday || isFullyCompleted)
                                      return;

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
                                      } else if (med.frequency ==
                                          'Cách 2 ngày') {
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
                                    await DatabaseHelper.instance
                                        .updateMedication(med);
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
        backgroundColor: const Color(0xFF009688),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Thêm thuốc",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Khối thống kê nhỏ
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

  // Popup xác nhận xóa
  void _showDeleteConfirm(BuildContext context, int id, String name) {
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
              _loadMedications();
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
