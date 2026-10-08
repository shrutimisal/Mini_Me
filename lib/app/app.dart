import 'package:flutter/material.dart';

import 'routes.dart';
import 'theme.dart';

class MiniMeApp extends StatelessWidget {
  const MiniMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiniMe',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: Routes.home,
      onGenerateRoute: Routes.generate,
    );
  }
}
