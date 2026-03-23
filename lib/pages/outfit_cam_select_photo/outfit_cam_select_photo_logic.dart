import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../../utils/index.dart';
import '../../main.dart';
class OutfitCamSelectPhotoLogic extends GetxController {
  final isLoading = false.obs;
  final loadingMessage = 'Loading...'.obs;
  final selectedImage = Rx<File?>(null);
  final faceDetected = false.obs;
  final albums = <AssetPathEntity>[].obs;
  final currentAlbumIndex = 0.obs;
  final photos = <AssetEntity>[].obs;
  final isLoadingPhotos = true.obs;
  final ImagePicker _picker = ImagePicker();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
  SelfieSegmenter? _segmenter;
  Timer? _detectionTimer;
  @override
  void onInit() {
    super.onInit();
    _initSegmenter();
    _loadAlbums();
  }
  @override
  void onClose() {
    _faceDetector.close();
    _segmenter?.close();
    _detectionTimer?.cancel();
    super.onClose();
  }
  void _initSegmenter() {
    try {
      _segmenter = SelfieSegmenter(
        mode: SegmenterMode.single,
        enableRawSizeMask: false,
      );
    } catch (e) {
      print('Failed to init segmenter: $e');
    }
  }
  Future<void> _loadAlbums() async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        _showPermissionDialog();
        return;
      }
      isLoadingPhotos.value = true;
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
        onlyAll: true,
      );
      if (paths.isEmpty) {
        isLoadingPhotos.value = false;
        errorToast('No photos found in album');
        return;
      }
      albums.value = paths;
      currentAlbumIndex.value = 0;
      await _loadPhotosFromAlbum(0);
    } catch (e) {
      isLoadingPhotos.value = false;
      errorToast('Failed to load albums: ${e.toString()}');
    }
  }
  Future<void> _loadPhotosFromAlbum(int index) async {
    try {
      isLoadingPhotos.value = true;
      currentAlbumIndex.value = index;
      final AssetPathEntity album = albums[index];
      final List<AssetEntity> assets = await album.getAssetListRange(
        start: 0,
        end: 1000,
      );
      photos.value = assets;
      isLoadingPhotos.value = false;
    } catch (e) {
      isLoadingPhotos.value = false;
      errorToast('Failed to load photos: ${e.toString()}');
    }
  }
  Future<void> selectPhoto(AssetEntity asset) async {
    try {
      isLoading.value = true;
      loadingMessage.value = 'Loading photo...';
      final File? file = await asset.file;
      if (file == null) {
        isLoading.value = false;
        errorToast('Failed to load photo');
        return;
      }
      loadingMessage.value = 'Detecting face...';
      await _detectFaceInImage(file.path);
    } catch (e) {
      isLoading.value = false;
      errorToast('Failed to select photo: ${e.toString()}');
    }
  }
  Future<void> takePhoto() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        errorToast('Camera permission denied');
        return;
      }
      isLoading.value = true;
      loadingMessage.value = 'Opening camera...';
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
        requestFullMetadata: false,
      );
      if (pickedFile != null) {
        loadingMessage.value = 'Processing image...';
        final bytes = await pickedFile.readAsBytes();
        final originalImage = img.decodeImage(bytes);
        if (originalImage == null) {
          isLoading.value = false;
          errorToast('Failed to process image');
          return;
        }
        final tempDir = await getTemporaryDirectory();
        final processedPath = '${tempDir.path}/camera_${DateTime.now().millisecondsSinceEpoch}.png';
        final processedFile = File(processedPath);
        await processedFile.writeAsBytes(img.encodePng(originalImage));
        loadingMessage.value = 'Detecting face...';
        await _detectFaceInImage(processedFile.path);
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
      errorToast('Failed to take photo: ${e.toString()}');
    }
  }
  Future<void> _detectFaceInImage(String imagePath) async {
    try {
      selectedImage.value = File(imagePath);
      bool detectionCompleted = false;
      _detectionTimer = Timer(const Duration(seconds: 5), () {
        if (!detectionCompleted) {
          isLoading.value = false;
          _showNoFaceDetectedDialog();
        }
      });
      loadingMessage.value = 'Detecting face...';
      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await _faceDetector.processImage(inputImage);
      detectionCompleted = true;
      _detectionTimer?.cancel();
      if (faces.isEmpty) {
        isLoading.value = false;
        _showNoFaceDetectedDialog();
        return;
      }
      loadingMessage.value = 'Removing background...';
      final faceFile = await _segmentPortrait(imagePath);
      if (faceFile == null) {
        isLoading.value = false;
        errorToast('Failed to extract face');
        return;
      }
      faceDetected.value = true;
      isLoading.value = false;
      successToast('Face extracted successfully');
      await Future.delayed(const Duration(milliseconds: 500));
      Get.back(result: faceFile);
    } catch (e) {
      _detectionTimer?.cancel();
      isLoading.value = false;
      if (e.toString().contains('corrupt') ||
          e.toString().contains('invalid')) {
        errorToast('Image file is damaged, please select another photo');
      } else {
        errorToast('Face detection failed: ${e.toString()}');
      }
    }
  }
  Future<File?> _segmentPortrait(String imagePath) async {
    if (_segmenter == null) {
      errorToast('Segmenter not initialized');
      return null;
    }
    try {
      final bytes = await File(imagePath).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final originalImage = frame.image;
      final inputImage = InputImage.fromFilePath(imagePath);
      final mask = await _segmenter!.processImage(inputImage);
      if (mask == null) {
        codec.dispose();
        originalImage.dispose();
        return null;
      }
      final portraitImage = await _applySegmentationMask(
        originalImage,
        mask,
      );
      codec.dispose();
      originalImage.dispose();
      if (portraitImage == null) {
        return null;
      }
      final byteData = await portraitImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      portraitImage.dispose();
      if (byteData == null) {
        return null;
      }
      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final portraitFilePath =
          '${tempDir.path}/portrait_${DateTime.now().millisecondsSinceEpoch}.png';
      final portraitFile = File(portraitFilePath);
      await portraitFile.writeAsBytes(pngBytes);
      return portraitFile;
    } catch (e) {
      print('Segment portrait error: $e');
      return null;
    }
  }
  Future<ui.Image?> _applySegmentationMask(
    ui.Image originalImage,
    SegmentationMask mask,
  ) async {
    try {
      final imgW = originalImage.width;
      final imgH = originalImage.height;
      final maskW = mask.width;
      final maskH = mask.height;
      final imgByteData = await originalImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (imgByteData == null) return null;
      final imgPixels = imgByteData.buffer.asUint8List();
      final maskData = <int>[];
      for (final confidence in mask.confidences) {
        maskData.add((confidence * 255).toInt());
      }
      final maskBytes = Uint8List.fromList(maskData);
      final resultPixels = Uint8List(imgW * imgH * 4);
      const int threshold = 128;
      for (int y = 0; y < imgH; y++) {
        for (int x = 0; x < imgW; x++) {
          final maskX = (x * maskW / imgW).floor().toInt().clamp(0, maskW - 1);
          final maskY = (y * maskH / imgH).floor().toInt().clamp(0, maskH - 1);
          final maskIndex = maskY * maskW + maskX;
          if (maskIndex >= maskBytes.length) continue;
          final maskValue = maskBytes[maskIndex];
          final srcPixelIndex = (y * imgW + x) * 4;
          final dstPixelIndex = srcPixelIndex;
          if (maskValue >= threshold) {
            resultPixels[dstPixelIndex] = imgPixels[srcPixelIndex];
            resultPixels[dstPixelIndex + 1] = imgPixels[srcPixelIndex + 1];
            resultPixels[dstPixelIndex + 2] = imgPixels[srcPixelIndex + 2];
            resultPixels[dstPixelIndex + 3] = 255;
          } else {
            resultPixels[dstPixelIndex] = 0;
            resultPixels[dstPixelIndex + 1] = 0;
            resultPixels[dstPixelIndex + 2] = 0;
            resultPixels[dstPixelIndex + 3] = 0;
          }
        }
      }
      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        resultPixels,
        imgW,
        imgH,
        ui.PixelFormat.rgba8888,
        (ui.Image result) {
          completer.complete(result);
        },
      );
      return await completer.future;
    } catch (e) {
      print('Apply mask error: $e');
      return null;
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
                          takePhoto();
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
                        textColor,
                        () {
                          Get.back();
                          Get.back();
                        },
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
                          PhotoManager.openSetting();
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
