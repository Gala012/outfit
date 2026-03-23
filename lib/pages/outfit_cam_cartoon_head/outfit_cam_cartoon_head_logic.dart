import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as img;
import '../../db_outfitcam/data.dart';
import '../../db_outfitcam/db_outfitcam_entity.dart';
import '../../utils/index.dart';
import '../../main.dart';

class OutfitCamCartoonHeadLogic extends GetxController {
  final photoImage = Rx<File?>(null);
  final templatePath = ''.obs;
  final headPosition = Rx<Offset>(Offset.zero);
  final headScale = 1.8.obs;
  final headRotation = 0.0.obs;
  final headFlipped = false.obs;
  final isLoading = false.obs;
  final loadingMessage = ''.obs;
  final savedImagePath = ''.obs;
  final showSaveSuccess = false.obs;
  double _baseScale = 1.8;
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      photoImage.value = args['photo'] as File?;
      templatePath.value = args['template'] as String? ?? '';
      headPosition.value = Offset(0, -20.h);
    }
  }

  void onHeadScaleStart(ScaleStartDetails details) {
    _baseScale = headScale.value;
  }

  void onHeadScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale != 1.0) {
      final newScale = (_baseScale * details.scale).clamp(0.3, 3.0);
      headScale.value = newScale;
    }
    headPosition.value = Offset(
      headPosition.value.dx + details.focalPointDelta.dx,
      headPosition.value.dy + details.focalPointDelta.dy,
    );
  }

  Future<void> onSaveTap() async {
    if (photoImage.value == null || templatePath.value.isEmpty) {
      errorToast('No image to save');
      return;
    }
    try {
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        _showPermissionDialog();
        return;
      }
      isLoading.value = true;
      loadingMessage.value = 'Compositing image...';
      final compositedFile = await _compositeImageWithTemplate();
      if (compositedFile == null) {
        isLoading.value = false;
        errorToast('Failed to composite image');
        return;
      }
      loadingMessage.value = 'Saving to album...';
      final result = await ImageGallerySaverPlus.saveFile(
        compositedFile.path,
        name: 'cartoon_head_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (result['isSuccess'] != true) {
        isLoading.value = false;
        errorToast('Failed to save to album');
        return;
      }
      final appDir = await getApplicationDocumentsDirectory();
      final savedPath =
          '${appDir.path}/cartoon_head_${DateTime.now().millisecondsSinceEpoch}.png';
      await compositedFile.copy(savedPath);
      savedImagePath.value = savedPath;
      final db = Get.find<OutfitCamDatabase>();
      await db.insertHistoryRecord(
        HistoryRecord(
          imagePath: savedPath,
          featureType: 'cartoon_head',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      isLoading.value = false;
      showSaveSuccess.value = true;
    } catch (e) {
      isLoading.value = false;
      errorToast('Save failed: ${e.toString()}');
      print('Save error: $e');
    }
  }

  Future<File?> _compositeImageWithTemplate() async {
    try {
      final photoBytes = await photoImage.value!.readAsBytes();
      final photoImg = img.decodeImage(photoBytes);
      if (photoImg == null) {
        return null;
      }
      final templateBytes = await _loadAssetImage(templatePath.value);
      final templateImg = img.decodeImage(templateBytes);
      if (templateImg == null) {
        return null;
      }
      final canvas = img.Image(width: photoImg.width, height: photoImg.height);
      img.compositeImage(canvas, photoImg, dstX: 0, dstY: 0);
      final baseRatio = 0.35;
      final templateWidth = (photoImg.width * baseRatio * headScale.value)
          .toInt();
      final templateHeight =
          (templateWidth * templateImg.height / templateImg.width).toInt();
      final scaledTemplate = img.copyResize(
        templateImg,
        width: templateWidth,
        height: templateHeight,
      );
      final finalTemplate = headFlipped.value
          ? img.flipHorizontal(scaledTemplate)
          : scaledTemplate;
      final screenToPhotoRatio = photoImg.width / 375.0;
      final centerX = photoImg.width ~/ 2;
      final centerY = photoImg.height ~/ 2;
      final offsetX = (headPosition.value.dx * screenToPhotoRatio).toInt();
      final offsetY = (headPosition.value.dy * screenToPhotoRatio).toInt();
      final dstX = centerX - (templateWidth ~/ 2) + offsetX;
      final dstY = centerY - (templateHeight ~/ 2) + offsetY;
      img.compositeImage(canvas, finalTemplate, dstX: dstX, dstY: dstY);
      final pngBytes = img.encodePng(canvas);
      final tempDir = await getTemporaryDirectory();
      final tempPath =
          '${tempDir.path}/composited_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(pngBytes);
      return tempFile;
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List> _loadAssetImage(String assetPath) async {
    final data = await DefaultAssetBundle.of(Get.context!).load(assetPath);
    return data.buffer.asUint8List();
  }

  Future<void> onShareTap() async {
    if (savedImagePath.value.isEmpty) {
      errorToast('Please save the image first');
      return;
    }
    try {
      await Share.shareXFiles(
        [XFile(savedImagePath.value)],
        text: 'Check out my cartoon head photo!',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
      );
    } catch (e) {
      errorToast('Share failed');
      print('Share error: $e');
    }
  }

  void onViewHistoryTap() {
    showSaveSuccess.value = false;
    Get.offAllNamed('/outfit_history');
  }

  void onDoneTap() {
    showSaveSuccess.value = false;
    Get.offAllNamed('/outfit_home');
  }

  void closeSaveSuccessDialog() {
    showSaveSuccess.value = false;
  }

  void onBackTap() {
    Get.back();
  }

  void _showPermissionDialog() {
    Get.dialog(
      Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 40.w),
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.w),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 64.w,
                  color: primaryColor,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Album Permission Required',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please enable album access in settings to save photos',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogButton(
                        'Cancel',
                        Colors.grey[200]!,
                        textColor,
                        () => Get.back(),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildDialogButton(
                        'Go to Settings',
                        primaryColor,
                        Colors.white,
                        () {
                          Get.back();
                          openAppSettings();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(
    String label,
    Color bg,
    Color fg,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10.w),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
