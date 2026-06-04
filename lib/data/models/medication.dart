class MedicationModel {
  int? id;
  String name;
  String dosage;
  String time;
  String frequency;
  int durationDays;
  int totalQuantity;
  int takenQuantity;
  String notes;
  String status;

  // 3 TRƯỜNG MỚI ĐỂ QUẢN LÝ NGÀY
  String startDate;
  String? lastTakenDate;
  String? nextDoseDate;

  MedicationModel({
    this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.frequency,
    required this.durationDays,
    required this.totalQuantity,
    required this.takenQuantity,
    required this.notes,
    required this.status,
    required this.startDate,
    this.lastTakenDate,
    this.nextDoseDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'time': time,
      'frequency': frequency,
      'durationDays': durationDays,
      'totalQuantity': totalQuantity,
      'takenQuantity': takenQuantity,
      'notes': notes,
      'status': status,
      'startDate': startDate,
      'lastTakenDate': lastTakenDate,
      'nextDoseDate': nextDoseDate,
    };
  }

  factory MedicationModel.fromMap(Map<String, dynamic> map) {
    return MedicationModel(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      time: map['time'],
      frequency: map['frequency'],
      durationDays: map['durationDays'],
      totalQuantity: map['totalQuantity'],
      takenQuantity: map['takenQuantity'],
      notes: map['notes'],
      status: map['status'],
      startDate: map['startDate'],
      lastTakenDate: map['lastTakenDate'],
      nextDoseDate: map['nextDoseDate'],
    );
  }
}
