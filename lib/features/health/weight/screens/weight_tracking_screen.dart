import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'package:wellness_app/features/health/weight/models/weight_record.dart';

class WeightTrackingScreen extends StatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen> {
  List<WeightRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final records = await DatabaseHelper.instance.getAllWeightRecords();
      if (records.isEmpty) {
        // Add initial record if empty
        final initialRecord = WeightRecord(
          weight: UserProfile.weight,
          date: DateTime.now().subtract(const Duration(days: 7)),
        );
        await DatabaseHelper.instance.insertWeightRecord(initialRecord);
        records.add(initialRecord);
      }
      
      // Sort by date ascending
      records.sort((a, b) => a.date.compareTo(b.date));

      if (mounted) {
        setState(() {
          _records = records;
          // Update global profile to latest
          UserProfile.weight = records.last.weight;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading weight records: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddWeightDialog() {
    // Initial values based on current weight
    int selectedInteger = UserProfile.weight.truncate();
    int selectedDecimal = ((UserProfile.weight - selectedInteger) * 10).round();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext builderContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 300,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy', style: TextStyle(color: Colors.red, fontSize: 16)),
                      ),
                      const Text(
                        'Nhập Cân Nặng',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      TextButton(
                        onPressed: () async {
                          double newWeight = selectedInteger + (selectedDecimal / 10.0);
                          final record = WeightRecord(
                            weight: newWeight,
                            date: DateTime.now(),
                          );
                          final id = await DatabaseHelper.instance.insertWeightRecord(record);
                          
                          // Update profile
                          UserProfile.weight = newWeight;

                          final int caloGoal = UserProfile.getSuggestedCaloriesFor(
                            weight: newWeight,
                            height: UserProfile.height,
                            age: UserProfile.age,
                            gender: UserProfile.gender,
                          );
                          UserProfile.dailyCaloGoal = caloGoal;
                          
                          // Sync to Firestore
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('weight_records')
                                .doc(id.toString())
                                .set(record.toMap()..['id'] = id)
                                .catchError((e) => debugPrint("Error syncing weight to Firestore: $e"));

                            FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                              'weight': newWeight,
                              'dailyCaloGoal': caloGoal,
                            }).catchError((e) => debugPrint("Error updating profile weight on Firestore: $e"));
                          }
                          
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          _loadRecords(); // Reload
                        },
                        child: const Text('Xác nhận', style: TextStyle(color: AppColors.primary, fontSize: 16)),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Highlight box overlay for CupertinoPicker center
                        Container(
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Positioned.fill(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Integer Picker
                              SizedBox(
                                width: 80,
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(initialItem: selectedInteger - 30),
                                  itemExtent: 40,
                                  onSelectedItemChanged: (index) {
                                    setModalState(() {
                                      selectedInteger = index + 30;
                                    });
                                  },
                                  children: List.generate(121, (index) {
                                    return Center(
                                      child: Text(
                                        '${index + 30}',
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              // Comma
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  ',',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                              // Decimal Picker
                              SizedBox(
                                width: 60,
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(initialItem: selectedDecimal),
                                  itemExtent: 40,
                                  onSelectedItemChanged: (index) {
                                    setModalState(() {
                                      selectedDecimal = index;
                                    });
                                  },
                                  children: List.generate(10, (index) {
                                    return Center(
                                      child: Text(
                                        '$index',
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'kg',
                                style: TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Theo dõi Cân nặng',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildChartSection(),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildHistoryList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddWeightDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ghi nhận thay đổi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildChartSection() {
    if (_records.isEmpty) return const SizedBox();

    List<FlSpot> spots = [];
    double minX = 0;
    double maxX = (_records.length - 1).toDouble();
    if (maxX < 1) maxX = 1; // Default width
    double minY = 150;
    double maxY = 0;

    for (int i = 0; i < _records.length; i++) {
      final weight = _records[i].weight;
      spots.add(FlSpot(i.toDouble(), weight));
      if (weight < minY) minY = weight;
      if (weight > maxY) maxY = weight;
    }

    minY = (minY - 5).floorToDouble();
    maxY = (maxY + 5).ceilToDouble();

    return Container(
      height: 250,
      padding: const EdgeInsets.only(right: 20, left: 10, top: 20, bottom: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < _records.length) {
                    final date = _records[index].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${date.day}/${date.month}',
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox();
                },
                interval: 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.cyan,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.cyan,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.cyan.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Lịch sử cân nặng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
              itemCount: _records.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                // Reverse list to show newest first
                final record = _records[_records.length - 1 - index];
                
                double diff = 0;
                if (_records.length - 1 - index > 0) {
                  final previousRecord = _records[_records.length - 2 - index];
                  diff = record.weight - previousRecord.weight;
                }

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.monitor_weight, color: Colors.cyan),
                  ),
                  title: Text(
                    '${record.weight.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    '${record.date.day.toString().padLeft(2, '0')}/${record.date.month.toString().padLeft(2, '0')}/${record.date.year} - ${record.date.hour.toString().padLeft(2, '0')}:${record.date.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: diff == 0 
                    ? const Text('--', style: TextStyle(color: Colors.grey))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            diff > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                            color: diff > 0 ? Colors.red : Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${diff.abs().toStringAsFixed(1)} kg',
                            style: TextStyle(
                              color: diff > 0 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
