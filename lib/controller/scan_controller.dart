import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_v2/tflite_v2.dart';

class ScanController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));
  RxBool isCameraInit = false.obs;
  RxBool isLoaded = false.obs;
  RxInt cameraCount = 0.obs;
  RxDouble width = 0.0.obs;
  RxDouble height = 0.0.obs;
  // RxDouble h = 0.0.obs;
  // RxDouble x = 0.0.obs;
  // RxDouble y = 0.0.obs;
  // RxDouble w = 0.0.obs;
  RxString model = "".obs;
  RxString labels = "".obs;
  RxString rawlabel = "".obs;
  RxString name = "".obs;
  RxString diagnose = "".obs;
  RxString accuracy = "".obs;

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
    if (classify.contains("leaf")) {
      model.value = "assets/daun_mobilenet_model.tflite";
      labels.value = "assets/daun_labels.txt";
    } else if (classify.contains("paddy")) {
      model.value = "assets/padi_model.tflite";
      labels.value = "assets/padi_label.txt";
    } else {
      model.value = "assets/daun_mobilenet_model.tflite";
      labels.value = "assets/daun_labels.txt";
    }
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
        if(detectObject['confidence'] * 100> 50){
          splitter(detectObject['label']);
          accuracy.value = (detectObject['confidence'] * 100).toStringAsFixed(0) + '%';
          // rawlabel.value = detectObject['label'];
          // width = RxDouble(image.width.toDouble());
          // height = RxDouble(image.height.toDouble());
          // h.value = detector.first['rect']['h'];
          // w.value = detector.first['rect']['w'];
          // x.value = detector.first['rect']['x'];
          // y.value = detector.first['rect']['y'];
          update();
        } else {
          splitter("tidak ditemukan___tidak ditemukan");
          accuracy.value = (detectObject['confidence'] * 100).toStringAsFixed(0) + '%';
          update();
        }
        log("Result is $detector");
        print("label : ${rawlabel.value}");
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
    try{
      Tflite.close();
      await Tflite.loadModel(
          model: model.value,
          labels: labels.value,
          isAsset: true,
          numThreads: -1,
          useGpuDelegate: false
      );
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
      closeTFLiteResources();
      disposeCamera();
      Get.toNamed("/dashboard");
    } else {
      Get.snackbar("Error", "Wait for a while");
    }
  }

}