
import 'package:get/get.dart';
import 'package:simpleapp/controller/scan_controller.dart';
import 'package:simpleapp/view/camera_view.dart';
import 'package:simpleapp/view/dashboard.dart';

class AppRoutes {
  static final pages = [
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(seconds: 2),
        name: '/home',
        page: () => const CameraView(),
    ),
    GetPage(
        transition: Transition.downToUp,
        transitionDuration: const Duration(seconds: 2),
        name: '/dashboard',
        page: () =>  const DashBoard(),
        binding: BindingsBuilder((){
          Get.put(ScanController());
        })
    )
  ];
}