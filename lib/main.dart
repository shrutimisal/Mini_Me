import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/services/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppServices.init();
  runApp(const MiniMeApp());
}
