import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart'; // Import واحد يشمل كل حاجة في GetX
import 'package:todo_app/Shared/db_helper.dart';
import 'package:todo_app/Shared/fb_halper.dart';
import 'package:todo_app/modules/todo/task_model.dart';
import 'package:uuid/uuid.dart';
import '../../Shared/Connectivity.dart';
import 'package:get_storage/get_storage.dart';

class TaskController extends GetxController {
  var allTasks = <TaskModel>[].obs;
  final DbHelper _dbHelper = DbHelper();
  final FirebaseHelper _fbHelper = FirebaseHelper.instance;
  ConnectivityController connectivityController = Get.put(
    ConnectivityController(),
  );
  final _box = GetStorage();
  int get lastSync => _box.read('lastSync') ?? 0;

  @override
  void onInit() {
    _dbHelper.db;
    super.onInit();
    fullSync(); // بننادي ميثود التحميل هنا
  }

  // 1. ميثود جلب البيانات من الداتابيز
  Future<void> fetchTasks() async {
    try {
      var tasks = await _dbHelper.getAllTasks();
      allTasks.assignAll(tasks);
      print(tasks);
    } catch (e) {
      print('____________________________${e}');
    }

    // assignAll أحسن من value= لأنها بتعمل refresh أوتوماتيك
  }

  // 2. ميثود إضافة تاسك جديدة
  void addTask(String title, String date, ) async {
    var uuid = const Uuid();
    final user = FirebaseAuth.instance.currentUser;
    print('________________________${user!.uid}');
    String uniqueId = uuid.v4();
    TaskModel newTask = TaskModel(
      userId: user!.uid,
      title: title,
      date: date,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      status: 0,
      id: uniqueId,
    );

    _dbHelper.insertTask(newTask);
    if (connectivityController.isConnected.value) {
      _fbHelper.addToCloud(newTask);
    }
    allTasks.add(newTask);
    allTasks.refresh(); // بنضيفها لليستة عشان تظهر في الـ UI فوراً
  }

  // 3. ميثود الـ Toggle (كودك الممتاز مع تبسيط صغير)
  void toggleTaskStatus(TaskModel task) async {
    task.status = (task.status == 0) ? 1 : 0;
    allTasks.refresh();
    task.timestamp = DateTime.now().millisecondsSinceEpoch;
    await _dbHelper.updateTask(task);
    if (connectivityController.isConnected.value) {
      await _fbHelper.addToCloud(task);
    }
  }

  // 4. ميثود المسح
  void deleteTask(TaskModel task) async {
    final last_Sync = lastSync;
    try {
      if (connectivityController.isConnected.value) {
        _dbHelper.deleteTask(task.id);
        _fbHelper.deleteFromCloud(task.id);
      } else if (task.timestamp > last_Sync) {
        _dbHelper.deleteTask(task.id);
      } else {
        task.isDeleted = 1;
        // task.timestamp=DateTime.now().millisecondsSinceEpoch;

        _dbHelper.updateTask(task);
      }
    } catch (e) {
      Get.snackbar('خطا', '${e}');
    }

    allTasks.remove(task);
    allTasks.refresh(); // بتمسحها من الرام بناءً على الـ Reference
  }

  Future<void> fullSync() async {
    await fetchTasks(); // عرض أولي سريع

    if (connectivityController.isConnected.value) {
      final int syncStartTime = DateTime.now().millisecondsSinceEpoch;
      final int lastSyncTime = lastSync;

      try {
        // 1. سحب الجديد من السحاب (Pull)
        List<TaskModel> cloudTasks = await _fbHelper.fetchNewFromCloud(
          lastSyncTime,
        );
        for (var task in cloudTasks) {
          await _dbHelper.insertTask(task);
        }

        // 2. تنظيف الممسوحات (Delete Cleanup) - الأولوية للمسح
        List<TaskModel> deletedTasks = await _dbHelper.getSoftDeletedTasks();
        for (var task in deletedTasks) {
          await _fbHelper.deleteFromCloud(task.id);
          await _dbHelper.deleteTask(
            task.id,
          ); // Hard Delete محلي بعد نجاح المسح سحابياً
        }

        // 3. رفع الجديد والمعدل (Push) - فقط اللي مش ممسوح
        List<TaskModel> localToUpload = allTasks
            .where((t) => t.timestamp > lastSyncTime && t.isDeleted == 0)
            .toList();

        for (var task in localToUpload) {
          await _fbHelper.addToCloud(task);
        }

        // 4. تحديث الوقت النهائي والرام
        await _box.write('lastSync', syncStartTime);
        await fetchTasks();

        print("Sync Finished: All clean and uploaded.");
      } catch (e) {
        print("Sync Error: $e");
      }
    }
  }
}
