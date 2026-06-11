import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wellness_app/core/database/database_helper.dart';

class DataSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

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
        
        // Tạo bản sao dữ liệu để đẩy lên Cloud
        Map<String, dynamic> dataToSync = Map<String, dynamic>.from(med);
        dataToSync['userId'] = uid;
        dataToSync['isSynced'] = 1;

        // Merge dữ liệu lên Firestore
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('medications')
            .doc(docId)
            .set(dataToSync, SetOptions(merge: true));

        // Cập nhật lại isSynced = 1 dưới local DB
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

      debugPrint("DataSyncService: Hoàn tất syncLocalToCloud.");
    } catch (e) {
      debugPrint("DataSyncService: Lỗi trong quá trình syncLocalToCloud - $e");
    }
  }

  /// Tải dữ liệu từ Firestore xuống SQLite (Ví dụ khi đăng nhập thiết bị mới)
  static Future<void> pullCloudToLocal() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      debugPrint("DataSyncService: Chưa đăng nhập, không thể tải dữ liệu.");
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
        
        // Dùng conflictAlgorithm.replace để cập nhật nếu đã tồn tại hoặc tạo mới
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

      debugPrint("DataSyncService: Hoàn tất pullCloudToLocal.");
    } catch (e) {
      debugPrint("DataSyncService: Lỗi trong quá trình pullCloudToLocal - $e");
    }
  }
}
