import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Food {
  final int? id;
  final String name;
  final int calories;
  final DateTime dateTime;

  Food({
    this.id,
    required this.name,
    required this.calories,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'dateTime': dateTime.toIso8601String(),
    };
  }
}

class FoodDatabase {
  static final FoodDatabase instance = FoodDatabase._init();
  static Database? _database;

  FoodDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('food.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE foods(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories INTEGER NOT NULL,
        dateTime TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertFood(Food food) async {
    final db = await database;
    await db.insert('foods', food.toMap());
  }

  Future<List<Food>> getAllFoods() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('foods');
    
    return List.generate(maps.length, (i) {
      return Food(
        id: maps[i]['id'],
        name: maps[i]['name'],
        calories: maps[i]['calories'],
        dateTime: DateTime.parse(maps[i]['dateTime']),
      );
    });
  }

  Future<List<Food>> getFoodsByDate(DateTime date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'foods',
      where: 'dateTime LIKE ?',
      whereArgs: ['${date.toIso8601String().substring(0, 10)}%'],
    );

    return List.generate(maps.length, (i) {
      return Food(
        id: maps[i]['id'],
        name: maps[i]['name'],
        calories: maps[i]['calories'],
        dateTime: DateTime.parse(maps[i]['dateTime']),
      );
    });
  }
}