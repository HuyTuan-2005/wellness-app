import 'package:flutter/material.dart';
import '../controllers/sleep_controller.dart';
import 'package:wellness_app/core/utils/date_helper.dart';
import 'package:wellness_app/core/utils/app_helpers.dart';

class SleepTrackingScreen extends StatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  State<SleepTrackingScreen> createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  final SleepController _controller = SleepController();
  TimeOfDay _bedTime = const TimeOfDay(hour: 22, minute: 30);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 30);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  Future<void> _pickBedTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _bedTime,
    );
    if (!mounted || picked == null) return;
    setState(() {
      _bedTime = picked;
    });
  }

  Future<void> _pickWakeTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _wakeTime,
    );
    if (!mounted || picked == null) return;
    setState(() {
      _wakeTime = picked;
    });
  }

  void _saveSleepSession() {
    final result = _controller.addSleepSession(bedTime: _bedTime, wakeTime: _wakeTime);
    if (!mounted) return;
    if (result == SleepSessionResult.success) {
      AppHelpers.showSnackBar(context, 'Đã lưu phiên ngủ vào lịch sử.');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Giờ thức dậy phải sau giờ đi ngủ trong cùng một ngày. Vui lòng kiểm tra lại.'),
      ),
    );
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

  Future<void> _showGoalDialog() async {
    final textController = TextEditingController(text: _controller.goalHours.toStringAsFixed(1));

    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Mục tiêu giờ ngủ'),
          content: TextField(
            controller: textController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Nhập số giờ mục tiêu'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Hủy')),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(textController.text);
                if (value != null) {
                  Navigator.of(dialogContext).pop(value);
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    if (!mounted || result == null) return;
    _controller.updateGoal(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      body: SafeArea(
        child: Padding(
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
                        'Theo dõi giấc ngủ',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF283593),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateHelper.getDateString(),
                        style: TextStyle(fontSize: 14, color: Colors.indigo.shade300),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: IconButton(
                      icon: const Icon(Icons.settings_outlined, color: Color(0xFF283593)),
                      onPressed: _showGoalDialog,
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
                      '${_controller.todayHours.toStringAsFixed(1)} / ${_controller.goalHours.toStringAsFixed(1)} giờ',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF283593)),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _controller.progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5C6BC0)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_controller.progress * 100).round()}% hoàn thành mục tiêu',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 6),
                    Text(_controller.recommendationText, style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    Text(
                      'Đánh giá: ${_controller.latestQualityText}',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF283593)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickBedTime,
                            icon: const Icon(Icons.bedtime_outlined),
                            label: Text('Giờ ngủ: ${DateHelper.formatTime(_bedTime)}'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickWakeTime,
                            icon: const Icon(Icons.wb_sunny_outlined),
                            label: Text('Giờ thức: ${DateHelper.formatTime(_wakeTime)}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveSleepSession,
                        icon: const Icon(Icons.save_alt_outlined),
                        label: const Text('Lưu phiên ngủ'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: _controller.history.isEmpty
                      ? Center(child: Text('Chưa có lần ghi nhận nào', style: TextStyle(color: Colors.grey.shade500)))
                      : ListView.builder(
                          itemCount: _controller.history.length,
                          itemBuilder: (context, index) {
                            final item = _controller.history[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.shade50,
                                child: Icon(Icons.bedtime, color: Colors.indigo.shade400),
                              ),
                              title: Text('${item.hours.toStringAsFixed(1)} giờ ngủ'),
                              subtitle: Text('Từ ${DateHelper.formatTime(item.bedTime)} đến ${DateHelper.formatTime(item.wakeTime)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${item.createdAt.day}/${item.createdAt.month}'),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

