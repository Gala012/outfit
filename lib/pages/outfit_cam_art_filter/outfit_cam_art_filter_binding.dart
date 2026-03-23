import 'package:get/get.dart';
import 'outfit_cam_art_filter_logic.dart';
class OutfitCamArtFilterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutfitCamArtFilterLogic());
  }
}
