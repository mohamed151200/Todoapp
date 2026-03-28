import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_app/Modules/HomePage/HomeScreen.dart';
import 'package:todo_app/Modules/todo/task_controller.dart';
import 'Auth_Controller.dart';

// ══════════════════════════════════════════════════════════
const _kPrimary = Color.fromARGB(255, 21, 84, 186);
const _kDark    = Color(0xff0D0D12);
const _kSurface = Color(0xff1C1C1E);
const _kBorder  = Color(0xff2a2a3a);
// ══════════════════════════════════════════════════════════

class Signwithgoogle extends StatelessWidget {
  const Signwithgoogle({super.key});

  @override
  Widget build(BuildContext context) {
    final tctr = Get.find<TaskController>();
    final ctr  = Get.find<AuthController>();
    final RxBool isLoading = false.obs;

    return Scaffold(
      backgroundColor: _kDark,
      body: Stack(
        children: [

          // ── خلفية زخرفية ──
          _buildBackground(),

          // ── المحتوى ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Spacer(flex: 2),

                  // ── Logo / Icon ──
                  Container(
                    width : 64, height: 64,
                    decoration: BoxDecoration(
                      color       : _kPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                      border      : Border.all(color: _kPrimary.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: _kPrimary, size: 30,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── العنوان ──
                  Text(
                    'Get Things\nDone.',
                    style: GoogleFonts.playfairDisplay(
                      fontSize  : 42,
                      fontWeight: FontWeight.bold,
                      color     : Colors.white,
                      height    : 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Sign in to sync your tasks\nacross all your devices.',
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      color   : Colors.white38,
                      height  : 1.6,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ── Features ──
                  _FeatureRow(
                    icon : Icons.sync_rounded,
                    title: 'Sync across devices',
                    sub  : 'Your tasks, always up to date',
                  ),
                  const SizedBox(height: 12),
                  _FeatureRow(
                    icon : Icons.lock_outline_rounded,
                    title: 'Secure & private',
                    sub  : 'Powered by Google authentication',
                  ),
                  const SizedBox(height: 12),
                  _FeatureRow(
                    icon : Icons.bolt_rounded,
                    title: 'Instant access',
                    sub  : 'One tap and you\'re in',
                  ),

                  const Spacer(flex: 2),
                  Row(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Remember Me".tr,
                      style: GoogleFonts.lato(color: Colors.white70, fontSize: 11),
                    ),
                      Obx(()=>
                        Checkbox(
                          hoverColor: Colors.blue,
                          value: ctr.remember.value,
                          onChanged: (value) {
                            ctr.toggleRemember();
                            ctr.save();
                          },
                        ),
                      ),]),

                  // ── Sign In Button ──
                  Obx(() => GestureDetector(
                    onTap: isLoading.value ? null : () async {
                      isLoading.value = true;
                      try {
                        await ctr.signInWithGoogle();
                       await tctr.fullSync();
                        Get.offAll(() => HomeView());
                      } finally {
                        isLoading.value = false;
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width : double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color       : isLoading.value
                            ? _kSurface
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border      : Border.all(
                          color: isLoading.value ? _kBorder : Colors.transparent,
                        ),
                        boxShadow: isLoading.value ? [] : [
                          BoxShadow(
                            color     : Colors.white.withOpacity(0.1),
                            blurRadius: 20,
                            offset    : const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: isLoading.value
                          ? const Center(
                              child: SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor : AlwaysStoppedAnimation(_kPrimary),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Google G logo
                                
                                const SizedBox(width: 12),
                                Text(
                                  'Continue with Google',
                                  style: GoogleFonts.lato(
                                    color     : const Color(0xff1a1a1a),
                                    fontSize  : 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  )),

                  const SizedBox(height: 16),

                  // ── Terms ──
                  Center(
                    child: Text(
                      'By continuing, you agree to our Terms & Privacy Policy',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        color   : Colors.white24,
                        fontSize: 11,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── خلفية زخرفية ──
  Widget _buildBackground() {
    return Stack(
      children: [
        // دائرة كبيرة فوق اليمين
        Positioned(
          top: -80, right: -80,
          child: Container(
            width : 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(255, 242, 115, 196).withOpacity(0.06),
            ),
          ),
        ),
        // دائرة صغيرة فوق اليسار
        Positioned(
          top: 60, left: -40,
          child: Container(
            width : 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kPrimary.withOpacity(0.04),
            ),
          ),
        ),
        // gradient في الأسفل
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin  : Alignment.bottomCenter,
                end    : Alignment.topCenter,
                colors : [
                  _kPrimary.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
//  _FeatureRow
// ══════════════════════════════════════════════════════════
class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String   title, sub;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width : 40, height: 40,
          decoration: BoxDecoration(
            color       : _kPrimary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border      : Border.all(color: _kPrimary.withOpacity(0.15)),
          ),
          child: Icon(icon, color: _kPrimary, size: 18),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.lato(
                color     : Colors.white70,
                fontSize  : 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              sub,
              style: GoogleFonts.lato(color: Colors.white24, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
//  Google G Icon — مرسومة يدوياً بدون assets
// ══════════════════════════════════════════════════════════


