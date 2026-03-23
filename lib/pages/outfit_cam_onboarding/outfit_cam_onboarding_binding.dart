import 'package:get/get.dart';
import 'outfit_cam_onboarding_logic.dart';
class OutfitCamOnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutfitCamOnboardingLogic());
  }
}
