import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Prescription {
  final String diseaseKey;
  final String cropName;
  final String diseaseNameEn;
  final String diseaseNameMl;
  final String chemicalCure;
  final double dosagePerLiter;
  final String chemicalInstructionsMl;
  final String organicCure;
  final String organicInstructionsMl;
  final int waitingPeriodDays;

  Prescription({
    required this.diseaseKey,
    required this.cropName,
    required this.diseaseNameEn,
    required this.diseaseNameMl,
    required this.chemicalCure,
    required this.dosagePerLiter,
    required this.chemicalInstructionsMl,
    required this.organicCure,
    required this.organicInstructionsMl,
    required this.waitingPeriodDays,
  });

  factory Prescription.fromMap(Map<String, dynamic> map) {
    return Prescription(
      diseaseKey: map['disease_key'],
      cropName: map['crop_name'],
      diseaseNameEn: map['disease_name_en'],
      diseaseNameMl: map['disease_name_ml'],
      chemicalCure: map['chemical_cure'],
      dosagePerLiter: (map['dosage_per_liter'] as num).toDouble(),
      chemicalInstructionsMl: map['chemical_instructions_ml'],
      organicCure: map['organic_cure'],
      organicInstructionsMl: map['organic_instructions_ml'],
      waitingPeriodDays: map['waiting_period_days'] as int,
    );
  }
}

class PrescriptionRepository {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    var dbDir = await getDatabasesPath();
    var dbPath = join(dbDir, "agronomy_prescriptions.db");

    // Copy SQLite database from Flutter asset bundle to device filesystem on first launch
    bool exists = await databaseExists(dbPath);
    if (!exists) {
      ByteData data = await rootBundle.load("assets/database/agronomy_prescriptions.db");
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(dbPath, readOnly: true);
  }

  Future<Prescription?> getPrescription(String diseaseKey) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'Prescriptions',
      where: 'disease_key = ?',
      whereArgs: [diseaseKey],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return Prescription.fromMap(results.first);
    }
    return null;
  }
}