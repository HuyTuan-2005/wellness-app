import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/mental_health/controllers/mental_health_controller.dart';
import 'package:wellness_app/features/mental_health/models/mental_health.dart';

class MentalHealthTrackingScreen extends StatefulWidget {
  const MentalHealthTrackingScreen({super.key});

  @override
  State<MentalHealthTrackingScreen> createState() => _MentalHealthTrackingScreenState();
}

class _MentalHealthTrackingScreenState extends State<MentalHealthTrackingScreen> {
  final MentalHealthController _controller = MentalHealthController();
  
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddEmotionSheet(BuildContext context) {
    String selectedEmotion = 'Bình thường';
    TextEditingController noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ghi nhận cảm xúc",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildEmotionOption('Rất vui', '😁', selectedEmotion, (val) => setModalState(() => selectedEmotion = val)),
                      _buildEmotionOption('Bình thường', '😐', selectedEmotion, (val) => setModalState(() => selectedEmotion = val)),
                      _buildEmotionOption('Buồn', '😔', selectedEmotion, (val) => setModalState(() => selectedEmotion = val)),
                      _buildEmotionOption('Căng thẳng', '🤯', selectedEmotion, (val) => setModalState(() => selectedEmotion = val)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      hintText: "Bạn đang nghĩ gì? (Tùy chọn)",
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        bool success = await _controller.addRecord(
                          emotion: selectedEmotion,
                          notes: noteController.text,
                          date: _selectedDay ?? DateTime.now(),
                        );
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã ghi nhận cảm xúc!')),
                          );
                        }
                      },
                      child: const Text(
                        "Lưu lại",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmotionOption(String title, String emoji, String selectedValue, Function(String) onSelect) {
    bool isSelected = title == selectedValue;
    return GestureDetector(
      onTap: () => onSelect(title),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.grey.shade100,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<MentalHealthRecord> selectedRecords = _selectedDay != null 
        ? _controller.getRecordsForDay(_selectedDay!) 
        : [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Sức khỏe Tinh thần',
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
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Phần Lịch Calendar
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      }
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    eventLoader: (day) {
                      return _controller.getRecordsForDay(day);
                    },
                    calendarStyle: CalendarStyle(
                      selectedDecoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Colors.purple,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Phần Danh sách cảm xúc
                Expanded(
                  child: selectedRecords.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.self_improvement, size: 60, color: Colors.purple.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              const Text(
                                "Chưa có bản ghi nào trong ngày này.\nHãy ghi nhận cảm xúc của bạn!",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          itemCount: selectedRecords.length,
                          itemBuilder: (context, index) {
                            return _buildRecordCard(selectedRecords[index]);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEmotionSheet(context),
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Ghi nhận", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildRecordCard(MentalHealthRecord record) {
    String emoji = '😐';
    Color color = Colors.grey;
    if (record.emotion == 'Rất vui') {
      emoji = '😁';
      color = Colors.green;
    } else if (record.emotion == 'Buồn') {
      emoji = '😔';
      color = Colors.blue;
    } else if (record.emotion == 'Căng thẳng') {
      emoji = '🤯';
      color = Colors.red;
    }

    String timeStr = '';
    try {
      DateTime dt = DateTime.parse(record.dateTime);
      timeStr = "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      record.emotion,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (record.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    record.notes,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (record.isSynced == 1)
            const Icon(Icons.cloud_done, color: Colors.green, size: 20)
          else
            const Icon(Icons.cloud_upload_outlined, color: Colors.orange, size: 20),
        ],
      ),
    );
  }
}
