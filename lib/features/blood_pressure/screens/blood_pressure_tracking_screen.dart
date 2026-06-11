import 'package:flutter/material.dart';
import '../controllers/blood_pressure_controller.dart';
import 'package:wellness_app/core/utils/date_helper.dart';

class BloodPressureTrackingScreen extends StatefulWidget {
  const BloodPressureTrackingScreen({super.key});

  @override
  State<BloodPressureTrackingScreen> createState() => _BloodPressureTrackingScreenState();
}

class _BloodPressureTrackingScreenState extends State<BloodPressureTrackingScreen> {
  final BloodPressureController _controller = BloodPressureController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _showTargetDialog() async {
    final sysController = TextEditingController(text: _controller.targetSystolic.toString());
    final diaController = TextEditingController(text: _controller.targetDiastolic.toString());

    final result = await showDialog<({int sys, int dia})>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Mục tiêu huyết áp'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tâm thu (sys)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: diaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tâm trương (dia)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Hủy')),
            FilledButton(
              onPressed: () {
                final sys = int.tryParse(sysController.text);
                final dia = int.tryParse(diaController.text);
                if (sys != null && dia != null) {
                  Navigator.of(dialogContext).pop((sys: sys, dia: dia));
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    if (!mounted || result == null) return;
    _controller.updateTarget(systolic: result.sys, diastolic: result.dia);
  }

  Future<void> _showAddReadingDialog() async {
    final sysController = TextEditingController();
    final diaController = TextEditingController();
    final triggerController = TextEditingController();

    final result = await showDialog<({int sys, int dia, String trigger})>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Thêm lần đo huyết áp'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: sysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Tâm thu (sys)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: diaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Tâm trương (dia)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: triggerController,
                  decoration: const InputDecoration(
                    labelText: 'Liên quan đến thức ăn/nước uống (tùy chọn)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Hủy')),
            FilledButton(
              onPressed: () {
                final sys = int.tryParse(sysController.text);
                final dia = int.tryParse(diaController.text);
                if (sys != null && dia != null) {
                  Navigator.of(dialogContext).pop(
                    (sys: sys, dia: dia, trigger: triggerController.text.trim()),
                  );
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );

    if (!mounted || result == null) return;
    _controller.addReading(
      systolic: result.sys,
      diastolic: result.dia,
      trigger: result.trigger,
    );
  }

  @override
  Widget build(BuildContext context) {
    final latest = _controller.latest;
    final dangerMessage = latest == null ? null : _controller.dangerMessageFor(latest);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4EE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Theo dõi huyết áp',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB71C1C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateHelper.getDateString(),
                        style: TextStyle(fontSize: 14, color: Colors.red.shade300),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings_outlined, color: Color(0xFFB71C1C)),
                      onPressed: _showTargetDialog,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      latest == null
                          ? '-- / -- mmHg'
                          : '${latest.systolic}/${latest.diastolic} mmHg',
                      style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFFB71C1C)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mục tiêu: ${_controller.targetSystolic}/${_controller.targetDiastolic} mmHg',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                    if (latest != null) ...[
                      const SizedBox(height: 16),
                      _buildComparisonBar(
                        label: 'Tâm thu (sys)',
                        currentValue: latest.systolic.toDouble(),
                        minValue: 70,
                        maxValue: 180,
                        lowThreshold: 90,
                        highThreshold: 140,
                        lowLabel: 'Thấp (<90)',
                        normalLabel: 'Bình thường (90-140)',
                        highLabel: 'Cao (≥140)',
                        activeColor: _controller.statusColorFor(latest),
                      ),
                      const SizedBox(height: 20),
                      _buildComparisonBar(
                        label: 'Tâm trương (dia)',
                        currentValue: latest.diastolic.toDouble(),
                        minValue: 40,
                        maxValue: 120,
                        lowThreshold: 60,
                        highThreshold: 90,
                        lowLabel: 'Thấp (<60)',
                        normalLabel: 'Bình thường (60-90)',
                        highLabel: 'Cao (≥90)',
                        activeColor: _controller.statusColorFor(latest),
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Chưa có dữ liệu đo huyết áp để hiển thị thanh so sánh chỉ số.',
                        style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      'Trạng thái: ${_controller.statusText}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: latest == null
                            ? Colors.grey.shade600
                            : _controller.statusColorFor(latest),
                      ),
                    ),
                    if (dangerMessage != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          dangerMessage,
                          style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showAddReadingDialog,
                  icon: const Icon(Icons.favorite),
                  label: const Text('Thêm lần đo huyết áp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lịch sử đo',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFB71C1C)),
                    ),
                    const SizedBox(height: 12),
                    if (_controller.history.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text('Chưa có dữ liệu đo huyết áp', style: TextStyle(color: Colors.grey.shade500)),
                        ),
                      )
                    else
                      ..._controller.history.asMap().entries.map(
                        (mapEntry) {
                          final index = mapEntry.key;
                          final item = mapEntry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.favorite, color: Colors.red.shade300, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${item.systolic}/${item.diastolic} mmHg',
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFB71C1C)),
                                      ),
                                      if (item.trigger.isNotEmpty)
                                        Text(
                                          item.trigger,
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                        ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Phân loại: ${_controller.classify(item)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _controller.statusColorFor(item),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(DateHelper.formatTime(item.time), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _controller.removeEntry(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonBar({
    required String label,
    required double currentValue,
    required double minValue,
    required double maxValue,
    required double lowThreshold,
    required double highThreshold,
    required String lowLabel,
    required String normalLabel,
    required String highLabel,
    required Color activeColor,
  }) {
    final zoneColor = currentValue < lowThreshold
        ? Colors.orange.shade700
        : (currentValue >= highThreshold ? Colors.red.shade700 : Colors.green.shade700);

    double range = maxValue - minValue;
    double percentage = (currentValue - minValue) / range;
    percentage = percentage.clamp(0.02, 0.98);

    double lowPart = (lowThreshold - minValue) / range;
    double normalPart = (highThreshold - lowThreshold) / range;
    double highPart = (maxValue - highThreshold) / range;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            Text(
              '${currentValue.toInt()} mmHg',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: zoneColor),
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 3-Color Bar
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      // Low Zone (Orange)
                      Expanded(
                        flex: (lowPart * 100).round(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orange.shade400,
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(5)),
                          ),
                        ),
                      ),
                      // Normal Zone (Green)
                      Expanded(
                        flex: (normalPart * 100).round(),
                        child: Container(
                          color: Colors.green.shade400,
                        ),
                      ),
                      // High Zone (Red)
                      Expanded(
                        flex: (highPart * 100).round(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Indicator Arrow
                Positioned(
                  left: (constraints.maxWidth * percentage) - 12,
                  top: -18,
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 24,
                    color: zoneColor,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(lowLabel, style: TextStyle(fontSize: 10, color: Colors.orange.shade800, fontWeight: FontWeight.w500)),
            Text(normalLabel, style: TextStyle(fontSize: 10, color: Colors.green.shade800, fontWeight: FontWeight.w500)),
            Text(highLabel, style: TextStyle(fontSize: 10, color: Colors.red.shade800, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}

