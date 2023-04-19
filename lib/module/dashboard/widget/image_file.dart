import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hyper_ui/core.dart';
import 'dart:io';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:just_audio/just_audio.dart';

class ImageFile extends StatefulWidget {
  const ImageFile({super.key});

  @override
  State<ImageFile> createState() => _ImageFileState();
}

class _ImageFileState extends State<ImageFile> {
  late ModelObjectDetection _objectModel;
  String? _imagePrediction;
  String? nameDetection = '';
  List? _prediction;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool objectDetection = false;
  List<ResultObjectDetection?> objDetect = [];
  bool firststate = false;
  bool message = true;
  // AudioPlayer audioPlayer = AudioPlayer();
  final storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    loadModel();
    getAudio();
  }

  AudioPlayer audioPlayer = AudioPlayer();
  getAudio() async {
    await audioPlayer.setAsset('assets/audio/pig.mp3');
  }

  playAudio() async {
    await audioPlayer.play();
    getAudio();
  }

  Future loadModel() async {
    String pathObjectDetectionModel = "assets/models/telur.torchscript";
    // await audioPlayer.setAsset('assets/audio/pig.mp3');
    try {
      _objectModel = await FlutterPytorch.loadObjectDetectionModel(
          pathObjectDetectionModel, 2, 640, 640,
          labelPath: "assets/labels/telur.txt");
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

  getFirebase(String name) async {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection("object_detection")
        .where('name', isEqualTo: name)
        .get();
    print("cek lagii $name");
    if (documentSnapshot.docs.isNotEmpty) {
      final data = documentSnapshot.docs;
      for (var i = 0; i < data.length; i++) {
        var item = data[i];

        await showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Info Terdeteksi'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(' Nama : ${item['name']}'),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Image.network(
                      "${item['photo']}",
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text(' Deskripsi :'),
                    Text(' ${item['description']}'),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("detail"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
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

      print('cek lagiii ${['name']}');
      await audioPlayer.play();

      // Lakukan operasi yang Anda inginkan dengan data
    } else {
      print('Dokumen tidak ditemukan atau data null.');
    }

    scheduleTimeout(3 * 1000);
    update();
  }

  List<Map<String, dynamic>> objectsData = [];
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
        source: ImageSource.gallery, preferredCameraDevice: CameraDevice.rear);
    objDetect = await _objectModel.getImagePrediction(
        await File(image!.path).readAsBytes(),
        minimumScore: 0.1,
        IOUThershold: 0.3);
    for (var element in objDetect) {
      nameDetection = element!.className;

      getFirebase(element.className!);

      print({
        "score": element.score,
        "className": element.className,
        "class": element.classIndex,
        "rect": {
          "left": element.rect.left,
          "top": element.rect.top,
          "width": element.rect.width,
          "height": element.rect.height,
          "right": element.rect.right,
          "bottom": element.rect.bottom,
        },
      });
    }

    scheduleTimeout(1 * 1000);
    // nameDetection = objDetect[0]!.className;
    // print("nama : $nameDetection");

    setState(() {
      _image = File(image.path);
    });

    // if (objDetect[0]!.className != null) {
    //   final documentSnapshot = await FirebaseFirestore.instance
    //       .collection("object_detection")
    //       .where('name', isEqualTo: "android")
    //       .get();

    //   print("object nyaaa ${objDetect[0]!.className}");
    //   if (documentSnapshot.docs.isNotEmpty) {
    //     final data = documentSnapshot.docs;
    //     print('object ${data[0]['name']}');
    //     // Lakukan operasi yang Anda inginkan dengan data
    //   } else {
    //     print('Dokumen tidak ditemukan atau data null.');
    //   }
    // }
    // await getDialogDetection(nameDetection!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OBJECT DETECTOR APP"),
        backgroundColor: const Color.fromARGB(255, 238, 118, 5),
      ),
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
                    : Text("Select the File to $nameDetection")
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
              child: const Icon(Icons.folder),
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

                return ListTile(
                  leading: const Icon(
                    Icons.camera,
                    size: 24.0,
                  ),
                  title:
                      Text("${item.className}  $persen %  ${item.rect.left}"),
                );
              },
            ),
          ),
        ),
      ])),
    );
  }
}
