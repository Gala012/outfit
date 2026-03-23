import 'package:get/get.dart';
import 'outfit_cam_camera_logic.dart';
class OutfitCamCameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutfitCamCameraLogic());
  }
}
