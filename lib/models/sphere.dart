import 'package:flutter/material.dart';

class Sphere {
  final String id;
  final String name;
  final Color accentColor;

  Sphere({
    required this.id,
    required this.name,
    required this.accentColor,
  });
}

class SphereTask {
  final String id;
  final String title;
  final String sphereId;

  SphereTask({
    required this.id,
    required this.title,
    required this.sphereId,
  });
}
