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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.blue),
      ),
      home: ctr.isRememberd()?HomeView():Signwithgoogle(),
    );
  }
}
