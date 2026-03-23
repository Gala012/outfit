import 'package:get/get.dart';
import 'outfit_cam_fun_template_logic.dart';

class OutfitCamFunTemplateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutfitCamFunTemplateLogic());
  }
}
