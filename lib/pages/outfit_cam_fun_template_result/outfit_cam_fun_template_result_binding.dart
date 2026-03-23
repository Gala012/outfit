import 'package:get/get.dart';
import 'outfit_cam_fun_template_result_logic.dart';
class OutfitCamFunTemplateResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutfitCamFunTemplateResultLogic());
  }
}
