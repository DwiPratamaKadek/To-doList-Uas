import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todolist/model/checkbox_model.dart';
import 'package:todolist/model/note_model.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todolist.db');
    // Uncomment the following line to delete the old database for testing
    // await deleteDatabase(path);
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE titles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        deskripsi TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE checkboxes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titleId INTEGER,
        title TEXT,
        isChecked INTEGER,
        FOREIGN KEY (titleId) REFERENCES titles(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertTitle(TitleModel title) async {
    Database db = await database;
    return await db.insert('titles', title.toMap());
  }

  Future<int> updateTitle(TitleModel title) async {
    Database db = await database;
    return await db.update('titles', title.toMap(),
        where: 'id = ?', whereArgs: [title.id]);
  }

  Future<int> insertCheckbox(CheckboxModel checkbox) async {
    Database db = await database;
    return await db.insert('checkboxes', checkbox.toMap());
  }

  Future<int> updateCheckbox(CheckboxModel checkbox) async {
    Database db = await database;
    return await db.update('checkboxes', checkbox.toMap(),
        where: 'id = ?', whereArgs: [checkbox.id]);
  }

  Future<List<TitleModel>> getTitles() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('titles');
    return List.generate(maps.length, (i) {
      return TitleModel.fromMap(maps[i]);
    });
  }

  Future<List<CheckboxModel>> getCheckboxes(int titleId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db
        .query('checkboxes', where: 'titleId = ?', whereArgs: [titleId]);
    return List.generate(maps.length, (i) {
      return CheckboxModel.fromMap(maps[i]);
    });
  }

  Future<void> deleteTitle(int id) async {
    Database db = await database;
    await db.delete(
      'titles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteCheckbox(int id) async {
    Database db = await database;
    await db.delete(
      'checkboxes',
      where: 'titleId = ?',
      whereArgs: [id],
    );
  }

}
