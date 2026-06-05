class AppointmentModel {
  String? id;
  String doctorName;
  String location;
  String dateTime; // ISO8601 String (Kết hợp ngày và giờ)
  int reminderOffset; // Số phút báo trước (vd: 60 = 1 tiếng)
  String notes;
  String status;

  AppointmentModel({
    this.id,
    required this.doctorName,
    required this.location,
    required this.dateTime,
    required this.reminderOffset,
    this.notes = "",
    this.status = "upcoming",
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorName': doctorName,
      'location': location,
      'dateTime': dateTime,
      'reminderOffset': reminderOffset,
      'notes': notes,
      'status': status,
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'].toString(),
      doctorName: map['doctorName'],
      location: map['location'],
      dateTime: map['dateTime'],
      reminderOffset: map['reminderOffset'],
      notes: map['notes'],
      status: map['status'],
    );
  }
}
