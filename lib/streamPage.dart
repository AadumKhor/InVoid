import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:invoid/facePainter.dart';
import 'package:invoid/utils/utils.dart';

class StreamPage extends StatefulWidget {
  @override
  _StreamPageState createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> with WidgetsBindingObserver {
  List<CameraDescription> cameras = List<CameraDescription>();
  final FirebaseVision firebaseVision = FirebaseVision.instance;

  CameraController controller;
  bool isInitialized = false;
  Image imageFile;
  List<Rect> rect = List<Rect>();
  bool isFaceDetected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeCamera().then((value) {
      controller = CameraController(cameras.first, ResolutionPreset.low,
          enableAudio: false);
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          isInitialized = true;
        });
        _monitorFeed();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
  }

  Future<void> _monitorFeed() async {
    print('Monitoring feed');
    controller?.startImageStream((CameraImage image) async {
      _lookForFace(image);
      await Future.delayed(Duration(seconds: 3));
    });
  }

  Future<void> _lookForFace(CameraImage image) async {
    final FirebaseVisionImage firebaseVisionImage =
        FirebaseVisionImage.fromBytes(
            image.planes[0].bytes,
            FirebaseVisionImageMetadata(
                size: Size(image.width.toDouble(), image.height.toDouble()),
                rawFormat: {},
                planeData: []));
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

    if (faces.length > 0) setState(() => isFaceDetected = true);

    print('Face detected  : $isFaceDetected');

    if (isFaceDetected) {
      final temp = await convertYUV420toImageColor(image);
      if (temp != null)
        setState(() {
          imageFile = temp;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller.value.isInitialized
          ? !isFaceDetected
              ? AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: CameraPreview(controller),
                )
              : Container(
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
                )
          : CircularProgressIndicator(),
    );
  }
}
