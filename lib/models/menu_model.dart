import 'package:flutter/material.dart';

class MenuItem {
  final String id;
  final String label;
  final IconData icon;
  final String description;

  MenuItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.description,
  });
}