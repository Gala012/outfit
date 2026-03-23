import 'package:get/get.dart';
import 'outfit_cam_home_logic.dart';

class OutfitCamHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutfitCamHomeLogic());
  }
}
