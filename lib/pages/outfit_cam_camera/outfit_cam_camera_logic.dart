import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../../utils/index.dart';
import '../../main.dart';

class OutfitCamCameraLogic extends GetxController {
  final isFrontCamera = true.obs;
  final isLoading = false.obs;
  final loadingText = ''.obs;
  final showFirstTimeGuide = false.obs;
  final cameraController = Rx<CameraController?>(null);
  final isCameraInitialized = false.obs;
  List<CameraDescription> _cameras = [];
  final ImagePicker _picker = ImagePicker();
  FaceDetector? _faceDetector;
  @override
  void onInit() {
    super.onInit();
    _initFaceDetector();
    _checkFirstTimeUse();
    _initializeCamera();
  }

  @override
  void onClose() {
    cameraController.value?.dispose();
    _faceDetector?.close();
    super.onClose();
  }

  void _initFaceDetector() {
    try {
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: false,
          enableClassification: false,
          enableLandmarks: false,
          enableTracking: false,
          minFaceSize: 0.01,
          performanceMode: FaceDetectorMode.fast,
        ),
      );
      print('✅ Face detector initialized (minFaceSize: 1%, fast mode)');
    } catch (e) {
      print('❌ Failed to init face detector: $e');
      errorToast('Face detector initialization failed');
    }
  }

  Future<void> _checkFirstTimeUse() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('camera_first_time') ?? true;
      if (isFirstTime) {
        showFirstTimeGuide.value = true;
        Future.delayed(const Duration(seconds: 3), () {
          showFirstTimeGuide.value = false;
        });
        await prefs.setBool('camera_first_time', false);
      }
    } catch (e) {
      print('Check first time error: $e');
    }
  }

  void closeGuide() {
    showFirstTimeGuide.value = false;
  }

  Future<void> _initializeCamera() async {
    try {
      isLoading.value = true;
      loadingText.value = 'Starting camera...';
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        isLoading.value = false;
        _showPermissionDialog('Camera');
        return;
      }
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        isLoading.value = false;
        errorToast('No camera found');
        return;
      }
      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );
      final controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!controller.value.isInitialized) {
        isLoading.value = false;
        errorToast('Failed to start camera');
        return;
      }
      await controller.setFlashMode(FlashMode.off);
      cameraController.value = controller;
      isCameraInitialized.value = true;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorToast('Camera initialization failed: ${e.toString()}');
      print('Camera init error: $e');
    }
  }

  Future<void> toggleCamera() async {
    if (_cameras.isEmpty || cameraController.value == null) return;
    try {
      isLoading.value = true;
      loadingText.value = 'Switching camera...';
      await cameraController.value?.dispose();
      isFrontCamera.value = !isFrontCamera.value;
      final targetCamera = _cameras.firstWhere(
        (camera) =>
            camera.lensDirection ==
            (isFrontCamera.value
                ? CameraLensDirection.front
                : CameraLensDirection.back),
        orElse: () => _cameras.first,
      );
      final controller = CameraController(
        targetCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
      cameraController.value = controller;
      isCameraInitialized.value = true;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorToast('Failed to switch camera');
      print('Switch camera error: $e');
    }
  }

  Future<void> takePicture() async {
    if (cameraController.value == null || !isCameraInitialized.value) {
      errorToast('Camera not ready');
      return;
    }
    try {
      isLoading.value = true;
      loadingText.value = 'Taking photo...';
      final XFile photo = await cameraController.value!.takePicture();
      loadingText.value = 'Processing image...';
      final processedImagePath = await _processImageOrientation(photo.path);
      if (processedImagePath == null) {
        isLoading.value = false;
        errorToast('Failed to process image');
        return;
      }
      loadingText.value = 'Detecting face...';
      await _detectAndProcessFace(processedImagePath);
    } catch (e) {
      isLoading.value = false;
      errorToast('Failed to take photo: ${e.toString()}');
      print('Take photo error: $e');
    }
  }

  Future<String?> _processImageOrientation(String imagePath) async {
    try {
      print('📐 Processing image orientation...');
      final bytes = await File(imagePath).readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        print('❌ Failed to decode image');
        return null;
      }
      print('📏 Original image: ${image.width}x${image.height}');
      if (isFrontCamera.value) {
        print('🔄 Flipping image horizontally (front camera)');
        image = img.flipHorizontal(image);
      }
      final tempDir = await getTemporaryDirectory();
      final processedPath =
          '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final processedFile = File(processedPath);
      await processedFile.writeAsBytes(img.encodeJpg(image, quality: 95));
      print('✅ Image processed and saved: $processedPath');
      return processedPath;
    } catch (e) {
      print('❌ Error processing image orientation: $e');
      return imagePath;
    }
  }

  Future<void> pickFromGallery() async {
    try {
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        _showPermissionDialog('Album');
        return;
      }
      isLoading.value = true;
      loadingText.value = 'Opening album...';
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (pickedFile != null) {
        loadingText.value = 'Detecting face...';
        await _detectAndProcessFace(pickedFile.path);
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
      errorToast('Failed to pick image: ${e.toString()}');
      print('Pick from gallery error: $e');
    }
  }

  Future<void> _detectAndProcessFace(String imagePath) async {
    try {
      print('🔍 ========== Starting face detection ==========');
      print('📸 Image path: $imagePath');
      final file = File(imagePath);
      if (!await file.exists()) {
        isLoading.value = false;
        errorToast('Image file not found');
        print('❌ Image file does not exist');
        return;
      }
      final fileSize = await file.length();
      print('📦 File size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      if (_faceDetector == null) {
        isLoading.value = false;
        errorToast('Face detector not initialized');
        print('❌ ERROR: Face detector is null');
        return;
      }
      print('✅ Face detector is ready (minFaceSize: 1%)');
      try {
        final bytes = await file.readAsBytes();
        final image = img.decodeImage(bytes);
        if (image != null) {
          print('📐 Image dimensions: ${image.width}x${image.height}');
        }
      } catch (e) {
        print('⚠️ Could not read image dimensions: $e');
      }
      print('🔍 Creating InputImage...');
      final inputImage = InputImage.fromFilePath(imagePath);
      print('✅ InputImage created successfully');
      print('🔍 Processing image for face detection...');
      final faces = await _faceDetector!.processImage(inputImage);
      print('✅ Face detection completed. Found ${faces.length} face(s)');
      if (faces.isEmpty) {
        isLoading.value = false;
        print('⚠️ No faces detected in the image');
        _showNoFaceDetectedDialog(imagePath);
        return;
      }
      print('👤 Face details:');
      for (var i = 0; i < faces.length; i++) {
        final face = faces[i];
        print('  Face $i:');
        print('    - BoundingBox: ${face.boundingBox}');
        print('    - HeadEulerAngleY: ${face.headEulerAngleY}');
        print('    - HeadEulerAngleZ: ${face.headEulerAngleZ}');
      }
      print('✅ ========== Face detection completed successfully ==========');
      isLoading.value = false;
      _showTemplateSelectionDialog(imagePath);
    } catch (e) {
      isLoading.value = false;
      print('❌ ========== ERROR in _detectAndProcessFace ==========');
      print('❌ Error: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      if (e.toString().contains('corrupt') ||
          e.toString().contains('invalid')) {
        errorToast('Image file is damaged');
      } else if (e.toString().contains('MlKitException')) {
        errorToast('Face detection service error. Please try again');
      } else {
        errorToast('Face detection failed: ${e.toString()}');
      }
    }
  }

  void _showTemplateSelectionDialog(String imagePath) {
    Get.dialog(
      Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 32.w),
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.face, size: 64.w, color: primaryColor),
                SizedBox(height: 16.h),
                Text(
                  'Choose a Cartoon Head',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Select a template to apply',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildTemplateOption(
                        'assets/images/outfit_templates/boy.png',
                        'Boy',
                        () {
                          Get.back();
                          _applyTemplate(
                            imagePath,
                            'assets/images/outfit_templates/boy.png',
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildTemplateOption(
                        'assets/images/outfit_templates/girl.png',
                        'Girl',
                        () {
                          Get.back();
                          _applyTemplate(
                            imagePath,
                            'assets/images/outfit_templates/girl.png',
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: double.infinity,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildTemplateOption(
    String imagePath,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.w)),
              child: Image.asset(
                imagePath,
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120.h,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, size: 40.w, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyTemplate(String photoPath, String templatePath) async {
    try {
      isLoading.value = true;
      loadingText.value = 'Loading...';
      final File photoFile = File(photoPath);
      await Future.delayed(const Duration(milliseconds: 500));
      isLoading.value = false;
      Get.toNamed(
        '/cartoon_head',
        arguments: {'photo': photoFile, 'template': templatePath},
      );
    } catch (e) {
      isLoading.value = false;
      errorToast('Failed to apply template');
      print('Apply template error: $e');
    }
  }

  void _showNoFaceDetectedDialog(String? lastImagePath) {
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
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogButton(
                        'Album',
                        secondaryColor,
                        Colors.white,
                        () {
                          Get.back();
                          pickFromGallery();
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildDialogButton(
                        'close',
                        primaryColor,
                        Colors.white,
                        () => Get.back(),
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

  void _showPermissionDialog(String permissionType) {
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
                  permissionType == 'Camera'
                      ? Icons.camera_alt_outlined
                      : Icons.photo_library_outlined,
                  size: 64.w,
                  color: primaryColor,
                ),
                SizedBox(height: 16.h),
                Text(
                  '$permissionType Permission Required',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please enable $permissionType access in settings to use this feature',
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
