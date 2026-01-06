import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/clothing_item.dart';

class DatabaseHelper {
  // 单例模式
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const String tableName = 'clothes';
  static const String outfitsTableName = 'outfits';
  static const String wearLogTableName = 'wear_log';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wardrobe.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            category TEXT,
            image_path TEXT,
            tags TEXT,
            color_value INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE $outfitsTableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            category TEXT,
            clothing_item_ids TEXT,
            created_date TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE $wearLogTableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            outfit_id INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $wearLogTableName(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT,
              outfit_id INTEGER
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE $tableName ADD COLUMN color_value INTEGER');
        }
      },
    );
  }

  /// 插入衣服
  Future<int> insertItem(ClothingItem item) async {
    final db = await database;
    return await db.insert(tableName, item.toMap());
  }

  /// 查询所有衣服
  Future<List<ClothingItem>> queryAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) => ClothingItem.fromMap(maps[i]));
  }

  /// 删除衣服
  Future<int> deleteItem(int id) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      final imagePath = maps[0]['image_path'] as String;
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // ignore
      }
    }

    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 更新衣服信息
  Future<int> updateItem(ClothingItem item) async {
    final db = await database;
    return await db.update(
      tableName,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // 辅助方法：按分类查询
  Future<List<ClothingItem>> getClothingByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'category = ?',
      whereArgs: [category],
    );
    return List.generate(maps.length, (i) => ClothingItem.fromMap(maps[i]));
  }

  // 穿搭相关操作
  Future<int> addOutfit(Map<String, dynamic> outfitMap) async {
    final db = await database;
    return await db.insert(outfitsTableName, outfitMap, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllOutfits() async {
    final db = await database;
    return await db.query(outfitsTableName);
  }

  Future<int> deleteOutfit(int id) async {
    final db = await database;
    return await db.delete(
      outfitsTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 穿搭日历相关操作
  Future<int> insertWearLog(String date, int outfitId) async {
    final db = await database;
    return await db.insert(wearLogTableName, {
      'date': date,
      'outfit_id': outfitId,
    });
  }

  Future<List<Map<String, dynamic>>> getWearLogs() async {
    final db = await database;
    return await db.query(wearLogTableName);
  }

  Future<int> deleteWearLog(int id) async {
    final db = await database;
    return await db.delete(wearLogTableName, where: 'id = ?', whereArgs: [id]);
  }
}
