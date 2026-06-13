import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'package:wellness_app/features/health/weight/models/weight_record.dart';

class DataSyncService {
  static final DataSyncService _instance = DataSyncService._internal();
  factory DataSyncService() => _instance;
  DataSyncService._internal();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool _isSyncing = false;

  // Instance method used by auth_wrapper
  Future<void> syncOnLogin(String uid) async {
    debugPrint("[DataSyncService] syncOnLogin called for: $uid");
    await pullCloudToLocal();
    await syncLocalToCloud();
  }

  /// Quét SQLite và đẩy các bản ghi chưa đồng bộ (isSynced = 0) lên Firestore
  static Future<void> syncLocalToCloud() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      debugPrint("DataSyncService: Chưa đăng nhập, không thể đồng bộ.");
      return;
    }
    final String uid = user.uid;

    try {
      debugPrint("DataSyncService: Đang quét dữ liệu chưa đồng bộ dưới SQLite...");

      // 1. Đồng bộ bảng Thuốc (Medications)
      final unsyncedMeds = await DatabaseHelper.instance.getUnsyncedMedications();
      for (var med in unsyncedMeds) {
        String docId = med['id'].toString();
        
        Map<String, dynamic> dataToSync = Map<String, dynamic>.from(med);
        dataToSync['userId'] = uid;
        dataToSync['isSynced'] = 1;

        await _firestore
            .collection('users')
            .doc(uid)
            .collection('medications')
            .doc(docId)
            .set(dataToSync, SetOptions(merge: true));

        await DatabaseHelper.instance.markAsSynced('medications', med['id'] as int);
        debugPrint("DataSyncService: Đã đẩy Thuốc ID ${med['id']} lên Cloud.");
      }

      // 2. Đồng bộ bảng Lịch khám (Appointments)
      final unsyncedAppts = await DatabaseHelper.instance.getUnsyncedAppointments();
      for (var appt in unsyncedAppts) {
        String docId = appt['id'].toString();
        
        Map<String, dynamic> dataToSync = Map<String, dynamic>.from(appt);
        dataToSync['userId'] = uid;
        dataToSync['isSynced'] = 1;

        await _firestore
            .collection('users')
            .doc(uid)
            .collection('appointments')
            .doc(docId)
            .set(dataToSync, SetOptions(merge: true));

        await DatabaseHelper.instance.markAsSynced('appointments', appt['id'] as int);
        debugPrint("DataSyncService: Đã đẩy Lịch khám ID ${appt['id']} lên Cloud.");
      }

      // 3. Đồng bộ Cân nặng (WeightRecords) - So sánh danh sách ID
      final localWeights = await DatabaseHelper.instance.getAllWeightRecords();
      final weightRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('weight_records');

      final weightSnapshot = await weightRef.get();
      final remoteWeightIds = weightSnapshot.docs.map((doc) => int.tryParse(doc.id)).toSet();

      for (var localRecord in localWeights) {
        if (localRecord.id != null && !remoteWeightIds.contains(localRecord.id)) {
          await weightRef.doc(localRecord.id.toString()).set(localRecord.toMap());
          debugPrint("DataSyncService: Đã tải lên cân nặng từ SQLite: ${localRecord.weight} kg");
        }
      }

      // 4. Đồng bộ Sức khỏe Tinh thần (Mental Health)
      final unsyncedEmotions = await DatabaseHelper.instance.getUnsyncedMentalHealthRecords();
      for (var record in unsyncedEmotions) {
        String docId = record['id'].toString();
        
        Map<String, dynamic> dataToSync = Map<String, dynamic>.from(record);
        dataToSync['userId'] = uid;
        dataToSync['isSynced'] = 1;

        await _firestore
            .collection('users')
            .doc(uid)
            .collection('mental_health_records')
            .doc(docId)
            .set(dataToSync, SetOptions(merge: true));

        await DatabaseHelper.instance.markAsSynced('mental_health_records', record['id'] as int);
        debugPrint("DataSyncService: Đã đẩy Cảm xúc ID ${record['id']} lên Cloud.");
      }

      debugPrint("DataSyncService: Hoàn tất syncLocalToCloud.");
    } catch (e) {
      debugPrint("DataSyncService: Lỗi trong quá trình syncLocalToCloud - $e");
    }
  }

  /// Tải dữ liệu từ Firestore xuống SQLite (Ví dụ khi đăng nhập thiết bị mới)
  static Future<void> pullCloudToLocal() async {
    if (_isSyncing) return;
    _isSyncing = true;

    final User? user = _auth.currentUser;
    if (user == null) {
      debugPrint("DataSyncService: Chưa đăng nhập, không thể tải dữ liệu.");
      _isSyncing = false;
      return;
    }

    final String uid = user.uid;
    final db = await DatabaseHelper.instance.database;

    try {
      debugPrint("DataSyncService: Bắt đầu tải dữ liệu từ Cloud về máy...");

      // 1. Tải Medications
      final medsSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('medications')
          .get();

      for (var doc in medsSnapshot.docs) {
        final data = doc.data();
        data['isSynced'] = 1; // Đánh dấu đã sync vì lấy từ cloud về

        int id = int.parse(doc.id);
        data['id'] = id; // Bổ sung ID nguyên thủy
        
        await db.insert('medications', data, conflictAlgorithm: ConflictAlgorithm.replace);
        debugPrint("DataSyncService: Đã tải Thuốc ID $id về máy.");
      }

      // 2. Tải Appointments
      final apptsSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('appointments')
          .get();

      for (var doc in apptsSnapshot.docs) {
        final data = doc.data();
        data['isSynced'] = 1;

        int id = int.parse(doc.id);
        data['id'] = id;

        await db.insert('appointments', data, conflictAlgorithm: ConflictAlgorithm.replace);
        debugPrint("DataSyncService: Đã tải Lịch khám ID $id về máy.");
      }

      // 3. Tải Cân nặng
      final weightSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('weight_records')
          .get();

      final localWeights = await DatabaseHelper.instance.getAllWeightRecords();
      final localWeightIds = localWeights.map((w) => w.id).toSet();

      for (var doc in weightSnapshot.docs) {
        final data = doc.data();
        final record = WeightRecord.fromMap(data);
        if (!localWeightIds.contains(record.id)) {
          await DatabaseHelper.instance.insertWeightRecord(record);
          debugPrint("DataSyncService: Đã khôi phục cân nặng từ Firestore: ${record.weight} kg");
        }
      }

      // 4. Tải Sức khỏe tinh thần
      final emotionsSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('mental_health_records')
          .get();

      for (var doc in emotionsSnapshot.docs) {
        final data = doc.data();
        data['isSynced'] = 1;

        int id = int.parse(doc.id);
        data['id'] = id;

        await db.insert('mental_health_records', data, conflictAlgorithm: ConflictAlgorithm.replace);
        debugPrint("DataSyncService: Đã tải Cảm xúc ID $id về máy.");
      }

      debugPrint("DataSyncService: Hoàn tất pullCloudToLocal.");
    } catch (e) {
      debugPrint("DataSyncService: Lỗi trong quá trình pullCloudToLocal - $e");
    } finally {
      _isSyncing = false;
    }
  }
}
