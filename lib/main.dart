import 'package:flutter/material.dart';
import 'package:invoid/selectionPage.dart';
import 'package:invoid/utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InVoid',
      theme: InVoidTheme.theme,
      home: SelectionPage(),
    );
  }
}
