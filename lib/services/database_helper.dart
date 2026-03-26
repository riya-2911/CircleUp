  // --- POSTS CRUD ---
  Future<void> insertPost(UserPostModel post) async {
    final db = await instance.database;
    await db.insert('posts', post.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<UserPostModel>> getAllPosts() async {
    final db = await instance.database;
    final result = await db.query('posts', orderBy: 'createdAt DESC');
    return result.map((e) => UserPostModel.fromMap(e)).toList();
  }

  Future<List<UserPostModel>> getPostsByUser(String userId) async {
    final db = await instance.database;
    final result = await db.query('posts', where: 'userId = ?', whereArgs: [userId], orderBy: 'createdAt DESC');
    return result.map((e) => UserPostModel.fromMap(e)).toList();
  }

  Future<void> clearPosts() async {
    final db = await instance.database;
    await db.delete('posts');
  }
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/profile_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('circleup.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';

    await db.execute('''
CREATE TABLE messages (
  _id $idType,
  connectionId $textType,
  senderId $textType,
  content $textType,
  timestamp $integerType,
  isRead $boolType
)
''');

    await db.execute('''
CREATE TABLE connections (
  _id $idType,
  otherUserId $textType,
  otherUserName $textType,
  intentId $textType,
  timestamp $integerType
)
''');

    await db.execute('''
CREATE TABLE user_profiles (
  userId $idType,
  fullName $textType,
  gender TEXT,
  age INTEGER,
  personality TEXT,
  city TEXT,
  collegeOrProfession $textType,
  shortBio TEXT,
  interests $textType,
  photoPath TEXT,
  updatedAt $integerType
)
''');

    await db.execute('''
CREATE TABLE posts (
  id $idType,
  userId $textType,
  authorName $textType,
  content $textType,
  createdAt $integerType
)
''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
CREATE TABLE IF NOT EXISTS user_profiles (
  userId TEXT PRIMARY KEY,
  fullName TEXT NOT NULL,
  gender TEXT,
  age INTEGER,
  personality TEXT,
  city TEXT,
  collegeOrProfession TEXT NOT NULL,
  shortBio TEXT,
  interests TEXT NOT NULL,
  photoPath TEXT,
  updatedAt INTEGER NOT NULL
)
''');
    }

    if (oldVersion < 3) {
      // Add newly introduced profile columns for existing installs.
      try {
        await db.execute('ALTER TABLE user_profiles ADD COLUMN gender TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE user_profiles ADD COLUMN age INTEGER');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE user_profiles ADD COLUMN personality TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE user_profiles ADD COLUMN city TEXT');
      } catch (_) {}
    }

    if (oldVersion < 4) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS posts (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        authorName TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt INTEGER NOT NULL
      )
      ''');
    }
  }

  Future<void> insertMessage(Map<String, dynamic> message) async {
    final db = await instance.database;
    await db.insert('messages', message, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getMessages(String connectionId) async {
    final db = await instance.database;
    return await db.query(
      'messages',
      where: 'connectionId = ?',
      whereArgs: [connectionId],
      orderBy: 'timestamp ASC',
    );
  }

  Future<void> upsertUserProfile(ProfileModel profile) async {
    final db = await instance.database;
    try {
      await db.insert(
        'user_profiles',
        profile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DatabaseException {
      // Older local DBs may miss newly added columns; patch schema then retry.
      await _ensureUserProfileColumns(db);
      await db.insert(
        'user_profiles',
        profile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> _ensureUserProfileColumns(Database db) async {
    final tableInfo = await db.rawQuery('PRAGMA table_info(user_profiles)');
    final existingColumns = tableInfo
        .map((row) => (row['name'] ?? '').toString())
        .where((name) => name.isNotEmpty)
        .toSet();

    if (!existingColumns.contains('gender')) {
      await db.execute('ALTER TABLE user_profiles ADD COLUMN gender TEXT');
    }
    if (!existingColumns.contains('age')) {
      await db.execute('ALTER TABLE user_profiles ADD COLUMN age INTEGER');
    }
    if (!existingColumns.contains('personality')) {
      await db.execute('ALTER TABLE user_profiles ADD COLUMN personality TEXT');
    }
    if (!existingColumns.contains('city')) {
      await db.execute('ALTER TABLE user_profiles ADD COLUMN city TEXT');
    }
  }

  Future<ProfileModel?> getUserProfile(String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'user_profiles',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return ProfileModel.fromMap(result.first);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
