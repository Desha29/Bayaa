import 'package:flutter/material.dart';
import 'app/bayaa_app.dart';
import 'app/bootstrap/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setup();
  runApp(const BayaaApp());
}
