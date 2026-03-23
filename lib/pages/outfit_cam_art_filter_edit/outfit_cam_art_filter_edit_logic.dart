import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../../db_outfitcam/data.dart';
import '../../db_outfitcam/db_outfitcam_entity.dart';
import '../../utils/index.dart';

class OutfitCamArtFilterEditLogic extends GetxController {
  final selectedCategory = 0.obs;
  final selectedFilter = 0.obs;
  final showSaveSuccess = false.obs;
  final isLoading = false.obs;
  final loadingMessage = 'Processing...'.obs;
  final savedImagePath = ''.obs;
  late File userImage;
  final OutfitCamDatabase _database = Get.find<OutfitCamDatabase>();
  final GlobalKey previewKey = GlobalKey();
  final categories = ['Popular', 'Landscape', 'Romance', 'Premium', 'Vintage'];
  final filtersByCategory = <List<Map<String, dynamic>>>[
    [
      {'name': 'Original', 'matrix': null},
      {
        'name': 'Beach',
        'matrix': [
          1.2,
          0.0,
          0.0,
          0.0,
          10.0,
          0.0,
          1.1,
          0.0,
          0.0,
          5.0,
          0.0,
          0.0,
          0.9,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ],
      },
      {
        'name': 'Afternoon',
        'matrix': [
          1.1,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.85,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ],
      },
      {
        'name': 'Summer',
        'matrix': [
          1.15,
          0.0,
          0.0,
          0.0,
          15.0,
          0.0,
          1.05,
          0.0,
          0.0,
          10.0,
          0.0,
          0.0,
          0.95,
          0.0,
          -5.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ],
      },
      {
        'name': 'Dream',
        'matrix': [
          1.0,
          0.0,
          0.0,
          0.0,
          20.0,
          0.0,
          0.95,
          0.0,
          0.0,
          15.0,
          0.0,
          0.0,
          1.1,
          0.0,
          10.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ],
      },
      {
        'name': 'Glow',
        'matrix': [
          1.1,
          0.0,
          0.0,
          0.0,
          25.0,
          0.0,
          1.05,
          0.0,
          0.0,
          20.0,
          0.0,
          0.0,
          1.0,
          0.0,
          15.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ],
      },
      {
        'name': 'Haze',
        'matrix': [
          0.95,
          0.0,
          0.0,
          0.0,
          30.0,
          0.0,
          0.9,
          0.0,
          0.0,
          25.0,
          0.0,
          0.0,
          0.85,
          0.0,
          20.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ],
      },
    ],
    [
      {'name': 'Original', 'matrix': null},
      {
        'name': 'Forest',
        'matrix': [
          0.9,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.15,
          0.0,
          0.0,
          10.0,
          0.0,
          0.0,
          0.85,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ],
      },
      {
        'name': 'Mountain',
        'matrix': [
          0.95,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.95,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.1,
          0.0,
          5.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ],
      },
      {
        'name': 'Ocean',
        'matrix': [
          0.85,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.95,
          0.0,
          0.0,
          5.0,
          0.0,
          0.0,
          1.2,
          0.0,
          15.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ],
      },
    ],
    [
      {'name': 'Original', 'matrix': null},
      {
        'name': 'Romance',
        'matrix': [
          1.1,
          0.0,
          0.0,
          0.0,
          15.0,
          0.0,
          0.9,
          0.0,
          0.0,
          5.0,
          0.0,
          0.0,
          1.0,
          0.0,
          10.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ],
      },
      {
        'name': 'Pink',
        'matrix': [
          1.15,
          0.0,
          0.0,
          0.0,
          20.0,
          0.0,
          0.85,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.95,
          0.0,
          5.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ],
      },
      {
        'name': 'Warm',
        'matrix': [
          1.2,
          0.0,
          0.0,
          0.0,
          25.0,
          0.0,
          1.0,
          0.0,
          0.0,
          10.0,
          0.0,
          0.0,
          0.8,
          0.0,
          -10.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ],
      },
    ],
    [
      {'name': 'Original', 'matrix': null},
      {
        'name': 'Noir',
        'matrix': [
          0.33,
          0.59,
          0.11,
          0.0,
          0.0,
          0.33,
          0.59,
          0.11,
          0.0,
          0.0,
          0.33,
          0.59,
          0.11,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ],
      },
      {
        'name': 'Mono',
        'matrix': [
          0.3,
          0.6,
          0.1,
          0.0,
          0.0,
          0.3,
          0.6,
          0.1,
          0.0,
          0.0,
          0.3,
          0.6,
          0.1,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ],
      },
      {
        'name': 'Film',
        'matrix': [
          0.9,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.9,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.9,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ],
      },
    ],
    [
      {'name': 'Original', 'matrix': null},
      {
        'name': 'Retro',
        'matrix': [
          1.1,
          0.0,
          0.0,
          0.0,
          15.0,
          0.0,
          0.95,
          0.0,
          0.0,
          5.0,
          0.0,
          0.0,
          0.7,
          0.0,
          -15.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ],
      },
      {
        'name': 'Fade',
        'matrix': [
          0.8,
          0.0,
          0.0,
          0.0,
          40.0,
          0.0,
          0.8,
          0.0,
          0.0,
          35.0,
          0.0,
          0.0,
          0.8,
          0.0,
          30.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ],
      },
      {
        'name': 'Grain',
        'matrix': [
          0.95,
          0.0,
          0.0,
          0.0,
          10.0,
          0.0,
          0.9,
          0.0,
          0.0,
          10.0,
          0.0,
          0.0,
          0.85,
          0.0,
          10.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ],
      },
    ],
  ];
  List<Map<String, dynamic>> get currentFilters =>
      filtersByCategory[selectedCategory.value];
  List<double>? get currentFilterMatrix {
    final filter = currentFilters[selectedFilter.value];
    return filter['matrix'] as List<double>?;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args?['imageFile'] != null) {
      userImage = args!['imageFile'] as File;
    } else {
      errorToast('No image selected');
      Get.back();
    }
  }

  void onCategoryTap(int index) {
    selectedCategory.value = index;
    selectedFilter.value = 0;
  }

  void onFilterTap(int index) {
    selectedFilter.value = index;
  }

  Future<void> onSaveTap() async {
    if (!userImage.existsSync()) {
      errorToast('No image to save');
      return;
    }
    try {
      isLoading.value = true;
      loadingMessage.value = 'Processing...';
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
        name: 'art_filter_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (result['isSuccess'] == true) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath =
            '${directory.path}/art_filter_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);
        savedImagePath.value = filePath;
        await _database.insertHistoryRecord(
          HistoryRecord(
            imagePath: filePath,
            featureType: 'art_filter',
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
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10.w),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF2C3E50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                          openAppSettings();
                        },
                        child: Container(
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B9D),
                            borderRadius: BorderRadius.circular(10.w),
                          ),
                          child: Center(
                            child: Text(
                              'Go to Settings',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
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
        text: 'Check out my artistic photo!',
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
