import 'package:get/get.dart';

import 'outfit_cam_find_logic.dart';

class OutfitCamFindBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      OutfitCamFindLogic(),
      permanent: true,
    );
  }
}
