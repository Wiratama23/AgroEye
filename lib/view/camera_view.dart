// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../controller/scan_controller.dart';
//
// class CameraView extends GetView<ScanController> {
//   const CameraView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     double Widths = MediaQuery.of(context).size.width;
//     double Heights = MediaQuery.of(context).size.height;
//     return Scaffold(
//       body: Obx(
//             () => controller.isCameraInit.value
//             ? Stack(
//               children: [
//                 CameraPreview(controller.cameraController),
//                 Obx(
//                       () => Stack(
//                     children: controller.boundingBoxes
//                         .map(
//                           (entry) => Positioned(
//                         left: entry.key.left * Widths,
//                         top: entry.key.top * Heights,
//                         child: Container(
//                           width: entry.key.width * Widths,
//                           height: entry.key.height * Heights,
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               color: Colors.green,
//                               width: 4.0,
//                             ),
//                           ),
//                           child: Text(
//                             entry.value,
//                             style: TextStyle(
//                               color: Colors.red,
//                               backgroundColor: Colors.green,
//                             ),
//                           ),
//                         ),
//                       ),
//                     )
//                         .toList(),
//                   ),
//                 ),
//               ],
//             )
//             : const Center(child: CircularProgressIndicator()),
//       ),
//     );
//   }
// }

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
      body: Obx(()
        // init: ScanController(),
        // builder: (controller)
        {
          controller.camwidth.value = Widths;
          controller.camheight.value = Heights;
          return  controller.isCameraInit.value
              ? Column (
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Widths * 0.1),
                    child: Container(
                      height: Heights * 0.5,
                      width: Widths * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.black,
                        border: Border.all(
                          color: Colors.black,
                          width: 3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            fit: StackFit.passthrough,
                            children: [
                              CameraPreview(controller.cameraController),
                              Obx(
                                    () => Stack(
                                      children: [
                                            Positioned(
                                              top: controller.y1.value * 700 * ((Heights * 0.5) / 100),
                                              right: controller.x2.value * 500 * ((Widths * 0.8) / 100),
                                              child: Container(
                                                width: (controller.x1.value * 100) * ((Widths * 0.8) / 100),
                                                height: (controller.y2.value * 100) * ((Heights * 0.5) / 100),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.green
                                                  )
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      color: Colors.white,
                                                      child: Text(controller.labels.value),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ),

                                      ],
                                    )
                              ),
                            ],
                          )
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Padding(
                  //   padding: EdgeInsets.only(left: Widths * 0.1),
                  //   child: Row(
                  //     children: [
                  //       const Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text("Nama Tumbuhan\t :"),
                  //           Text("Hasil Diagnosa\t\t\t\t :"),
                  //           Text("Akurasi\t\t\t\t              :")
                  //         ],
                  //       ),
                  //       const SizedBox(width: 5),
                  //       Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text(controller.name.value),
                  //           Text(controller.diagnose.value),
                  //           Text(controller.accuracy.value)
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.only(left: Widths * 0.1),
                    child: ElevatedButton(
                        onPressed: (){
                          controller.toDashboard();
                        },
                        child: const Text("Go Back")
                    ),
                  ),
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
