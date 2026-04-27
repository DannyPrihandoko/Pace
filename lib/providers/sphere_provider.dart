import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sphere.dart';

class SphereState {
  final List<Sphere> spheres;
  final List<SphereTask> allTasks;
  final String selectedSphereId;

  SphereState({
    required this.spheres,
    required this.allTasks,
    required this.selectedSphereId,
  });

  List<SphereTask> get filteredTasks => 
      allTasks.where((task) => task.sphereId == selectedSphereId).toList();
  
  Sphere get selectedSphere => 
      spheres.firstWhere((s) => s.id == selectedSphereId);

  int getTaskCount(String sphereId) =>
      allTasks.where((task) => task.sphereId == sphereId).length;
}

class SphereNotifier extends StateNotifier<SphereState> {
  SphereNotifier() : super(SphereState(
    spheres: [
      Sphere(id: '1', name: 'Pekerjaan', accentColor: const Color(0xFF1E3A8A)),
      Sphere(id: '2', name: 'Turnamen', accentColor: const Color(0xFFC2410C)),
      Sphere(id: '3', name: 'Kesehatan & Personal', accentColor: const Color(0xFF0F766E)),
    ],
    allTasks: [
      SphereTask(id: 't1', title: 'Pengembangan Dashboard Admin POS F&B', sphereId: '1'),
      SphereTask(id: 't2', title: 'Rapat Mingguan Tim Teknis', sphereId: '1'),
      SphereTask(id: 't3', title: 'Analisis Matchup Deck 3v3', sphereId: '2'),
      SphereTask(id: 't4', title: 'Latihan Rutin', sphereId: '2'),
      SphereTask(id: 't5', title: 'Jalan 10.000 Langkah', sphereId: '3'),
      SphereTask(id: 't6', title: 'Jurnal Harian', sphereId: '3'),
    ],
    selectedSphereId: '1',
  ));

  void selectSphere(String id) {
    state = SphereState(
      spheres: state.spheres,
      allTasks: state.allTasks,
      selectedSphereId: id,
    );
  }
}

final sphereProvider = StateNotifierProvider<SphereNotifier, SphereState>((ref) {
  return SphereNotifier();
});
