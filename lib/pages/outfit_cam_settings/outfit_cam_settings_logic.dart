import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class OutfitCamSettingsLogic extends GetxController {
  final appVersion = ''.obs;
  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = 'Version ${packageInfo.version}';
    } catch (e) {
      print('Error loading app version: $e');
      appVersion.value = 'Version 1.0.0';
    }
  }

  void onHistoryTap() {
    Get.toNamed('/outfit_history');
  }
}
