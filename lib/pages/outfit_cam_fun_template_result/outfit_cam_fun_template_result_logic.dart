import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../db_outfitcam/data.dart';
import '../../db_outfitcam/db_outfitcam_entity.dart';
import '../../utils/index.dart';
class OutfitCamFunTemplateResultLogic extends GetxController {
  final showSaveSuccess = false.obs;
  final isLoading = false.obs;
  final loadingMessage = 'Processing...'.obs;
  final savedImagePath = ''.obs;
  late File portraitFile;
  late String templateImage;
  late int templateIndex;
  final portraitPosition = const Offset(0, 0).obs;
  final portraitScale = 1.0.obs;
  final portraitRotation = 0.0.obs;
  final portraitFlipped = false.obs;
  final OutfitCamDatabase _database = Get.find<OutfitCamDatabase>();
  final GlobalKey previewKey = GlobalKey();
  Offset _lastFocalPoint = Offset.zero;
  double _lastScale = 1.0;
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    portraitFile = args?['portraitFile'] as File? ?? File('');
    templateImage = args?['templateImage'] as String? ?? '';
    templateIndex = args?['templateIndex'] as int? ?? 0;
  }
  void onPortraitScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.focalPoint;
    _lastScale = portraitScale.value;
  }
  void onPortraitScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale != 1.0) {
      portraitScale.value = (_lastScale * details.scale).clamp(0.3, 5.0);
    }
    if (details.pointerCount == 1) {
      final delta = details.focalPoint - _lastFocalPoint;
      portraitPosition.value = portraitPosition.value + delta;
      _lastFocalPoint = details.focalPoint;
    } else if (details.pointerCount > 1) {
      _lastFocalPoint = details.focalPoint;
    }
  }
  void onFlipTap() {
    portraitFlipped.value = !portraitFlipped.value;
  }
  void onRotate90Degrees() {
    portraitRotation.value = (portraitRotation.value + 1.5708) % 6.2832;
  }
  Future<void> onSaveTap() async {
    if (!portraitFile.existsSync()) {
      errorToast('No image to save');
      return;
    }
    try {
      isLoading.value = true;
      loadingMessage.value = 'Compositing...';
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        isLoading.value = false;
        _showPermissionDialog();
        return;
      }
      loadingMessage.value = 'Saving...';
      final boundary =
          previewKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        isLoading.value = false;
        errorToast('Failed to capture preview');
        return;
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      final result = await ImageGallerySaverPlus.saveImage(
        pngBytes,
        quality: 100,
        name: 'fun_template_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (result['isSuccess'] == true) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath =
            '${directory.path}/fun_template_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);
        savedImagePath.value = filePath;
        await _database.insertHistoryRecord(
          HistoryRecord(
            imagePath: filePath,
            featureType: 'fun_template',
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
        isLoading.value = false;
        showSaveSuccess.value = true;
        successToast('Saved to album');
      } else {
        isLoading.value = false;
        errorToast('Failed to save image');
      }
    } catch (e) {
      isLoading.value = false;
      errorToast('Save failed: ${e.toString()}');
    }
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
                  color: const Color(0xFFFF6B9D),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Album Permission Required',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please enable album access in settings',
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
                        const Color(0xFF2C3E50),
                        () => Get.back(),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildDialogButton(
                        'Go to Settings',
                        const Color(0xFFFF6B9D),
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
  void onRemakeTap() {
    Get.until((route) => route.settings.name == '/outfit_fun_template');
  }
  void onCloseSaveDialog() {
    showSaveSuccess.value = false;
    Get.until((route) => route.settings.name == '/outfit_home');
  }
  Future<void> onShareTap() async {
    try {
      if (savedImagePath.value.isEmpty) {
        errorToast('No image to share');
        return;
      }
      final file = XFile(savedImagePath.value);
      await Share.shareXFiles(
        [file],
        text: 'Check out my fun scene!',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
      );
    } catch (e) {
      errorToast('Share failed: ${e.toString()}');
    }
  }
  void onViewHistoryTap() {
    onCloseSaveDialog();
    Get.toNamed('/outfit_history');
  }
}
