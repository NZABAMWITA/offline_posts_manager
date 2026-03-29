import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/post.dart';

class DBHelper {
  // Single instance of DBHelper (Singleton pattern)
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  // Get database (create it if it doesn't exist yet)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('posts.db');
    return _database!;
  }

  // Initialize the database file
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create the posts table
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        body TEXT NOT NULL
      )
    ''');
  }

  // ─── CREATE ───────────────────────────────────────
  Future<int> insertPost(Post post) async {
    try {
      final db = await database;
      return await db.insert('posts', post.toMap());
    } catch (e) {
      throw Exception('Failed to insert post: $e');
    }
  }

  // ─── READ ALL ─────────────────────────────────────
  Future<List<Post>> getAllPosts() async {
    try {
      final db = await database;
      final result = await db.query('posts', orderBy: 'id DESC');
      return result.map((map) => Post.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  // ─── READ ONE ─────────────────────────────────────
  Future<Post?> getPost(int id) async {
    try {
      final db = await database;
      final result = await db.query('posts', where: 'id = ?', whereArgs: [id]);
      if (result.isNotEmpty) return Post.fromMap(result.first);
      return null;
    } catch (e) {
      throw Exception('Failed to fetch post: $e');
    }
  }

  // ─── UPDATE ───────────────────────────────────────
  Future<int> updatePost(Post post) async {
    try {
      final db = await database;
      return await db.update(
        'posts',
        post.toMap(),
        where: 'id = ?',
        whereArgs: [post.id],
      );
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  // ─── DELETE ───────────────────────────────────────
  Future<int> deletePost(int id) async {
    try {
      final db = await database;
      return await db.delete('posts', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // Close the database
  Future close() async {
    final db = await database;
    db.close();
  }
}
