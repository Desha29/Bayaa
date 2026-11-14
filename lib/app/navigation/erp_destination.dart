import 'package:flutter/material.dart';

/// A destination describes presentation only; the shell owns selection state.
class ErpDestination {
  const ErpDestination(
      {required this.id,
      required this.icon,
      required this.title,
      required this.screen});
  final String id;
  final IconData icon;
  final String title;
  final Widget screen;
}
