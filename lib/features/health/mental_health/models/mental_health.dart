class MentalHealthRecord {
  int? id;
  String emotion;
  String notes;
  String dateTime;
  String? userId;
  int isSynced;

  MentalHealthRecord({
    this.id,
    required this.emotion,
    required this.notes,
    required this.dateTime,
    this.userId,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'emotion': emotion,
      'notes': notes,
      'dateTime': dateTime,
      if (userId != null) 'userId': userId,
      'isSynced': isSynced,
    };
  }

  factory MentalHealthRecord.fromMap(Map<String, dynamic> map) {
    return MentalHealthRecord(
      id: map['id'],
      emotion: map['emotion'] ?? '',
      notes: map['notes'] ?? '',
      dateTime: map['dateTime'] ?? '',
      userId: map['userId'],
      isSynced: map['isSynced'] ?? 0,
    );
  }
}
