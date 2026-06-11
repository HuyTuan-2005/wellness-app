import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'package:wellness_app/features/weight/models/weight_record.dart';
import 'package:wellness_app/features/medication/models/medication.dart';
import 'package:wellness_app/features/appointment/models/appointment.dart';

class DataSyncService {
  static final DataSyncService _instance = DataSyncService._internal();
  factory DataSyncService() => _instance;
  DataSyncService._internal();

  bool _isSyncing = false;

  Future<void> syncOnLogin(String uid) async {
    if (_isSyncing) return;
    _isSyncing = true;
    debugPrint("[DataSyncService] Bắt đầu đồng bộ dữ liệu khi đăng nhập cho user: $uid");

    try {
      final db = DatabaseHelper.instance;

      // 1. Đồng bộ Cân nặng (2 chiều)
      final localWeights = await db.getAllWeightRecords();
      final localWeightIds = localWeights.map((w) => w.id).toSet();

      final weightSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('weight_records')
          .get();
      final remoteWeightIds = weightSnapshot.docs.map((doc) => int.tryParse(doc.id)).toSet();

      // Tải từ Firestore về SQLite cục bộ
      for (var doc in weightSnapshot.docs) {
        final record = WeightRecord.fromMap(doc.data());
        if (!localWeightIds.contains(record.id)) {
          await db.insertWeightRecord(record);
          debugPrint("[DataSyncService] Đã khôi phục cân nặng từ Firestore: ${record.weight} kg");
        }
      }

      // Tải từ SQLite cục bộ lên Firestore
      final weightRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('weight_records');
      for (var localRecord in localWeights) {
        if (localRecord.id != null && !remoteWeightIds.contains(localRecord.id)) {
          await weightRef.doc(localRecord.id.toString()).set(localRecord.toMap());
          debugPrint("[DataSyncService] Đã tải lên cân nặng từ SQLite: ${localRecord.weight} kg");
        }
      }

      // 2. Đồng bộ Lịch uống thuốc (2 chiều)
      final localMedications = await db.getAllMedications();
      final localMedicationIds = localMedications.map((m) => m.id).toSet();

      final medicationSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('medications')
          .get();
      final remoteMedicationIds = medicationSnapshot.docs.map((doc) => int.tryParse(doc.id)).toSet();

      // Tải từ Firestore về SQLite cục bộ
      for (var doc in medicationSnapshot.docs) {
        final record = MedicationModel.fromMap(doc.data());
        if (!localMedicationIds.contains(record.id)) {
          await db.insertMedication(record);
          debugPrint("[DataSyncService] Đã khôi phục lịch uống thuốc từ Firestore: ${record.name}");
        }
      }

      // Tải từ SQLite cục bộ lên Firestore
      final medicationRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('medications');
      for (var localRecord in localMedications) {
        if (localRecord.id != null && !remoteMedicationIds.contains(localRecord.id)) {
          await medicationRef.doc(localRecord.id.toString()).set(localRecord.toMap());
          debugPrint("[DataSyncService] Đã tải lên lịch uống thuốc từ SQLite: ${localRecord.name}");
        }
      }

      // 3. Đồng bộ Lịch khám (2 chiều)
      final localAppointments = await db.getAllAppointments();
      final localAppointmentIds = localAppointments.map((a) => a.id).toSet();

      final appointmentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('appointments')
          .get();
      final remoteAppointmentIds = appointmentSnapshot.docs.map((doc) => doc.id).toSet();

      // Tải từ Firestore về SQLite cục bộ
      for (var doc in appointmentSnapshot.docs) {
        final record = AppointmentModel.fromMap(doc.data());
        if (!localAppointmentIds.contains(record.id)) {
          await db.insertAppointment(record);
          debugPrint("[DataSyncService] Đã khôi phục lịch khám bác sĩ từ Firestore: ${record.doctorName}");
        }
      }

      // Tải từ SQLite cục bộ lên Firestore
      final appointmentRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('appointments');
      for (var localRecord in localAppointments) {
        if (localRecord.id != null && !remoteAppointmentIds.contains(localRecord.id)) {
          await appointmentRef.doc(localRecord.id!).set(localRecord.toMap());
          debugPrint("[DataSyncService] Đã tải lên lịch khám từ SQLite: ${localRecord.doctorName}");
        }
      }

      debugPrint("[DataSyncService] Đồng bộ dữ liệu thành công!");
    } catch (e) {
      debugPrint("[DataSyncService] Lỗi khi đồng bộ dữ liệu: $e");
    } finally {
      _isSyncing = false;
    }
  }
}
