import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Food {
  final int? id;
  final String name;
  final int calories;
  final DateTime dateTime;
  final double? fat;
  final double? carbs;
  final double? protein;

  Food({
    this.id,
    required this.name,
    required this.calories,
    required this.dateTime,
    this.fat,
    this.carbs,
    this.protein,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'dateTime': dateTime.toIso8601String(),
      'fat': fat,
      'carbs': carbs,
      'protein': protein,
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

    try {
      return await openDatabase(
        path,
        version: 5, 
        onCreate: _createDB,
        onUpgrade: _upgradeDB, 
      );
    } catch (e) {
      throw Exception('Error initializing database: $e');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE foods(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories INTEGER NOT NULL,
        dateTime TEXT NOT NULL,
        fat REAL,
        carbs REAL,
        protein REAL
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    final tableInfo = await db.rawQuery('PRAGMA table_info(foods)');
    final hasFat = tableInfo.any((col) => col['name'] == 'fat');
    final hasCarbs = tableInfo.any((col) => col['name'] == 'carbs');
    final hasProtein = tableInfo.any((col) => col['name'] == 'protein');

    if (!hasFat) {
      await db.execute('ALTER TABLE foods ADD COLUMN fat REAL;');
    }
    if (!hasCarbs) {
      await db.execute('ALTER TABLE foods ADD COLUMN carbs REAL;');
    }
    if (!hasProtein) {
      await db.execute('ALTER TABLE foods ADD COLUMN protein REAL;');
    }
  }

  Future<void> insertFood(Food food) async {
    final db = await database;
    await db.insert('foods', food.toMap());
  }

  Future<List<Food>> getAllFoods() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'foods',
      orderBy: 'dateTime DESC'
    );
    
    return List.generate(maps.length, (i) {
      return Food(
        id: maps[i]['id'],
        name: maps[i]['name'],
        calories: maps[i]['calories'],
        dateTime: DateTime.parse(maps[i]['dateTime']),
        fat: maps[i]['fat'],
        carbs: maps[i]['carbs'],
        protein: maps[i]['protein'],
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
        fat: maps[i]['fat'],
        carbs: maps[i]['carbs'],
        protein: maps[i]['protein'],
      );
    });
  }

  Future<void> deleteFood(int id) async {
    final db = await database;
    await db.delete(
      'foods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateFood(Food food) async {
    final db = await database;
    await db.update(
      'foods',
      food.toMap(),
      where: 'id = ?',
      whereArgs: [food.id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}