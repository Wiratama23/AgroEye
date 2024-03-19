import 'dart:developer';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:tflite_v2/tflite_v2.dart';

double root(num value, num rootDegree) {
  // Check dulu benar apa kagak
  if (value is! num || rootDegree is! num) {
    throw ArgumentError('Must number');
  }
  // Biar gak error kalau nilainya minus, karena minus itu imajiner
  if (rootDegree <= 0) {
    throw ArgumentError('Must positive');
  }
  return math.pow(value, 1 / rootDegree).toDouble();
}

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
  RxList<MapEntry<Map<String, double>, String>> boundingBoxes =
      <MapEntry<Map<String, double>, String>>[].obs;
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
  int frameCount = 0;
  bool isDetecting = false;

  checkPermission(Permission permission, String classifies) async {
    final status = await permission.request();
    if (status.isGranted) {
      classify(classifies);
    } else {
      Get.snackbar("Eror", "Permission is not granted");
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
    if (isCameraInit.isFalse) {
      initCamera();
    } else {
      cameraController.resumePreview();
    }
    toCamera();
  }

  splitter(String label) {
    if (label.contains("___")) {
      final split = label.split("___");
      if (split.length == 2) {
        split[0] = split[0].replaceAll("_", " ");
        name.value = split[0].replaceAll(",", "");
        diagnose.value = split[1].replaceAll("_", " ");
      }
    }
  }

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.max,
          imageFormatGroup: ImageFormatGroup.yuv420, enableAudio: false);
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          frameCount++;
          if (frameCount % 5 == 0 && !isDetecting) {
            frameCount = 0;
            objectDetector(image);
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
    if (isDetecting) return;
    isDetecting = true;
    print(image.height);
    print(image.width);
    try {
      final detector = await vision.yoloOnFrame(
          bytesList: image.planes.map((plane) => plane.bytes).toList(),
          imageHeight: image.height,
          imageWidth: image.width,
          iouThreshold: 0.3,
          confThreshold: 0.3,
          classThreshold: 0.4);
      print(detector);
      boundingBoxes.clear(); // Clear the list before adding new bounding boxes

      if (detector != null) {
        for (final detectedObject in detector) {
          final left = detectedObject['box'][0];
          final top = detectedObject['box'][1];
          final right = left + detectedObject['box'][2];
          final bottom = top + detectedObject['box'][3];
          final confidence = detectedObject['box'][4];
          final label = detectedObject['tag'];

          if (confidence > 0.3) {
            // Add bounding box and label to the list
            boundingBoxes.add(
              MapEntry(
                {
                  'left': math.pow(left, 1.1) / image.width,
                  'top': root(top, 1.129) / image.height,
                  'right': math.pow(right, 1.01) / image.width,
                  'bottom': root(bottom, 1.2) / image.height,
                },
                label,
              ),
            );
          }
        }
      }

      update();
    } catch (e) {
      print("Error in object detection: $e");
    } finally {
      isDetecting = false;
    }
  }

  initTFLite() async {
    try {
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
          numThreads: 2,
          useGpu: true);
      isLoaded(true);
    } catch (e) {
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

  toCamera() {
    Get.toNamed("/home");
  }

  toDashboard() {
    if (isCameraInit.isTrue && isLoaded.isTrue) {
      vision.closeYoloModel();
      closeTFLiteResources();
      disposeCamera();
      Get.toNamed("/dashboard");
    } else {
      Get.snackbar("Error", "Wait for a while");
    }
  }
}
