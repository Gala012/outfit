import 'package:get/get.dart';
import 'outfit_cam_art_filter_edit_logic.dart';
class OutfitCamArtFilterEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutfitCamArtFilterEditLogic());
  }
}
