import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MainPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  MainPage(this.cameras) : super();

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  // List<CameraDescription> cameras = List<CameraDescription>();
  final ImagePicker imagePicker = ImagePicker();
  final FirebaseVision firebaseVision = FirebaseVision.instance;

  File _imageFile;
  List<Rect> rect = List<Rect>();
  bool isFaceDetected = true;
  CameraController controller;

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        // showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    // try {
    await controller.initialize();
    // } on CameraException catch (e) {
    //   _showCameraException(e);
    // }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller =
        CameraController(this.widget.cameras.first, ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller.description);
      }
    }
  }

  // Future _launchImagePicker() async {
  //   final image = await imagePicker.getImage(
  //       source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);

  //   if (image != null) {
  //     setState(() {
  //       _imageFile = File(image.path);
  //     });
  //   } else {
  //     print('No image selected');
  //     return;
  //   }

  //   FirebaseVisionImage firebaseVisionImage =
  //       FirebaseVisionImage.fromFile(_imageFile);
  //   final FaceDetector faceDetector =
  //       firebaseVision.faceDetector(FaceDetectorOptions());
  //   final List<Face> faces =
  //       await faceDetector.processImage(firebaseVisionImage);

  //   if (rect.length > 0) {
  //     rect = List<Rect>();
  //   }

  //   for (Face face in faces) {
  //     rect.add(face.boundingBox);

  //     final double rotY = face.headEulerAngleY;
  //     final double rotZ = face.headEulerAngleZ;
  //   }

  //   setState(() {
  //     isFaceDetected = true;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return Scaffold(
      backgroundColor: _theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: _theme.primaryColor,
        title: Text(
          'InVoid',
          style: _theme.textTheme.headline1.copyWith(color: Colors.white),
        ),
      ),
      body: (controller.value.isInitialized)
          ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller),
              ),
          )
          : Container(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _theme.buttonColor,
        child: Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 20.0,
        ),
        onPressed: () {},
      ),
    );
  }
}
