import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:tflite_v2/tflite_v2.dart';

class ScanController extends GetxController {
  // RxList<MapEntry<Map<String, double>, String>> boundingBoxes =
  //     <MapEntry<Map<String, double>, String>>[].obs;
  FlutterVision vision = FlutterVision();
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));
  RxBool isCameraInit = false.obs;
  RxBool isLoaded = false.obs;
  RxInt cameraCount = 0.obs;
  RxDouble width = 0.0.obs;
  RxDouble height = 0.0.obs;
  RxDouble x1 = 0.0.obs;
  RxDouble x2 = 0.0.obs;
  RxDouble y1 = 0.0.obs;
  RxDouble y2 = 0.0.obs;
  RxString model = "".obs;
  RxString labels = "".obs;
  RxString rawlabel = "".obs;
  RxString name = "".obs;
  RxString diagnose = "".obs;
  RxString accuracy = "".obs;
  RxDouble camwidth = 0.0.obs;
  RxDouble camheight = 0.0.obs;

  checkPermission(Permission permission, String classifies) async {
    final status = await permission.request();
    if (status.isGranted) {
      classify(classifies);
    } else {
      Get.snackbar(
          "Eror",
          "Permission is not granted");
    }
  }

  classify(String classify) async {
    // if (classify.contains("leaf")) {
    //   model.value = "assets/daun_mobilenet_model.tflite";
    //   labels.value = "assets/daun_labels.txt";
    // } else if (classify.contains("paddy")) {
    //   model.value = "assets/daun_mobilenet_model.tflite";
    //   labels.value = "assets/daun_labels.txt";
    // } else {
    //   model.value = "assets/daun_mobilenet_model.tflite";
    //   labels.value = "assets/daun_labels.txt";
    // }

    update();
    print("ini modelnya ${model.value}");
    print("ini labelnya ${labels.value}");
    await initTFLite();
    if(isCameraInit.isFalse){
      initCamera();
    }else{
      cameraController.resumePreview();
    }
    toCamera();
  }

  splitter(String label) {
    if(label.contains("___")){
      final split = label.split("___");
      if(split.length == 2){
        split[0] = split[0].replaceAll("_", " ");
        name.value = split[0].replaceAll(",", "");
        diagnose.value = split[1].replaceAll("_", " ");
      }
    }
  }

  initCamera() async {
    if(await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.max,
        imageFormatGroup: ImageFormatGroup.yuv420,
          enableAudio: false
      );
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraCount.value++;
          if(cameraCount.value % 10 == 0){
            cameraCount.value = 0;
            _debouncer(() {
              objectDetector(image);
            });
          }
          update();
          isCameraInit(true);
        });
      });
      update();
    } else {
      print("permission denied");
    }
  }

  // void addBoundingBox(double left, double top, double right, double bottom, String label) {
  //   final Map<String, double> coordinates = {
  //     'left': left / (cameraController.value.previewSize?.width ?? 1),
  //     'top': top / (cameraController.value.previewSize?.height ?? 1),
  //     'right': right / (cameraController.value.previewSize?.width ?? 1),
  //     'bottom': bottom / (cameraController.value.previewSize?.height ?? 1),
  //   };
  //   boundingBoxes.add(MapEntry(coordinates, label));
  //   boundingBoxes.add(
  //     MapEntry(
  //       coordinates,
  //       // Rect.fromLTRB(
  //       //   left / cameraController.value.previewSize!.width,
  //       //   top / cameraController.value.previewSize!.height,
  //       //   right / cameraController.value.previewSize!.width,
  //       //   bottom / cameraController.value.previewSize!.height,
  //       // ),
  //       label,
  //     ),
  //   );
  //   print(boundingBoxes.value);
  // }

  objectDetector(CameraImage image) async {
    try {
      // var detector = await Tflite.runModelOnFrame(
      //   bytesList: image.planes.map((plane) {
      //     return plane.bytes;
      //   }).toList(),
      //   asynch: true,
      //   imageHeight: image.height,
      //   imageWidth: image.width,
      //   imageMean: 127.5,
      //   imageStd: 127.5,
      //   numResults: 1,
      //   rotation: 90,
      //   threshold: 0.1,
      // );
      print("image height : ${image.height}");
      print("image width : ${image.width}");
      print("canv width : ${camwidth.value}");
      print("canv height : ${camheight.value}");
      final detector = await vision.yoloOnFrame(
          bytesList: image.planes.map((plane) => plane.bytes).toList(),
          imageHeight: image.height,
          imageWidth: image.width,
          iouThreshold: 0.4,
          confThreshold: 0.4,
          classThreshold: 0.5
      );
      // boundingBoxes.clear();
      print(detector);
      if (detector != null) {
        for (final detectedObject in detector) {
          final left = detectedObject['box'][0];
          final top = detectedObject['box'][1];
          final right = left + detectedObject['box'][2];
          final bottom = top + detectedObject['box'][3];
          final confidence = detectedObject['box'][4];
          final label = detectedObject['tag']; // Get the label

          if (confidence >0.5) {
            // Add bounding box and label to the list
            // addBoundingBox(left, top, right, bottom, label);
            x1.value = left;
            x2.value = right;
            y1.value = top;
            y2.value = bottom;
            labels.value = label;

            splitter(label); // Use the label directly
            accuracy.value = (confidence * 100).toStringAsFixed(0) + '%';
            update();
          } else {
            splitter("tidak ditemukan___tidak ditemukan");
            accuracy.value = (confidence * 100).toStringAsFixed(0) + '%';
            update();
          }
        }
      }
      // if (detector != null) {
      //   var detectObject = detector.first;
      //   print("ini suka-suka ${detectObject['confidence']}");
      //   if(detectObject['confidence'] * 100> 50){
      //     splitter(detectObject['label']);
      //     accuracy.value = (detectObject['confidence'] * 100).toStringAsFixed(0) + '%';
      //     // rawlabel.value = detectObject['label'];
      //     // width = RxDouble(image.width.toDouble());
      //     // height = RxDouble(image.height.toDouble());
      //     // h.value = detector.first['rect']['h'];
      //     // w.value = detector.first['rect']['w'];
      //     // x.value = detector.first['rect']['x'];
      //     // y.value = detector.first['rect']['y'];
      //     update();
      //   } else {
      //     splitter("tidak ditemukan___tidak ditemukan");
      //     accuracy.value = (detectObject['confidence'] * 100).toStringAsFixed(0) + '%';
      //     update();
      //   }
      //   log("Result is $detector");
      //   print("label : ${rawlabel.value}");
      //   print("width : ${width.value}");
      //   print("heigth : ${height.value}");
      //   // print("x${x.value}");
      //   // print(y.value);
      //   // print(w.value);
      //   // print(h.value);
      //   update();
      // }
    } catch (e) {
      log("Error in object detection: $e");
    }
  }

  initTFLite() async {
    try{
      // Tflite.close();
      // await Tflite.loadModel(
      //     model: model.value,
      //     labels: labels.value,
      //     isAsset: true,
      //     numThreads: 1,
      //     useGpuDelegate: false
      // );
      await vision.closeYoloModel();
      await vision.loadYoloModel(
          labels: 'assets/labels_v8.txt',
          modelPath: 'assets/yolov8n_float32.tflite',
          modelVersion: "yolov8",
          quantization: false,
          numThreads: -1,
          useGpu: true);
      isLoaded(true);
    }catch(e){
      print(e);
    }
  }

  void closeTFLiteResources() {
    model.value = "";
    labels.value = "";
    isLoaded(false);
  }

  void disposeCamera() {
    cameraController.pausePreview();
    // isCameraInit(false);
  }

  toCamera(){
    Get.toNamed("/home");
  }

  toDashboard(){
    if(isCameraInit.isTrue && isLoaded.isTrue){
      vision.closeYoloModel();
      closeTFLiteResources();
      disposeCamera();
      Get.toNamed("/dashboard");
    } else {
      Get.snackbar("Error", "Wait for a while");
    }
  }

}