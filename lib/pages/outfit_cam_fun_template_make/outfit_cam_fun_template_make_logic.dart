import 'dart:io';
import 'package:get/get.dart';
import '../../utils/index.dart';
class OutfitCamFunTemplateMakeLogic extends GetxController {
  late String templateImage;
  late int templateIndex;
  final isLoading = false.obs;
  final loadingMessage = 'Processing...'.obs;
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    templateIndex = args?['templateIndex'] as int? ?? 0;
    templateImage = args?['templateImage'] as String? ??
        'assets/images/scene_templates/scene_templates_01.jpg';
  }
  Future<void> onMakeTap() async {
    try {
      isLoading.value = true;
      loadingMessage.value = 'Opening photo selector...';
      final result = await Get.toNamed('/outfit_select_photo');
      if (result != null && result is File) {
        loadingMessage.value = 'Loading...';
        await Future.delayed(const Duration(milliseconds: 300));
        isLoading.value = false;
        Get.toNamed(
          '/fun_template_result',
          arguments: {
            'portraitFile': result,
            'templateImage': templateImage,
            'templateIndex': templateIndex,
          },
        );
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
      errorToast('Processing failed: ${e.toString()}');
    }
  }
  void onBackTap() {
    Get.back();
  }
}
