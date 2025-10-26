import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import './item_model.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventory.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE stock(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        quantity INTEGER,
        price REAL,
        imagePath TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE stock ADD COLUMN imagePath TEXT');
    }
  }


  Future<int> insertItem(Map<String, dynamic> item) async {
    final db = await database;
    return await db.insert('stock', item);
  }

  // READ
  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await database;
    return await db.query('stock');
  }

  // UPDATE
  Future<int> updateItem(Map<String, dynamic> item) async {
    final db = await database;
    return await db.update(
      'stock',
      item,
      where: 'id = ?',
      whereArgs: [item['id']],
    );
  }

  // DELETE
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'stock',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
