import 'package:get/get.dart';
import 'outfit_cam_history_logic.dart';

class OutfitCamHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutfitCamHistoryLogic());
  }
}
