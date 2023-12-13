import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simpleapp/controller/scan_controller.dart';
import 'component/buttonlist.dart';
class DashBoard extends GetView<ScanController> {
  const DashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Text("AGROEYE", style: TextStyle(fontSize: 40),),
              const SizedBox(height: 80),
              ButtonList(
                onTap: (){
                  controller.checkPermission(Permission.camera, "leaf");
                },
                title: "Leaf Detector",
                deskripsi: "Classify how healthy plant is",
                imagePath: "leaf",
              ),
              const SizedBox(height: 50),
              ButtonList(
                onTap: (){
                  controller.checkPermission(Permission.camera,"paddy");
                },
                title: "Paddy Analyzer",
                deskripsi: "Analyze the paddy crop\nusing mobile phone camera",
                imagePath: "paddy",
              ),
              const SizedBox(height: 50),
              ButtonList(
                onTap: (){
                  controller.checkPermission(Permission.camera,"fruit");
                },
                title: "Fruit Analyzer",
                deskripsi: "analyze of healthy the fruit is\nbased on camera image",
                imagePath: "fruit",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
