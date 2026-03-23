import 'package:get/get.dart';
import 'outfit_cam_select_photo_logic.dart';
class OutfitCamSelectPhotoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutfitCamSelectPhotoLogic());
  }
}
