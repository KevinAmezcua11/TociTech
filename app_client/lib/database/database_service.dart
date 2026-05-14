import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'tocitech.db');
    return openDatabase(
      path,
      version: 2,
      onConfigure: _onConfigure,
      onCreate:    _onCreate,
      onUpgrade:   _onUpgrade,
    );
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await db.rawQuery('PRAGMA journal_mode=WAL');
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE session (
        id         INTEGER PRIMARY KEY,
        user_id    TEXT NOT NULL,
        username   TEXT,
        names      TEXT,
        lastnames  TEXT,
        email      TEXT,
        phone      TEXT,
        role       TEXT,
        token      TEXT NOT NULL,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE productos_cache (
        id          TEXT PRIMARY KEY,
        name        TEXT,
        description TEXT,
        price       REAL,
        cost        REAL,
        category    TEXT,
        brand       TEXT,
        model       TEXT,
        sku         TEXT,
        warranty    TEXT,
        status      TEXT,
        stock       INTEGER,
        min_stock   INTEGER,
        images      TEXT,
        specs       TEXT,
        cached_at   TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE carrito (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id       TEXT NOT NULL,
        product_id    TEXT NOT NULL,
        product_name  TEXT,
        product_price REAL,
        product_image TEXT,
        quantity      INTEGER DEFAULT 1,
        added_at      TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notificaciones (
        id         TEXT PRIMARY KEY,
        title      TEXT,
        message    TEXT,
        type       TEXT,
        leida      INTEGER DEFAULT 0,
        created_at TEXT,
        data       TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE servicios_cache (
        id          TEXT PRIMARY KEY,
        name        TEXT,
        description TEXT,
        price       REAL,
        duration    TEXT,
        image       TEXT,
        active      INTEGER DEFAULT 1,
        cached_at   TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        endpoint   TEXT NOT NULL,
        method     TEXT NOT NULL,
        body       TEXT,
        created_at TEXT
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_productos_category ON productos_cache (category)',
    );
    await db.execute(
      'CREATE INDEX idx_notificaciones_leida ON notificaciones (leida)',
    );
    await db.execute(
      'CREATE INDEX idx_carrito_product_id ON carrito (product_id)',
    );
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE carrito ADD COLUMN user_id TEXT');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_carrito_user_id ON carrito (user_id)',
      );
    }
  }
}
