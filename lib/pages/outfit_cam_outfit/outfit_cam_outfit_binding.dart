import 'package:get/get.dart';
import 'outfit_cam_outfit_logic.dart';
class OutfitCamOutfitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutfitCamOutfitLogic());
  }
}
