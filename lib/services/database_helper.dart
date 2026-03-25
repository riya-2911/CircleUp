import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 1,
      onCreate: _createDB,
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

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
