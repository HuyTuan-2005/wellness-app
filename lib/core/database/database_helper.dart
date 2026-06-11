import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wellness_app/features/appointment/models/appointment.dart';
import 'package:wellness_app/features/medication/models/medication.dart';
import 'package:wellness_app/features/weight/models/weight_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('wellness_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE weight_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          weight REAL NOT NULL,
          date TEXT NOT NULL
        )
      ''');
    }
  }

  // Chạy lệnh SQL để tạo 2 bảng cho phần của bạn
  Future _createDB(Database db, int version) async {
    // 1. Bảng Thuốc
    await db.execute('''
      CREATE TABLE medications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        time TEXT NOT NULL,
        frequency TEXT NOT NULL,
        durationDays INTEGER NOT NULL,
        totalQuantity INTEGER NOT NULL,
        takenQuantity INTEGER NOT NULL,
        notes TEXT,
        status TEXT NOT NULL,
        startDate TEXT NOT NULL,
        lastTakenDate TEXT,
        nextDoseDate TEXT
      )
    ''');

    // 2. Bảng Lịch hẹn
    await db.execute('''
      CREATE TABLE appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        doctorName TEXT NOT NULL,
        location TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        reminderOffset INTEGER NOT NULL,
        notes TEXT,
        status TEXT NOT NULL
      )
    ''');

    // 3. Bảng Cân nặng
    await db.execute('''
      CREATE TABLE weight_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // ================= CÁC HÀM CRUD CHO THUỐC =================
  Future<int> insertMedication(MedicationModel medication) async {
    final db = await instance.database;
    return await db.insert('medications', medication.toMap());
  }

  Future<List<MedicationModel>> getAllMedications() async {
    final db = await instance.database;
    final result = await db.query('medications');
    return result.map((json) => MedicationModel.fromMap(json)).toList();
  }

  // ================= CÁC HÀM CRUD CHO LỊCH HẸN =================
  Future<int> insertAppointment(AppointmentModel appointment) async {
    final db = await instance.database;
    return await db.insert('appointments', appointment.toMap());
  }

  Future<List<AppointmentModel>> getAllAppointments() async {
    final db = await instance.database;
    final result = await db.query('appointments', orderBy: 'dateTime ASC');
    return result.map((json) => AppointmentModel.fromMap(json)).toList();
  }

  Future<int> updateAppointment(AppointmentModel appointment) async {
    final db = await instance.database;
    return await db.update(
      'appointments',
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<int> deleteAppointment(int id) async {
    final db = await instance.database;
    return await db.delete('appointments', where: 'id = ?', whereArgs: [id]);
  }

  // Cập nhật trạng thái và số lượng thuốc đã uống
  Future<int> updateMedication(MedicationModel medication) async {
    final db = await instance.database;
    return await db.update(
      'medications',
      medication.toMap(),
      where: 'id = ?',
      whereArgs: [medication.id],
    );
  }

  // Hàm xóa lịch uống thuốc
  Future<int> deleteMedication(int id) async {
    final db = await instance.database;
    return await db.delete('medications', where: 'id = ?', whereArgs: [id]);
  }

  // ================= CÁC HÀM CRUD CHO CÂN NẶNG =================
  Future<int> insertWeightRecord(WeightRecord record) async {
    final db = await instance.database;
    return await db.insert('weight_records', record.toMap());
  }

  Future<List<WeightRecord>> getAllWeightRecords() async {
    final db = await instance.database;
    final result = await db.query('weight_records', orderBy: 'date ASC');
    return result.map((json) => WeightRecord.fromMap(json)).toList();
  }
}
