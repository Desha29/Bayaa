import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'app/bayaa_app.dart';
import 'app/bootstrap/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setup();
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const BayaaApp(),
    ),
  );
}
