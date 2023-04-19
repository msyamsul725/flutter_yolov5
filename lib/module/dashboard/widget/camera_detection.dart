import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ModelObjectDetection _objectModel;
  String? _imagePrediction;
  List? _prediction;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool objectDetection = false;
  List<ResultObjectDetection?> objDetect = [];
  bool firststate = false;
  bool message = true;
  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future loadModel() async {
    String pathObjectDetectionModel = "assets/models/best.torchscript";
    try {
      _objectModel = await FlutterPytorch.loadObjectDetectionModel(
          pathObjectDetectionModel, 2, 640, 640,
          labelPath: "assets/labels/android.txt");
    } catch (e) {
      if (e is PlatformException) {
        print("only supported for android, Error is $e");
      } else {
        print("Error is $e");
      }
    }
  }

  void handleTimeout() {
    // callback function
    // Do some work.
    setState(() {
      firststate = true;
    });
  }

  getDialogDetection() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Your order was placed!'),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Ok"),
            ),
          ],
        );
      },
    );
  }

  Timer scheduleTimeout([int milliseconds = 10000]) =>
      Timer(Duration(milliseconds: milliseconds), handleTimeout);
  //running detections on image
  Future runObjectDetection() async {
    setState(() {
      firststate = false;
      message = false;
    });
    //pick an image
    final XFile? image = await _picker.pickImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear);
    objDetect = await _objectModel.getImagePrediction(
        await File(image!.path).readAsBytes(),
        minimumScore: 0.1,
        IOUThershold: 0.3);
    for (var element in objDetect) {
      print({
        "score": element?.score,
        "className": element?.className,
        "class": element?.classIndex,
        "rect": {
          "left": element?.rect.left,
          "top": element?.rect.top,
          "width": element?.rect.width,
          "height": element?.rect.height,
          "right": element?.rect.right,
          "bottom": element?.rect.bottom,
        },
      });
    }
    scheduleTimeout(5 * 1000);
    setState(() {
      _image = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OBJECT DETECTOR APP")),
      backgroundColor: Colors.white,
      body: Center(
          child: Stack(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Image with Detections....

            !firststate
                ? !message
                    ? const CircularProgressIndicator()
                    : const Text("Select the Camera to Begin Detections")
                : Expanded(
                    child: Container(
                        child: _objectModel.renderBoxesOnImage(
                            _image!, objDetect)),
                  ),

            // !firststate
            //     ? LoaderState()
            //     : Expanded(
            //         child: Container(
            //             height: 150,
            //             width: 300,
            //             child: objDetect.isEmpty
            //                 ? Text("hello")
            //                 : _objectModel.renderBoxesOnImage(
            //                     _image!, objDetect)),
            //       ),
            Center(
              child: Visibility(
                visible: _imagePrediction != null,
                child: Text("$_imagePrediction"),
              ),
            ),
            //Button to click pic
            ElevatedButton(
              onPressed: () {
                runObjectDetection();
              },
              child: const Icon(Icons.camera),
            )
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Card(
            child: ListView.builder(
              itemCount: objDetect.length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              clipBehavior: Clip.none,
              itemBuilder: (context, index) {
                var item = objDetect[index];
                var persen = item!.score * 100;
                getDialogDetection();
                return ListTile(
                  leading: const Icon(
                    Icons.camera,
                    size: 24.0,
                  ),
                  title: Text("${item.className}  $persen %"),
                );
              },
            ),
          ),
        )
      ])),
    );
  }
}
