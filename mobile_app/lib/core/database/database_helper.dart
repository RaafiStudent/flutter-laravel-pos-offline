import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton Pattern
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kasir_pintar.db');
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
    // 1. Tabel User (Untuk menyimpan sesi login offline)
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY,
      name TEXT,
      email TEXT,
      token TEXT
    )
    ''');

    // 2. Tabel Categories
    // ID tidak Auto Increment karena harus SAMA dengan MySQL
    await db.execute('''
    CREATE TABLE categories (
      id INTEGER PRIMARY KEY, 
      name TEXT,
      image TEXT
    )
    ''');

    // 3. Tabel Products
    // ID tidak Auto Increment karena harus SAMA dengan MySQL
    await db.execute('''
    CREATE TABLE products (
      id INTEGER PRIMARY KEY,
      category_id INTEGER,
      name TEXT,
      sku TEXT,
      price REAL,
      stock INTEGER,
      image TEXT
    )
    ''');

    // 4. Tabel Orders (Transaksi)
    // is_synced: 0 = Belum Upload, 1 = Sudah Upload
    await db.execute('''
    CREATE TABLE orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      transaction_code TEXT,
      total_amount REAL,
      payment_amount REAL,
      change_amount REAL,
      payment_method TEXT,
      transaction_date TEXT,
      user_id INTEGER,
      is_synced INTEGER DEFAULT 0
    )
    ''');

    // 5. Tabel Order Items (Detail Transaksi)
    await db.execute('''
    CREATE TABLE order_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      order_id INTEGER,
      product_id INTEGER,
      quantity INTEGER,
      price REAL
    )
    ''');
  }

  // --- Helper Methods (Nanti kita isi CRUD di sini) ---
  
  // Method untuk menghapus database (Hanya untuk debugging jika struktur salah)
  Future<void> deleteDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'kasir_pintar.db');
    await deleteDatabase(path);
  }
}