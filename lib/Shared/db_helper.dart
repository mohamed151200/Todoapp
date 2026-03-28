import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo_app/Shared/fb_halper.dart';
import '../modules/todo/task_model.dart'; // تأكد من المسار صح

class DbHelper {
  // 1. Singleton Pattern: عشان نضمن وجود نسخة واحدة فقط من الكلاس
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    //print("--- Initializing Database ---");
    _db = await _initDb();
    return _db!;
  }

  // 2. Create: إنشاء الداتابيز والجدول
  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'todo_tasks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
       // print("--- Creating Tables ---");
        await db.execute('''
  CREATE TABLE tasks (
    id TEXT PRIMARY KEY,  
    title TEXT,
    userId TEXT,                  
    date TEXT,                  
    timestamp INTEGER,        
    status INTEGER,            
    isDeleted INTEGER      
  )
''');
      },
    );
  }

  // 3. Insert: إضافة مهمة جديدة
  Future<void> insertTask(TaskModel task) async {
    try {
      Database dbClient = await db;
      // بنحول الـ Object لـ Map عشان SQL بيفهم Maps بس
      await dbClient.insert(
        'tasks',
        task.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
     // print('_____________________${e}');
    }
  }

  // 4. Read (Get): قراءة كل المهام
  Future<List<TaskModel>> getAllTasks() async {
    final uid=FirebaseHelper.currentUid;
    Database dbClient = await db;
    // بنجيب الداتا مرتبة حسب الـ Timestamp (الأحدث فوق)
    try {
      List<Map<String, dynamic>> maps = await dbClient.query(
        'tasks',
      where: 'userId = ? AND isDeleted = ?',
      whereArgs: [uid, 0],
      );

      // بنحول الـ List of Maps لـ List of Objects عشان الـ UI
      return maps.isNotEmpty
          ? maps.map((task) => TaskModel.fromJson(task)).toList()
          : [];
    } catch (e) {
     // print('_____________________${e}');
      return [];
    }
  }

  // 5. Update: تعديل مهمة (أو تغيير الحالة لـ Done)
Future<void> updateTask(TaskModel task) async {
    Database dbClient = await db;
    try {
      await dbClient.update(
        'tasks',
        task.toJson(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
    //  print('___________________${e}');
      0;
    }
    0;
  }

  // 6. Delete: مسح مهمة
  Future<void> deleteTask(String id) async {
    try {
      Database dbClient = await db;
      await dbClient.delete('tasks', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      0;
     // print('______________________${e}');
    }
  }

Future<List<TaskModel>> getSoftDeletedTasks() async {
  try {
    Database dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query(
      'tasks',
      where: 'isDeleted = ?',
      whereArgs: [1],
    );

    return maps.map((task) => TaskModel.fromJson(task)).toList();
  } catch (e) {
   // print('Error fetching deleted tasks: $e');
    return [];
  }
}}
