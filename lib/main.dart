import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:invoid/theme.dart';

import 'mainPage.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InVoid',
      theme: InVoidTheme.theme,
      home: MainPage(),
    );
  }
}
