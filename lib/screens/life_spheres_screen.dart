import 'dart:math' show pi, cos, sin, min;
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
    
    // Safety check if no spheres are loaded
    if (state.spheres.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Life Spheres',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Belum ada Sphere.',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final selectedSphere = state.selectedSphere;

    // Mocking values based on task counts for the visualization
    // In a real app, this would be `sphere.points` mapped from SQLite gamification
    final values = state.spheres.map((s) {
      // Example logic: 1 task = 25 points, max 100
      return min(100.0, state.getTaskCount(s.id) * 25.0);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Life Spheres',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            color: Colors.black,
            letterSpacing: 1.5,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: Colors.black, height: 2.0), // Flat appbar border
        ),
      ),
      body: Column(
        children: [
          // 1. 2D Flat Spider Chart Visualization
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFDBEAFE), // Light pastel blue flat background
              border: Border(bottom: BorderSide(color: Colors.black, width: 3.0)),
            ),
            child: CustomPaint(
              size: const Size(double.infinity, 220),
              painter: SpiderChartPainter(
                spheres: state.spheres,
                values: values,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 2. Flat Sphere Selector
          const SphereSelector(),
          
          const SizedBox(height: 16),
          
          // 3. Flat Task List
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
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

class SpiderChartPainter extends CustomPainter {
  final List<Sphere> spheres;
  final List<double> values;

  SpiderChartPainter({required this.spheres, required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (spheres.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 36; // Padding for labels
    final angleStep = (2 * pi) / spheres.length;

    // A. Draw Web Background (Flat Polygon Rings)
    final webPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    final webFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw concentric polygons (3 levels)
    for (int i = 3; i >= 1; i--) {
      final path = Path();
      final r = radius * (i / 3);
      for (int j = 0; j < spheres.length; j++) {
        final angle = j * angleStep - pi / 2;
        final x = center.dx + r * cos(angle);
        final y = center.dy + r * sin(angle);
        if (j == 0) path.moveTo(x, y);
        else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, webFillPaint); // Solid white fill inside
      canvas.drawPath(path, webPaint);     // Hard black border
    }

    // Draw connecting spokes
    for (int j = 0; j < spheres.length; j++) {
      final angle = j * angleStep - pi / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(x, y), webPaint);
    }

    // B. Draw Data Polygon (Pure Color Overlap)
    final dataPath = Path();
    for (int j = 0; j < spheres.length; j++) {
      final angle = j * angleStep - pi / 2;
      // Clamp at 0.1 so even 0 values are slightly visible and maintain the shape
      final val = (values[j] / 100.0).clamp(0.1, 1.0); 
      final r = radius * val;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (j == 0) dataPath.moveTo(x, y);
      else dataPath.lineTo(x, y);
    }
    dataPath.close();

    // Solid vivid color with Multiply blend mode for pure flat overlapping effect
    final dataFillPaint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(0.9) // Bright Blue
      ..blendMode = BlendMode.multiply
      ..style = PaintingStyle.fill;

    final dataStrokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.miter;

    canvas.drawPath(dataPath, dataFillPaint);
    canvas.drawPath(dataPath, dataStrokePaint);
    
    // Draw thick dots at data points
    final dotPaint = Paint()
      ..color = const Color(0xFFFEF08A) // Pastel yellow
      ..style = PaintingStyle.fill;
      
    final dotStrokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int j = 0; j < spheres.length; j++) {
      final angle = j * angleStep - pi / 2;
      final val = (values[j] / 100.0).clamp(0.1, 1.0);
      final r = radius * val;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      
      canvas.drawCircle(Offset(x, y), 6, dotPaint);
      canvas.drawCircle(Offset(x, y), 6, dotStrokePaint);
    }

    // C. Draw Labels (Bold Flat Fonts)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int j = 0; j < spheres.length; j++) {
      final angle = j * angleStep - pi / 2;
      // Push label outside the radius
      final r = radius + 24; 
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);

      // Add a white background box behind text for maximum 2D flat contrast
      textPainter.text = TextSpan(
        text: spheres[j].name.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Colors.black,
          letterSpacing: 1.0,
        ),
      );
      
      textPainter.layout();
      
      // Draw strict black-bordered white box behind text
      final textRect = Rect.fromCenter(
        center: Offset(x, y), 
        width: textPainter.width + 12, 
        height: textPainter.height + 8
      );
      
      canvas.drawRect(textRect, Paint()..color = Colors.white);
      canvas.drawRect(
        textRect, 
        Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.0
      );
      
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SpiderChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.spheres != spheres;
  }
}

class SphereSelector extends ConsumerWidget {
  const SphereSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sphereProvider);

    return Container(
      height: 44,
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
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? sphere.accentColor : Colors.white,
                borderRadius: BorderRadius.circular(4), // Flat sharp radius
                border: Border.all(
                  color: Colors.black, // Hard black border
                  width: 2.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sphere.name.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : Colors.black,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      '${state.getTaskCount(sphere.id)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
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
    if (tasks.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3.0),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'BELUM ADA TASK',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Colors.black,
              letterSpacing: 1.5,
            ),
          ),
        ),
      );
    }
    
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6), // Flat radius
        border: Border.all(color: Colors.black, width: 2.0), // Hard border
      ),
      child: Row(
        children: [
          // Flat colored box instead of a pill shape
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: accentColor,
              border: Border.all(color: Colors.black, width: 2.0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              task.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF08A), // Pastel yellow action box
              border: Border.all(color: Colors.black, width: 2.0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.arrow_forward, color: Colors.black, size: 16),
          ),
        ],
      ),
    );
  }
}
