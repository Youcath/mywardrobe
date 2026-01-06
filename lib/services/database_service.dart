import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/clothing_item.dart';

class DatabaseService {
  static Database? _database;
  static const String tableName = 'clothes';
  static const String outfitsTableName = 'outfits';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wardrobe.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            category TEXT,
            image_path TEXT,
            tags TEXT
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
      },
    );
  }

  /// 衣物 CRUD 操作
  static Future<int> addClothing(ClothingItem item) async {
    final db = await database;
    return await db.insert(tableName, item.toMap());
  }

  static Future<List<ClothingItem>> getClothingItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) => ClothingItem.fromMap(maps[i]));
  }

  static Future<List<ClothingItem>> getClothingByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'category = ?',
      whereArgs: [category],
    );
    return List.generate(maps.length, (i) => ClothingItem.fromMap(maps[i]));
  }

  static Future<int> deleteClothing(int id) async {
    final db = await database;
    // 首先获取图片路径以便删除物理文件
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
        print('删除图片文件失败: $e');
      }
    }
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 穿搭 CRUD 操作
  static Future<int> addOutfit(Map<String, dynamic> outfitMap) async {
    final db = await database;
    return await db.insert(outfitsTableName, outfitMap, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getAllOutfits() async {
    final db = await database;
    return await db.query(outfitsTableName);
  }

  static Future<int> deleteOutfit(int id) async {
    final db = await database;
    return await db.delete(
      outfitsTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 图片路径管理 (持久化存储)
  static Future<String> saveImagePermanently(String tempPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${extension(tempPath)}';
    final permanentPath = join(directory.path, fileName);
    
    final tempFile = File(tempPath);
    final permanentFile = await tempFile.copy(permanentPath);
    
    return permanentFile.path;
  }
}
