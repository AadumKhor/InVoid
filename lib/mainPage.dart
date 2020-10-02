import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoid/facePainter.dart';

// typedef convert_func = Pointer<Uint32> Function(
//     Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, Int32, Int32, Int32, Int32);
// typedef Convert = Pointer<Uint32> Function(
//     Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int, int, int, int);

class MainPage extends StatefulWidget {
  // final List<CameraDescription> cameras;

  // MainPage(this.cameras) : super();

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  // List<CameraDescription> cameras = List<CameraDescription>();
  final ImagePicker imagePicker = ImagePicker();
  final FirebaseVision firebaseVision = FirebaseVision.instance;

  File _imageFile;
  var imageFile;
  // CameraImage _cameraImage;
  List<Rect> rect = List<Rect>();
  bool isFaceDetected = false;
  CameraController controller;
  bool isInitialized = false;

  // final DynamicLibrary convertImageLib = Platform.isAndroid
  //     ? DynamicLibrary.open("libconvertImage.so")
  //     : DynamicLibrary.process();
  // Convert conv;

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  // on new Camera selected if needed from their example app

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // initializeCamera().then((value) {
    //   controller = CameraController(cameras.first, ResolutionPreset.medium);
    //   controller.initialize().then((_) {
    //     if (!mounted) {
    //       return;
    //     }
    //     setState(() {
    //       isInitialized = true;
    //     });
    //     // _monitorFeed();
    //   });
    // });
    // conv = convertImageLib
    //     .lookup<NativeFunction<convert_func>>('convertImage')
    //     .asFunction<Convert>();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
  }

  // Future<void> initializeCamera() async {
  //   cameras = await availableCameras();
  // }

  Future _launchImagePicker() async {
    final image = await imagePicker.getImage(
        source: ImageSource.gallery, preferredCameraDevice: CameraDevice.front);

    imageFile = await image.readAsBytes();
    imageFile = await decodeImageFromList(imageFile);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        imageFile = imageFile;
      });
    } else {
      print('No image selected');
      return;
    }

    FirebaseVisionImage firebaseVisionImage =
        FirebaseVisionImage.fromFile(_imageFile);
    final FaceDetector faceDetector =
        firebaseVision.faceDetector(FaceDetectorOptions());
    final List<Face> faces =
        await faceDetector.processImage(firebaseVisionImage);

    if (rect.length > 0) {
      rect = List<Rect>();
    }

    for (Face face in faces) {
      rect.add(face.boundingBox);
    }

    setState(() {
      isFaceDetected = true;
    });
  }

  // Future<void> _monitorFeed() async {
  //   print('Monitoring feed');
  //   controller?.startImageStream((CameraImage image) {
  //     setState(() {
  //       _cameraImage = image;
  //     });
  //     // print(_cameraImage.planes[0].bytes.length.toString());
  //     Uint8List byteList;
  //     try {
  //       _cameraImage.planes.forEach((element) {
  //         byteList = Uint8List.fromList(element.bytes);
  //       });
  //     } catch (e) {
  //       print('Error with byteList $e');
  //     }
  //     // I.Image i = I.decodeImage(byteList);
  //     setState(() {
  //       _imageFile = File.fromRawPath(byteList);
  //     });
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
      body: isFaceDetected
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(blurRadius: 20),
                  ],
                ),
                child: FittedBox(
                  child: SizedBox(
                    width: imageFile.width.toDouble(),
                    height: imageFile.height.toDouble(),
                    child: CustomPaint(
                      painter: FacePainter(rect: rect, imageFile: imageFile),
                    ),
                  ),
                ),
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
        onPressed: _launchImagePicker,
      ),
    );
  }
}
