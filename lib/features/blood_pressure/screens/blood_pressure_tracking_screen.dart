import 'package:flutter/material.dart';
import '../controllers/blood_pressure_controller.dart';
import '../../utils/date_helper.dart';

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
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _controller.pressureScore,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEF5350)),
                      ),
                    ),
                    const SizedBox(height: 8),
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
}
