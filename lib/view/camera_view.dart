import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simpleapp/controller/scan_controller.dart';

class CameraView extends GetView<ScanController> {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    double Widths = MediaQuery.of(context).size.width;
    double Heights = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Obx(
        () {
          controller.camwidth.value = Widths;
          controller.camheight.value = Heights;
          if (controller.isCameraInit.value) {
            return Stack(
              children: [
                CameraPreview(
                    controller.cameraController), // Display the camera preview
                ...controller.boundingBoxes.value.map(
                  (box) => Positioned(
                    left: (box.key['left'] ?? 0.0) * Widths,
                    top: (box.key['top'] ?? 0.0) * Heights,
                    child: Container(
                      width: ((box.key['right'] ?? 0.0) -
                              (box.key['left'] ?? 0.0)) *
                          Widths,
                      height: ((box.key['bottom'] ?? 0.0) -
                              (box.key['top'] ?? 0.0)) *
                          Heights,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        box.value ?? '',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
