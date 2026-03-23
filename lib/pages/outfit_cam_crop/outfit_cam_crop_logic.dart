import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path_provider/path_provider.dart';
import '../../utils/index.dart';

class OutfitCamCropLogic extends GetxController {
  final cropController = CropController();
  final imageData = Rx<Uint8List?>(null);
  final isProcessing = false.obs;
  @override
  void onInit() {
    super.onInit();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final imagePath = Get.arguments as String?;
      if (imagePath == null) {
        errorToast('No image provided');
        Get.back();
        return;
      }
      final bytes = await File(imagePath).readAsBytes();
      imageData.value = bytes;
    } catch (e) {
      errorToast('Failed to load image');
      Get.back();
    }
  }

  void onCropPressed() {
    if (isProcessing.value) return;
    isProcessing.value = true;
    cropController.crop();
  }

  Future<void> onImageCropped(CropResult result) async {
    try {
      switch (result) {
        case CropSuccess(croppedImage: final croppedData):
          final tempDir = await getTemporaryDirectory();
          final croppedPath =
              '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png';
          final croppedFile = File(croppedPath);
          await croppedFile.writeAsBytes(croppedData);
          Get.back(result: croppedFile);
          break;
        case CropFailure():
          isProcessing.value = false;
          errorToast('Failed to crop image');
          break;
      }
    } catch (e) {
      isProcessing.value = false;
      errorToast('Failed to save cropped image');
    }
  }
}
