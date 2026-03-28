import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_app/modules/todo/task_model.dart';

class FirebaseHelper {
  FirebaseHelper._();
  static final FirebaseHelper instance = FirebaseHelper._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> deleteFromCloud(String id) async {
    final uid = currentUid;
    try {
      _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(id)
          .delete();
    } catch (e) {
      0;
    }
  }

  Future<void> addToCloud(TaskModel task) async {
    final uid = currentUid;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(task.id)
          .set(task.toJson(), SetOptions(merge: true));
    } catch (e) {
      0;
    }
  }

  Future<List<TaskModel>> fetchNewFromCloud(int lastSync) async {
    final uid = currentUid;
    

    if (uid == null) return [];

    try {
      // 1. استعلام الفلترة بالوقت
      QuerySnapshot query = await _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .where('timestamp', isLessThan: lastSync)
          .get();

      // 2. التحويل من QueryDocumentSnapshot إلى TaskModel
      List<TaskModel> newTasks = query.docs.map((doc) {
        // بنحول الـ Map اللي جاية من فايربيز لـ Object باستخدام الـ Factory اللي في الموديل
        return TaskModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
       //print('___________________${newTasks}');
      return newTasks;
    } catch (e) {
     // print("Error in fetchNewFromCloud: $e");
      return [];
    }
  }
}
