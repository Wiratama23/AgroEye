
import 'package:get/get.dart';
import 'package:simpleapp/controller/scan_controller.dart';
import 'package:simpleapp/view/camera_view.dart';

class AppRoutes {
  static final pages = [
    GetPage(
        name: '/home',
        page: () => const CameraView(),
        binding: BindingsBuilder(() {
          Get.lazyPut(() => ScanController());
        })
    )
  ];
}