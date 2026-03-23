import 'package:get/get.dart';
import 'outfit_cam_fun_template_make_logic.dart';
class OutfitCamFunTemplateMakeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutfitCamFunTemplateMakeLogic());
  }
}
