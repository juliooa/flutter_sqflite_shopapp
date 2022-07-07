import 'package:path/path.dart';
import 'package:shop_sqlite/models.dart';
import 'package:sqflite/sqflite.dart';

class ShopDatabase {
  static final ShopDatabase instance = ShopDatabase._init();

  static Database? _database;

  ShopDatabase._init();

  final String tableCartItems = 'cart_items';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('shop.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _onCreateDB);
  }

  Future _onCreateDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $tableCartItems(
    id INTEGER PRIMARY KEY,
    name TEXT,
    price INTEGER,
    quantity INTEGER
    )
    ''');
  }

  Future<void> insert(CartItem item) async {
    final db = await instance.database;
    await db.insert(tableCartItems, item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CartItem>> getAllItems() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableCartItems);

    return List.generate(maps.length, (i) {
      return CartItem(
        id: maps[i]['id'],
        name: maps[i]['name'],
        price: maps[i]['price'],
        quantity: maps[i]['quantity'],
      );
    });
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableCartItems,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> update(CartItem item) async {
    final db = await instance.database;
    return await db.update(
      tableCartItems,
      item.toMap(),
      where: "id=?",
      whereArgs: [item.id],
    );
  }
}
