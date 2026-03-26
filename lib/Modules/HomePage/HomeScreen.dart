import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todo_app/Modules/todo/task_controller.dart';

import '../../auth/signwithgoogle.dart';

// ══════════════════════════════════════════════════════════
//  الثوابت
// ══════════════════════════════════════════════════════════
const _kPrimary  = Color.fromARGB(255, 21, 84, 186);
const _kDark     = Color(0xff0D0D12);
const _kSurface  = Color(0xff1C1C1E);
const _kBorder   = Color(0xff2a2a3a);
const _kGreen    = Color(0xff1a7a4a);
const _kAccent   = Color.fromARGB(255, 188, 194, 24);

// ══════════════════════════════════════════════════════════
//  HomeView
// ══════════════════════════════════════════════════════════
class HomeView extends StatelessWidget {
  final TaskController        controller     = Get.put(TaskController());
  final TextEditingController titleController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // التاريخ المختار في الـ Bottom Sheet
  final Rx<DateTime> _selectedDate = DateTime.now().obs;

  // التبويب الحالي: 0 = pending, 1 = done
  final RxInt _tab = 0.obs;

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      backgroundColor: _kDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ──
            _buildHeader(),

            // ── Stats Row ──
            _buildStats(),

            // ── Tabs ──
            _buildTabs(),

            const SizedBox(height: 8),

            // ── List ──
            Expanded(child: _buildList()),
          ],
        ),
      ),

      // ── FAB ──
      floatingActionButton: _buildFab(context),
    );
  }

  // ─────────────────────────────────────────────
  //  Header
  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    final now = DateTime.now();
    final days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dayName = days[now.weekday - 1];
    final date    = '${now.day} ${months[now.month - 1]} ${now.year}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayName,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: GoogleFonts.lato(fontSize: 13, color: Colors.white38),
                ),
              ],
            ),
          ),

          // أيقونة زخرفية
          InkWell(
            onTap: () async {
               await _googleSignIn.signOut();
               Get.offAll(Signwithgoogle());
            },
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color       : _kPrimary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border      : Border.all(color: _kPrimary.withOpacity(0.3)),
              ),
              child: const Icon(Icons.logout, color: _kPrimary, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Stats
  // ─────────────────────────────────────────────
  Widget _buildStats() {
    return Obx(() {
      final total = controller.allTasks.length;
      final done  = controller.allTasks.where((t) => t.status == 1).length;
      final pct   = total == 0 ? 0.0 : done / total;

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Container(
          padding   : const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color       : _kSurface,
            borderRadius: BorderRadius.circular(16),
            border      : Border.all(color: _kBorder),
          ),
          child: Row(
            children: [
              // Progress circle
              SizedBox(
                width: 48, height: 48,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value          : pct,
                      strokeWidth    : 4,
                      backgroundColor: Colors.white12,
                      valueColor     : const AlwaysStoppedAnimation(_kPrimary),
                    ),
                    Center(
                      child: Text(
                        '${(pct * 100).round()}%',
                        style: GoogleFonts.lato(
                          color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$done of $total tasks completed',
                      style: GoogleFonts.lato(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value          : pct,
                        minHeight      : 4,
                        backgroundColor: Colors.white12,
                        valueColor     : const AlwaysStoppedAnimation(_kPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────
  //  Tabs
  // ─────────────────────────────────────────────
  Widget _buildTabs() {
    return Obx(() => Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _Tab(label: 'Pending', index: 0, current: _tab.value,
               onTap: () => _tab.value = 0),
          const SizedBox(width: 8),
          _Tab(label: 'Completed', index: 1, current: _tab.value,
               onTap: () => _tab.value = 1),
        ],
      ),
    ));
  }

  // ─────────────────────────────────────────────
  //  List
  // ─────────────────────────────────────────────
  Widget _buildList() {
    return Obx(() {
      final filtered = _tab.value == 0
          ? controller.allTasks.where((t) => t.status == 0).toList()
          : controller.allTasks.where((t) => t.status == 1).toList();

      if (filtered.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kPrimary.withOpacity(0.08),
                ),
                child: Icon(
                  _tab.value == 0
                      ? Icons.assignment_outlined
                      : Icons.check_circle_outline,
                  color: Colors.white12, size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _tab.value == 0 ? 'No pending tasks' : 'No completed tasks',
                style: GoogleFonts.playfairDisplay(color: Colors.white38, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                _tab.value == 0 ? 'Tap + to add a new task' : 'Complete tasks to see them here',
                style: GoogleFonts.lato(color: Colors.white24, fontSize: 13),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding         : const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount       : filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder     : (context, i) => _TaskCard(
          task      : filtered[i],
          controller: controller,
        ),
      );
    });
  }

  // ─────────────────────────────────────────────
  //  FAB
  // ─────────────────────────────────────────────
  Widget _buildFab(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddTaskSheet(context),
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color       : _kPrimary,
          shape       : BoxShape.circle,
          boxShadow   : [
            BoxShadow(
              color     : _kPrimary.withOpacity(0.4),
              blurRadius: 16,
              offset    : const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Bottom Sheet — Add Task
  // ─────────────────────────────────────────────
  void _showAddTaskSheet(BuildContext context) {
    _selectedDate.value = DateTime.now();
    titleController.clear();
    notesController.clear();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color       : _kSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'New Task',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Title field
            _SheetField(
              controller: titleController,
              hint      : 'Task title...',
              icon      : Icons.edit_outlined,
              autofocus : true,
            ),
            const SizedBox(height: 10),

           
            const SizedBox(height: 16),

            // Date picker
            Text(
              'DUE DATE',
              style: GoogleFonts.lato(
                color: Colors.white38, fontSize: 11,
                fontWeight: FontWeight.bold, letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),

            Obx(() => GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context   : Get.context!,
                  initialDate: _selectedDate.value,
                  firstDate : DateTime.now(),
                  lastDate  : DateTime.now().add(const Duration(days: 365)),
                  builder   : (context, child) => Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(primary: _kPrimary),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) _selectedDate.value = picked;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color       : _kDark,
                  borderRadius: BorderRadius.circular(12),
                  border      : Border.all(color: _kBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: _kPrimary, size: 16),
                    const SizedBox(width: 10),
                    Text(
                      _formatDate(_selectedDate.value),
                      style: GoogleFonts.lato(color: Colors.white70, fontSize: 14),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
                  ],
                ),
              ),
            )),

            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  if (titleController.text.trim().isNotEmpty) {
                    controller.addTask(
                      titleController.text.trim(),
                      _formatDate(_selectedDate.value),
                      
                    );
                    Get.back();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color       : _kPrimary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow   : [
                      BoxShadow(
                        color     : _kPrimary.withOpacity(0.3),
                        blurRadius: 12,
                        offset    : const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Save Task',
                      style: GoogleFonts.lato(
                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _formatDate(DateTime d) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[d.weekday-1]}, ${d.day} ${months[d.month-1]} ${d.year}';
  }
}

// ══════════════════════════════════════════════════════════
//  _TaskCard
// ══════════════════════════════════════════════════════════
class _TaskCard extends StatelessWidget {
  final dynamic       task;
  final TaskController controller;

  const _TaskCard({required this.task, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == 1;

    return Dismissible(
      key      : Key(task.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.deleteTask(task),
      background: Container(
        alignment   : Alignment.centerRight,
        padding     : const EdgeInsets.only(right: 20),
        decoration  : BoxDecoration(
          color       : Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border      : Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
      ),
      child: Container(
        padding   : const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color       : _kSurface,
          borderRadius: BorderRadius.circular(16),
          border      : Border.all(
            color: isDone ? _kGreen.withOpacity(0.3) : _kBorder,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Checkbox
            GestureDetector(
              onTap: () => controller.toggleTaskStatus(task),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24, height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color : isDone ? _kGreen : Colors.transparent,
                  border: Border.all(
                    color: isDone ? _kGreen : Colors.white38,
                    width: 2,
                  ),
                ),
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.playfairDisplay(
                      color     : isDone ? Colors.white38 : Colors.white,
                      fontSize  : 15,
                      fontWeight: FontWeight.w600,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.white38,
                    ),
                  ),

                  // Notes لو موجودة
                 /*  if (task.notes != null && task.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.notes!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(color: Colors.white38, fontSize: 12),
                    ),
                  ], */

                  const SizedBox(height: 6),

                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size : 11,
                        color: isDone ? Colors.white24 : _kPrimary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.date,
                        style: GoogleFonts.lato(
                          color   : isDone ? Colors.white24 : Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color       : isDone
                    ? _kGreen.withOpacity(0.12)
                    : _kPrimary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border      : Border.all(
                  color: isDone
                      ? _kGreen.withOpacity(0.3)
                      : _kPrimary.withOpacity(0.3),
                ),
              ),
              child: Text(
                isDone ? 'Done' : 'Pending',
                style: GoogleFonts.lato(
                  color    : isDone ? const Color(0xff4ade80) : _kAccent,
                  fontSize : 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  _Tab
// ══════════════════════════════════════════════════════════
class _Tab extends StatelessWidget {
  final String   label;
  final int      index, current;
  final VoidCallback onTap;

  const _Tab({
    required this.label, required this.index,
    required this.current, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == current;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color       : isSelected ? _kPrimary : _kSurface,
          borderRadius: BorderRadius.circular(20),
          border      : Border.all(
            color: isSelected ? _kPrimary : _kBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.lato(
            color     : isSelected ? Colors.white : Colors.white38,
            fontSize  : 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  _SheetField
// ══════════════════════════════════════════════════════════
class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String   hint;
  final IconData icon;
  final bool     autofocus;
  final int      maxLines;

  const _SheetField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.autofocus = false,
    this.maxLines  = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color       : _kDark,
        borderRadius: BorderRadius.circular(12),
        border      : Border.all(color: _kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Icon(icon, color: Colors.white38, size: 18),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus : autofocus,
              maxLines  : maxLines,
              style     : GoogleFonts.lato(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText      : hint,
                hintStyle     : GoogleFonts.lato(color: Colors.white24, fontSize: 14),
                border        : InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}