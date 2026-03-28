import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  // بنستخدم FirebaseAuth مباشرة كـ Source of Truth للـ UID
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";
  final _box = GetStorage();
  late RxBool remember;


  @override
  Future<void> onInit() async {
    super.onInit();
    
    remember = ( await _box.read<bool>("remember") ?? false).obs; 
    
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      return userCredential;
    } catch (e) {
      Get.snackbar("خطأ", "فشل تسجيل الدخول");
      return null;
    }
  }

  //____________________________________________________________________
  Future<void> save() async {
    await _box.write("remember", remember.value);
  }
  //____________________________________________________________________
void toggleRemember() {
    remember.value = !remember.value;
  }
  //____________________________________________________________________
bool isRememberd (){
  return _box.read<bool>("remember") ?? false;
}   
}
