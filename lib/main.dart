import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:todo_app/Modules/HomePage/HomeScreen.dart';
import 'package:todo_app/Modules/todo/task_controller.dart';
import 'package:todo_app/Shared/Connectivity.dart';
import 'package:todo_app/auth/signwithgoogle.dart';
import 'auth/Auth_Controller.dart';
  
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp().timeout(const Duration(seconds: 5));
 
  Get.put(  TaskController());
  Get.put(  AuthController(),permanent: true);
  Get.put(ConnectivityController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final ctr = Get.find<AuthController>();
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: .fromSeed(seedColor: Colors.blue),
      ),
      home: ctr.isRememberd()?HomeView():Signwithgoogle(),
    );
  }
}
