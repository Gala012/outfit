import 'package:get/get.dart';
import 'outfit_cam_settings_logic.dart';
class OutfitCamSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutfitCamSettingsLogic());
  }
}
