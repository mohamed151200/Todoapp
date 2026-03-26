import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  // بنستخدم FirebaseAuth مباشرة كـ Source of Truth للـ UID
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential;
    } catch (e) {
      Get.snackbar("خطأ", "فشل تسجيل الدخول");
      return null;
    }
  }
}