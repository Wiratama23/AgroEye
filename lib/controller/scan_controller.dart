import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class ScanController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;

  RxBool isCameraInit = false.obs;
  RxBool isLoaded = false.obs;
  RxInt cameraCount = 0.obs;
  RxDouble width = 0.0.obs;
  RxDouble height = 0.0.obs;
  // RxDouble h = 0.0.obs;
  // RxDouble x = 0.0.obs;
  // RxDouble y = 0.0.obs;
  // RxDouble w = 0.0.obs;
  RxString label = "".obs;

  initCamera() async {
    if(await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.max,
        imageFormatGroup: ImageFormatGroup.yuv420
      );
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraCount.value++;
          if(cameraCount.value % 10 == 0){
            cameraCount.value = 0;
            objectDetector(image);
          }
          update();
        });
      });
      isCameraInit(true);
      update();
    } else {
      print("permission denied");
    }
  }

  objectDetector(CameraImage image) async {
    try {
      var detector = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        asynch: true,
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 1,
        rotation: 90,
        threshold: 0.1,
      );

      if (detector != null) {
        var detectObject = detector.first;
        print("ini suka-suka ${detectObject['confidence']}");
        if(detectObject['confidence'] * 100> 0.045){
          label.value = detectObject['label'];
          width = RxDouble(image.width.toDouble());
          height = RxDouble(image.height.toDouble());
          // h.value = detector.first['rect']['h'];
          // w.value = detector.first['rect']['w'];
          // x.value = detector.first['rect']['x'];
          // y.value = detector.first['rect']['y'];
          update();
        }
        log("Result is $detector");
        print("label : ${label.value}");
        print("width : ${width.value}");
        print("heigth : ${height.value}");
        // print("x${x.value}");
        // print(y.value);
        // print(w.value);
        // print(h.value);
        update();
      }
    } catch (e) {
      log("Error in object detection: $e");
    }
  }

  initTFLite() async {
    print("ininiinininininininininininininin inittflite");
    await Tflite.loadModel(
        model: "assets/daun_mobilenet_model.tflite",
        labels: "assets/daun_labels.txt",
        isAsset: true,
        numThreads: 1,
        useGpuDelegate: false
    );
    isLoaded(true);
  }

  @override
  onInit() async {
    // TODO: implement onInit
    super.onInit();
    // if(isLoaded()){
    //   initCamera();
    // } else {
    //   initTFLite();
    // }
    await initTFLite();
    initCamera();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    cameraController.dispose();
    super.dispose();
  }
}