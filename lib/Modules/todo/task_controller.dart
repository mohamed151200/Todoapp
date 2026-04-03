import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
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
  final uid=FirebaseHelper.currentUid;
  ConnectivityController connectivityController = Get.put(
    ConnectivityController(),
  );
  final _box = GetStorage();
  int get lastSync => _box.read('lastSync_$uid') ?? 0;

  @override
  Future<void> onInit() async {
    _dbHelper.db;
    super.onInit();
    await fullSync(); 
  }

  Future<void> fetchTasks() async {
    try {
      var tasks = await _dbHelper.getAllTasks();
      allTasks.assignAll(tasks);
     // print(tasks);
    } catch (e) {
    //  print('____________________________${e}');
    }

  }

  void addTask(String title, String date, ) async {
    var uuid = const Uuid();
    final user = FirebaseAuth.instance.currentUser;
    //print('________________________${user!.uid}');
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
    allTasks.refresh();
  }

  void toggleTaskStatus(TaskModel task) async {
    task.status = (task.status == 0) ? 1 : 0;
    allTasks.refresh();
    task.timestamp = DateTime.now().millisecondsSinceEpoch;
    await _dbHelper.updateTask(task);
    if (connectivityController.isConnected.value) {
      await _fbHelper.addToCloud(task);
    }
  }

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
    allTasks.refresh();
  }

  Future<void> fullSync() async {
    final uid=FirebaseHelper.currentUid;
    await fetchTasks();

    if (connectivityController.isConnected.value && uid != null) {
      final int syncStartTime = DateTime.now().millisecondsSinceEpoch;
      final int lastSyncTime = lastSync;

      try {
        
        List<TaskModel> cloudTasks = await _fbHelper.fetchNewFromCloud(
          lastSyncTime,
        );
        for (var task in cloudTasks) {
          await _dbHelper.insertTask(task);
        }

        
        List<TaskModel> deletedTasks = await _dbHelper.getSoftDeletedTasks();
        for (var task in deletedTasks) {
          await _fbHelper.deleteFromCloud(task.id);
          await _dbHelper.deleteTask(
            task.id,
          ); 
        }

        
        List<TaskModel> localToUpload = allTasks
            .where((t) => t.timestamp > lastSyncTime && t.isDeleted == 0)
            .toList();

        for (var task in localToUpload) {
          await _fbHelper.addToCloud(task);
        }

       
       await _box.write('lastSync_$uid', syncStartTime);

        await fetchTasks();

        //print("Sync Finished: All clean and uploaded.");
      } catch (e) {
        //print("Sync Error: $e");
      }
    }
  }
}
