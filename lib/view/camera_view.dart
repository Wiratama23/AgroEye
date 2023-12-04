
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simpleapp/controller/scan_controller.dart';

class CameraView extends GetView<ScanController> {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(()
        // init: ScanController(),
        // builder: (controller)
        {
          return  controller.isCameraInit.value
              ? Column (
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CameraPreview(controller.cameraController),
                  const SizedBox(height: 20),
                  Container(
                    height: 100,
                    width: 200,
                    child: Text("Item : ${controller.label.value}"),
                  )
                  // Positioned(
                  //   top: (controller.y.value * 700),
                  //   right: (controller.x.value * 100),
                  //   child: Container(
                  //     height: (controller.h.value * 100 * context.height / 100),
                  //     width: (controller.w.value * 100 * context.width / 100),
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(8),
                  //       border: Border.all(color: Colors.red, width: 4.0)
                  //     ),
                  //     child: Column(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         Container(
                  //           color: Colors.blue,
                  //           child: Text(controller.label.value)),
                  //       ],
                  //     ),
                  //   ),
                  // )
                ],
              )
              : const Center(child: CircularProgressIndicator());
        }
      ),
    );
  }
}
