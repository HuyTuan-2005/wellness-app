import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wellness_app/features/medical/appointment/models/appointment.dart';
import 'package:wellness_app/features/medical/medication/models/medication.dart';
import 'package:wellness_app/features/health/weight/models/weight_record.dart';
import 'package:wellness_app/features/health/mental_health/models/mental_health.dart';

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
      version: 4,
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
    if (oldVersion < 3) {
      // Thêm trường userId và isSynced cho bảng medications
      await db.execute('ALTER TABLE medications ADD COLUMN userId TEXT');
      await db.execute('ALTER TABLE medications ADD COLUMN isSynced INTEGER DEFAULT 0');
      
      // Thêm trường userId và isSynced cho bảng appointments
      await db.execute('ALTER TABLE appointments ADD COLUMN userId TEXT');
      await db.execute('ALTER TABLE appointments ADD COLUMN isSynced INTEGER DEFAULT 0');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE mental_health_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          emotion TEXT NOT NULL,
          notes TEXT NOT NULL,
          dateTime TEXT NOT NULL,
          userId TEXT,
          isSynced INTEGER DEFAULT 0
        )
      ''');
    }
  }

  // Chạy lệnh SQL để tạo các bảng
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
        nextDoseDate TEXT,
        userId TEXT,
        isSynced INTEGER DEFAULT 0
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
        status TEXT NOT NULL,
        userId TEXT,
        isSynced INTEGER DEFAULT 0
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

    // 4. Bảng Sức khỏe tinh thần
    await db.execute('''
      CREATE TABLE mental_health_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        emotion TEXT NOT NULL,
        notes TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        userId TEXT,
        isSynced INTEGER DEFAULT 0
      )
    ''');
  }

  // ================= CÁC HÀM CHO ĐỒNG BỘ ĐÁM MÂY =================
  Future<List<Map<String, dynamic>>> getUnsyncedMedications() async {
    final db = await instance.database;
    return await db.query('medications', where: 'isSynced = ?', whereArgs: [0]);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedAppointments() async {
    final db = await instance.database;
    return await db.query('appointments', where: 'isSynced = ?', whereArgs: [0]);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedMentalHealthRecords() async {
    final db = await instance.database;
    return await db.query('mental_health_records', where: 'isSynced = ?', whereArgs: [0]);
  }

  Future<int> markAsSynced(String tableName, int id) async {
    final db = await instance.database;
    return await db.update(
      tableName,
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= CÁC HÀM CRUD CHO THUỐC =================
  Future<int> insertMedication(MedicationModel medication) async {
    final db = await instance.database;
    // Mặc định insert qua app là chưa đồng bộ (isSynced = 0)
    Map<String, dynamic> data = medication.toMap();
    data['isSynced'] = 0; 
    return await db.insert('medications', data);
  }

  Future<List<MedicationModel>> getAllMedications() async {
    final db = await instance.database;
    final result = await db.query('medications');
    return result.map((json) => MedicationModel.fromMap(json)).toList();
  }

  Future<int> updateMedication(MedicationModel medication) async {
    final db = await instance.database;
    Map<String, dynamic> data = medication.toMap();
    data['isSynced'] = 0; // Khi sửa thì phải đánh dấu để sync lại
    return await db.update(
      'medications',
      data,
      where: 'id = ?',
      whereArgs: [medication.id],
    );
  }

  Future<int> deleteMedication(int id) async {
    final db = await instance.database;
    return await db.delete('medications', where: 'id = ?', whereArgs: [id]);
  }

  // ================= CÁC HÀM CRUD CHO LỊCH HẸN =================
  Future<int> insertAppointment(AppointmentModel appointment) async {
    final db = await instance.database;
    Map<String, dynamic> data = appointment.toMap();
    data['isSynced'] = 0;
    return await db.insert('appointments', data);
  }

  Future<List<AppointmentModel>> getAllAppointments() async {
    final db = await instance.database;
    final result = await db.query('appointments', orderBy: 'dateTime ASC');
    return result.map((json) => AppointmentModel.fromMap(json)).toList();
  }

  Future<int> updateAppointment(AppointmentModel appointment) async {
    final db = await instance.database;
    Map<String, dynamic> data = appointment.toMap();
    data['isSynced'] = 0;
    return await db.update(
      'appointments',
      data,
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<int> deleteAppointment(int id) async {
    final db = await instance.database;
    return await db.delete('appointments', where: 'id = ?', whereArgs: [id]);
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

  // ================= CÁC HÀM CRUD CHO SỨC KHỎE TINH THẦN =================
  Future<int> insertMentalHealthRecord(MentalHealthRecord record) async {
    final db = await instance.database;
    Map<String, dynamic> data = record.toMap();
    data['isSynced'] = 0;
    return await db.insert('mental_health_records', data);
  }

  Future<List<MentalHealthRecord>> getAllMentalHealthRecords() async {
    final db = await instance.database;
    final result = await db.query('mental_health_records', orderBy: 'dateTime DESC');
    return result.map((json) => MentalHealthRecord.fromMap(json)).toList();
  }
}
