import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../db_outfitcam/data.dart';
import '../../db_outfitcam/db_outfitcam_entity.dart';
import '../../utils/index.dart';
import '../../main.dart';

class OutfitCamOutfitLogic extends GetxController {
  final selectedTemplate = 0.obs;
  final isLoading = false.obs;
  final showSaveSuccess = false.obs;
  final loadingMessage = 'Processing...'.obs;
  final savedImagePath = ''.obs;
  final backgroundTemplates = [
    'assets/images/outfit_templates/bg_1.jpg',
    'assets/images/outfit_templates/bg_2.png',
    'assets/images/outfit_templates/bg_3.jpg',
    'assets/images/outfit_templates/bg_4.jpg',
    'assets/images/outfit_templates/bg_5.jpg',
    'assets/images/outfit_templates/bg_6.jpg',
    'assets/images/outfit_templates/bg_7.jpg',
    'assets/images/outfit_templates/bg_8.jpg',
  ];
  final originalTemplates = [
    'assets/images/outfit_templates/original_1.png',
    'assets/images/outfit_templates/original_2.png',
    'assets/images/outfit_templates/original_3.png',
    'assets/images/outfit_templates/original_4.png',
    'assets/images/outfit_templates/original_5.png',
    'assets/images/outfit_templates/original_6.png',
    'assets/images/outfit_templates/original_7.png',
    'assets/images/outfit_templates/original_8.png',
  ];
  final processedTemplates = List.generate(
    8,
    (i) => 'assets/images/outfit_templates/outfit_templates_0${i + 1}.png',
  );
  String getCurrentTemplate() {
    return faceDetected.value
        ? processedTemplates[selectedTemplate.value]
        : originalTemplates[selectedTemplate.value];
  }

  final faceImage = Rx<File?>(null);
  final faceDetected = false.obs;
  final facePosition = const Offset(0, 0).obs;
  final faceScale = 1.0.obs;
  final faceRotation = 0.0.obs;
  final faceFlipped = false.obs;
  final isCropMode = false.obs;
  final faceOnTop = true.obs;
  final ImagePicker _picker = ImagePicker();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
  final OutfitCamDatabase _database = Get.find<OutfitCamDatabase>();
  final GlobalKey previewKey = GlobalKey();

  @override
  void onReady() {
    super.onReady();
    ever(faceImage, (file) {
      if (file != null) {
        faceDetected.value = true;
      }
    });
  }

  @override
  void onClose() {
    _faceDetector.close();
    super.onClose();
  }

  void onTemplateTap(int index) {
    selectedTemplate.value = index;
  }

  Future<void> onChangeImageTap() async {
    try {
      final result = await Get.toNamed('/select_photo');
      if (result != null && result is File) {
        faceImage.value = result;
        faceDetected.value = true;
        facePosition.value = const Offset(0, 0);
        faceScale.value = 1.0;
        faceRotation.value = 0.0;
        faceFlipped.value = false;
      }
    } catch (e) {
      errorToast('Failed to select image: ${e.toString()}');
    }
  }

  Future<void> onTakePhotoTap() async {
    try {
      isLoading.value = true;
      loadingMessage.value = 'Opening camera...';
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );
      isLoading.value = false;
      if (pickedFile != null) {
        await _detectFaceInImage(pickedFile.path);
      }
    } catch (e) {
      isLoading.value = false;
      errorToast('Failed to take photo: ${e.toString()}');
    }
  }

  Future<void> _detectFaceInImage(String imagePath) async {
    try {
      isLoading.value = true;
      loadingMessage.value = 'Detecting face...';
      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isEmpty) {
        isLoading.value = false;
        _showNoFaceDetectedDialog();
        return;
      }
      faceImage.value = File(imagePath);
      faceDetected.value = true;
      facePosition.value = const Offset(0, 0);
      faceScale.value = 1.0;
      faceRotation.value = 0.0;
      faceFlipped.value = false;
      isLoading.value = false;
      successToast('Face detected successfully');
    } catch (e) {
      isLoading.value = false;
      errorToast('Face detection failed: ${e.toString()}');
    }
  }

  void _showNoFaceDetectedDialog() {
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
                  Icons.sentiment_dissatisfied,
                  size: 64.w,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  'No Face Detected',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please try again',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogButton(
                        'Take Photo',
                        secondaryColor,
                        Colors.white,
                        () {
                          Get.back();
                          onTakePhotoTap();
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildDialogButton(
                        'Change Photo',
                        primaryColor,
                        Colors.white,
                        () {
                          Get.back();
                          onChangeImageTap();
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
      barrierDismissible: false,
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

  Offset _lastFocalPoint = Offset.zero;
  double _lastScale = 1.0;
  void onFaceScaleStart(ScaleStartDetails details) {
    if (!faceDetected.value) return;
    _lastFocalPoint = details.focalPoint;
    _lastScale = faceScale.value;
  }

  void onFaceScaleUpdate(ScaleUpdateDetails details) {
    if (!faceDetected.value) return;
    if (details.scale != 1.0) {
      faceScale.value = (_lastScale * details.scale).clamp(0.3, 5.0);
    }
    if (details.pointerCount == 1) {
      final delta = details.focalPoint - _lastFocalPoint;
      facePosition.value = facePosition.value + delta;
      _lastFocalPoint = details.focalPoint;
    } else if (details.pointerCount > 1) {
      _lastFocalPoint = details.focalPoint;
    }
  }

  void onFlipTap() {
    if (!faceDetected.value) return;
    faceFlipped.value = !faceFlipped.value;
  }

  void onRotationUpdate(DragUpdateDetails details, Size containerSize) {
    if (!faceDetected.value) return;
    final center = Offset(containerSize.width / 2, containerSize.height / 2);
    final angle = (details.localPosition - center).direction;
    faceRotation.value = angle;
  }

  Future<void> onEnterCropMode() async {
    if (!faceDetected.value || faceImage.value == null) return;
    try {
      final result = await Get.toNamed(
        '/outfit_crop',
        arguments: faceImage.value!.path,
      );
      if (result != null && result is File) {
        faceImage.value = result;
        facePosition.value = const Offset(0, 0);
        faceScale.value = 1.0;
        faceRotation.value = 0.0;
        successToast('Image cropped successfully');
      }
    } catch (e) {
      errorToast('Failed to crop image: ${e.toString()}');
    }
  }

  void onConfirmCrop() {
    isCropMode.value = false;
    successToast('Crop applied');
  }

  void onCancelCrop() {
    isCropMode.value = false;
  }

  void onToggleLayer() {
    if (!faceDetected.value) return;
    faceOnTop.value = !faceOnTop.value;
  }

  void onRotate90Degrees() {
    if (!faceDetected.value) return;
    faceRotation.value = (faceRotation.value + 1.5708) % 6.2832;
  }

  Future<void> onSaveTap() async {
    if (!faceDetected.value) {
      errorToast('Please select a face image first');
      return;
    }
    try {
      isLoading.value = true;
      loadingMessage.value = 'Saving...';
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        isLoading.value = false;
        errorToast('Storage permission denied');
        return;
      }
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
        name: 'outfit_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (result['isSuccess'] == true) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath =
            '${directory.path}/outfit_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);
        savedImagePath.value = filePath;
        await _database.insertHistoryRecord(
          HistoryRecord(
            imagePath: filePath,
            featureType: 'outfit',
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

  void onCloseSaveDialog() {
    showSaveSuccess.value = false;
    Get.back();
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
        text: 'Check out my fun outfit!',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
      );
    } catch (e) {
      errorToast('Share failed: ${e.toString()}');
    }
  }

  void onViewHistoryTap() {
    onCloseSaveDialog();
    successToast('History feature coming soon');
  }
}
