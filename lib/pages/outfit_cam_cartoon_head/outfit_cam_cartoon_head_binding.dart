import 'package:get/get.dart';
import 'outfit_cam_cartoon_head_logic.dart';
class OutfitCamCartoonHeadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutfitCamCartoonHeadLogic());
  }
}
