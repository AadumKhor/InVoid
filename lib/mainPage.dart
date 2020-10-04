import 'dart:ffi';
import 'dart:io';
import 'package:image/image.dart' as I;
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoid/facePainter.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ImagePicker imagePicker = ImagePicker();
  final FirebaseVision firebaseVision = FirebaseVision.instance;

  File _imageFile;
  var imageFile;
  // CameraImage _cameraImage;
  List<Rect> rect = List<Rect>();
  bool isFaceDetected = false;
  bool isLoading = false;

  Future _launchImagePicker() async {
    final image = await imagePicker.getImage(
        source: ImageSource.gallery, preferredCameraDevice: CameraDevice.front);

    imageFile = await image.readAsBytes();
    imageFile = await decodeImageFromList(imageFile);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        imageFile = imageFile;
        isLoading = true;
        isFaceDetected = false;
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

    if (faces.length > 0) setState(() => isFaceDetected = true);
  }

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
      body: isLoading
          ? !isFaceDetected
              ? Center(child: CircularProgressIndicator())
              : Padding(
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
                          painter:
                              FacePainter(rect: rect, imageFile: imageFile),
                        ),
                      ),
                    ),
                  ))
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
