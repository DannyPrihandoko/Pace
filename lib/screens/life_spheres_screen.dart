import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/sphere_provider.dart';
import '../models/sphere.dart';

class LifeSpheresScreen extends ConsumerWidget {
  const LifeSpheresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sphereProvider);
    final selectedSphere = state.selectedSphere;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Life Spheres',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // 1. Sphere Selector Component
          const SphereSelector(),
          const SizedBox(height: 20),
          // 2. Task List Component with Animated Switcher
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: TaskList(
                key: ValueKey(state.selectedSphereId),
                tasks: state.filteredTasks,
                accentColor: selectedSphere.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SphereSelector extends ConsumerWidget {
  const SphereSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sphereProvider);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.spheres.length,
        itemBuilder: (context, index) {
          final sphere = state.spheres[index];
          final isSelected = state.selectedSphereId == sphere.id;

          return GestureDetector(
            onTap: () => ref.read(sphereProvider.notifier).selectSphere(sphere.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? sphere.accentColor : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? sphere.accentColor : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sphere.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.2) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${state.getTaskCount(sphere.id)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  final List<SphereTask> tasks;
  final Color accentColor;

  const TaskList({
    super.key,
    required this.tasks,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return SphereTaskCard(task: task, accentColor: accentColor);
      },
    );
  }
}

class SphereTaskCard extends StatelessWidget {
  final SphereTask task;
  final Color accentColor;

  const SphereTaskCard({
    super.key,
    required this.task,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              task.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: accentColor.withOpacity(0.5)),
        ],
      ),
    );
  }
}
