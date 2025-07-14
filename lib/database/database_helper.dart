import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/contact.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal() {
    // デスクトップ環境でのSQLite初期化
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'address_book.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone_number TEXT,
        email TEXT,
        postal_code TEXT,
        address TEXT,
        company TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE contacts ADD COLUMN postal_code TEXT');
    }
  }

  // 連絡先を追加
  Future<int> insertContact(Contact contact) async {
    final db = await database;
    return await db.insert('contacts', contact.toMap());
  }

  // 全ての連絡先を取得
  Future<List<Contact>> getAllContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  // IDで連絡先を取得
  Future<Contact?> getContact(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    }
    return null;
  }

  // 連絡先を更新
  Future<int> updateContact(Contact contact) async {
    final db = await database;
    return await db.update(
      'contacts',
      contact.toMapForUpdate(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  // 連絡先を削除
  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 名前で検索
  Future<List<Contact>> searchContactsByName(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  // 複数の条件で検索
  Future<List<Contact>> searchContacts(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: '''
        name LIKE ? OR
        phone_number LIKE ? OR
        email LIKE ? OR
        postal_code LIKE ? OR
        address LIKE ? OR
        company LIKE ?
      ''',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  // データベースを閉じる
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // データベースを削除（テスト用）
  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'address_book.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}