import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cycle.dart';
import '../models/daily_log.dart';
import '../models/user_settings.dart';
import 'web_storage.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  // Web storage cache
  UserSettings _webSettings = const UserSettings(onboardingCompleted: false);
  final List<Cycle> _webCycles = [];
  final Map<String, DailyLog> _webLogs = {};

  AppDatabase._init() {
    if (kIsWeb) {
      _initWeb();
    }
  }

  void _initWeb() {
    try {
      final rawSettings = getWebStorage('monthly_settings');
      if (rawSettings != null) {
        final decoded = jsonDecode(rawSettings) as Map<String, dynamic>;
        _webSettings = UserSettings.fromMap(decoded);
      }

      final rawCycles = getWebStorage('monthly_cycles');
      if (rawCycles != null) {
        final decoded = jsonDecode(rawCycles) as List<dynamic>;
        _webCycles.clear();
        for (final item in decoded) {
          _webCycles.add(Cycle.fromMap(item as Map<String, dynamic>));
        }
      } else {
        _webCycles.add(
          Cycle(
            startDate: DateTime.now().subtract(const Duration(days: 13)),
            periodLength: 5,
            cycleLength: 28,
          ),
        );
      }

      final rawLogs = getWebStorage('monthly_logs');
      if (rawLogs != null) {
        final decoded = jsonDecode(rawLogs) as Map<String, dynamic>;
        _webLogs.clear();
        decoded.forEach((key, val) {
          final logMap = val as Map<String, dynamic>;
          final symptomsList = (logMap['symptoms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
          _webLogs[key] = DailyLog.fromMap(logMap, symptoms: symptomsList);
        });
      }
    } catch (_) {}
  }

  void _persistWeb() {
    try {
      saveWebStorage('monthly_settings', jsonEncode(_webSettings.toMap()));
      saveWebStorage('monthly_cycles', jsonEncode(_webCycles.map((c) => c.toMap()).toList()));
      final logsMap = <String, dynamic>{};
      _webLogs.forEach((key, log) {
        final map = log.toMap();
        map['symptoms'] = log.symptoms;
        logsMap[key] = map;
      });
      saveWebStorage('monthly_logs', jsonEncode(logsMap));
    } catch (_) {}
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('monthly.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE daily_logs ADD COLUMN medication INTEGER NOT NULL DEFAULT 0;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE daily_logs ADD COLUMN supplements INTEGER NOT NULL DEFAULT 0;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE daily_logs ADD COLUMN workout INTEGER NOT NULL DEFAULT 0;');
      } catch (_) {}
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. User Settings Table
    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        default_cycle_length INTEGER NOT NULL DEFAULT 28,
        default_period_length INTEGER NOT NULL DEFAULT 5,
        luteal_phase_length INTEGER NOT NULL DEFAULT 14,
        app_lock_enabled INTEGER NOT NULL DEFAULT 0,
        pin_hash TEXT,
        biometric_enabled INTEGER NOT NULL DEFAULT 0,
        disguise_mode_enabled INTEGER NOT NULL DEFAULT 0,
        panic_hide_enabled INTEGER NOT NULL DEFAULT 1,
        notifications_enabled INTEGER NOT NULL DEFAULT 1,
        period_reminder_days_before INTEGER DEFAULT 3,
        daily_log_reminder_time TEXT DEFAULT '21:00',
        theme_mode TEXT NOT NULL DEFAULT 'system',
        onboarding_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Insert initial default settings row
    await db.insert('user_settings', const UserSettings().toMap());

    // 2. Cycles Table
    await db.execute('''
      CREATE TABLE cycles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_date TEXT NOT NULL UNIQUE,
        end_date TEXT,
        cycle_length INTEGER,
        period_length INTEGER,
        is_predicted INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 3. Daily Logs Table
    await db.execute('''
      CREATE TABLE daily_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        log_date TEXT NOT NULL UNIQUE,
        flow_intensity TEXT,
        mood TEXT,
        pain_level INTEGER NOT NULL DEFAULT 0,
        energy_level INTEGER NOT NULL DEFAULT 3,
        medication INTEGER NOT NULL DEFAULT 0,
        supplements INTEGER NOT NULL DEFAULT 0,
        workout INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 4. Daily Symptoms Table
    await db.execute('''
      CREATE TABLE daily_symptoms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        daily_log_id INTEGER NOT NULL REFERENCES daily_logs(id) ON DELETE CASCADE,
        symptom_key TEXT NOT NULL,
        severity INTEGER DEFAULT 1
      )
    ''');

    // 5. Tracker Entries Table
    await db.execute('''
      CREATE TABLE tracker_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        daily_log_id INTEGER NOT NULL REFERENCES daily_logs(id) ON DELETE CASCADE,
        tracker_type TEXT NOT NULL,
        name TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 1,
        value TEXT
      )
    ''');
  }

  // --- User Settings Methods ---
  Future<UserSettings> getSettings() async {
    if (kIsWeb) return _webSettings;

    final db = await instance.database;
    final maps = await db.query('user_settings', limit: 1);
    if (maps.isNotEmpty) {
      return UserSettings.fromMap(maps.first);
    }
    return const UserSettings();
  }

  Future<int> updateSettings(UserSettings settings) async {
    if (kIsWeb) {
      _webSettings = settings;
      _persistWeb();
      return 1;
    }

    final db = await instance.database;
    return await db.update(
      'user_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [settings.id ?? 1],
    );
  }

  // --- Cycles Methods ---
  Future<List<Cycle>> getAllCycles() async {
    if (kIsWeb) return List.unmodifiable(_webCycles);

    final db = await instance.database;
    final maps = await db.query('cycles', orderBy: 'start_date ASC');
    return maps.map((m) => Cycle.fromMap(m)).toList();
  }

  Future<int> insertCycle(Cycle cycle) async {
    if (kIsWeb) {
      _webCycles.add(cycle);
      _persistWeb();
      return _webCycles.length;
    }

    final db = await instance.database;
    return await db.insert(
      'cycles',
      cycle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- Daily Log Methods ---
  Future<DailyLog?> getDailyLog(DateTime date) async {
    final dateStr = date.toIso8601String().split('T').first;
    if (kIsWeb) return _webLogs[dateStr];

    final db = await instance.database;
    final maps = await db.query(
      'daily_logs',
      where: 'log_date = ?',
      whereArgs: [dateStr],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final logId = maps.first['id'] as int;
    final symptomsData = await db.query(
      'daily_symptoms',
      where: 'daily_log_id = ?',
      whereArgs: [logId],
    );
    final symptoms = symptomsData.map((s) => s['symptom_key'] as String).toList();

    return DailyLog.fromMap(maps.first, symptoms: symptoms);
  }

  Future<void> saveDailyLog(DailyLog log) async {
    final dateStr = log.logDate.toIso8601String().split('T').first;
    if (kIsWeb) {
      _webLogs[dateStr] = log;
      _persistWeb();
      return;
    }

    final db = await instance.database;
    await db.transaction((txn) async {
      final existing = await txn.query(
        'daily_logs',
        where: 'log_date = ?',
        whereArgs: [dateStr],
        limit: 1,
      );

      int logId;
      if (existing.isNotEmpty) {
        logId = existing.first['id'] as int;
        await txn.update(
          'daily_logs',
          log.toMap(),
          where: 'id = ?',
          whereArgs: [logId],
        );
        await txn.delete(
          'daily_symptoms',
          where: 'daily_log_id = ?',
          whereArgs: [logId],
        );
        await txn.delete(
          'tracker_entries',
          where: 'daily_log_id = ?',
          whereArgs: [logId],
        );
      } else {
        logId = await txn.insert('daily_logs', log.toMap());
      }

      for (final symptom in log.symptoms) {
        await txn.insert('daily_symptoms', {
          'daily_log_id': logId,
          'symptom_key': symptom,
          'severity': 1,
        });
      }

      if (log.medication) {
        await txn.insert('tracker_entries', {
          'daily_log_id': logId,
          'tracker_type': 'medication',
          'name': 'Medication',
          'is_completed': 1,
        });
      }
      if (log.supplements) {
        await txn.insert('tracker_entries', {
          'daily_log_id': logId,
          'tracker_type': 'supplement',
          'name': 'Supplements',
          'is_completed': 1,
        });
      }
      if (log.workout) {
        await txn.insert('tracker_entries', {
          'daily_log_id': logId,
          'tracker_type': 'workout',
          'name': 'Workout',
          'is_completed': 1,
        });
      }
    });
  }

  Future<void> deleteDailyLog(DateTime date) async {
    final dateStr = date.toIso8601String().split('T').first;
    if (kIsWeb) {
      _webLogs.remove(dateStr);
      _persistWeb();
      return;
    }

    final db = await instance.database;
    await db.transaction((txn) async {
      final existing = await txn.query(
        'daily_logs',
        where: 'log_date = ?',
        whereArgs: [dateStr],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        final logId = existing.first['id'] as int;
        await txn.delete('daily_symptoms', where: 'daily_log_id = ?', whereArgs: [logId]);
        await txn.delete('tracker_entries', where: 'daily_log_id = ?', whereArgs: [logId]);
        await txn.delete('daily_logs', where: 'id = ?', whereArgs: [logId]);
      }
    });
  }

  Future<List<DailyLog>> getAllDailyLogs() async {
    if (kIsWeb) {
      final list = _webLogs.values.toList();
      list.sort((a, b) => a.logDate.compareTo(b.logDate));
      return list;
    }

    final db = await instance.database;
    final logsMaps = await db.query('daily_logs', orderBy: 'log_date ASC');
    final List<DailyLog> result = [];
    for (final map in logsMaps) {
      final logId = map['id'] as int;
      final symptomsData = await db.query(
        'daily_symptoms',
        where: 'daily_log_id = ?',
        whereArgs: [logId],
      );
      final symptoms = symptomsData.map((s) => s['symptom_key'] as String).toList();
      result.add(DailyLog.fromMap(map, symptoms: symptoms));
    }
    return result;
  }

  Future<List<DailyLog>> getDailyLogsForRange(DateTime start, DateTime end) async {
    if (kIsWeb) {
      return _webLogs.values.where((l) => !l.logDate.isBefore(start) && !l.logDate.isAfter(end)).toList();
    }

    final db = await instance.database;
    final startStr = start.toIso8601String().split('T').first;
    final endStr = end.toIso8601String().split('T').first;

    final logsMaps = await db.query(
      'daily_logs',
      where: 'log_date >= ? AND log_date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'log_date ASC',
    );

    final List<DailyLog> result = [];
    for (final map in logsMaps) {
      final logId = map['id'] as int;
      final symptomsData = await db.query(
        'daily_symptoms',
        where: 'daily_log_id = ?',
        whereArgs: [logId],
      );
      final symptoms = symptomsData.map((s) => s['symptom_key'] as String).toList();
      result.add(DailyLog.fromMap(map, symptoms: symptoms));
    }
    return result;
  }
}
