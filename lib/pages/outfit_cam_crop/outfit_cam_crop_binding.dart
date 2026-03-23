import 'package:get/get.dart';
import 'outfit_cam_crop_logic.dart';

class OutfitCamCropBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutfitCamCropLogic());
  }
}
