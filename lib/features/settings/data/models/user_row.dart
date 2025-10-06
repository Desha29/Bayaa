import 'package:flutter/material.dart';

class UserRow {
  UserRow({
    required this.name,
    required this.email,
    required this.roleLabel,
    required this.roleTint,
    required this.roleColor,
    required this.active,
    required this.lastLogin,
  });

  final String name;
  final String email;
  final String roleLabel;
  final Color roleTint;
  final Color roleColor;
  final bool active;
  final String lastLogin;
}
