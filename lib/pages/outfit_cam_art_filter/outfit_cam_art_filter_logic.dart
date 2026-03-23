import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/index.dart';

class OutfitCamArtFilterLogic extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final isLoading = false.obs;
  Future<void> onMakeTap() async {
    try {
      final result = await _showImageSourceDialog();
      if (result == null) return;
      isLoading.value = true;
      XFile? pickedFile;
      if (result == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          isLoading.value = false;
          _showPermissionDialog('Camera');
          return;
        }
        pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front,
        );
      } else {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          isLoading.value = false;
          _showPermissionDialog('Photo Library');
          return;
        }
        pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      }
      isLoading.value = false;
      if (pickedFile != null) {
        Get.toNamed(
          '/art_filter_edit',
          arguments: {'imageFile': File(pickedFile.path)},
        );
      }
    } catch (e) {
      isLoading.value = false;
      errorToast('Failed to select image: ${e.toString()}');
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await Get.dialog<ImageSource>(
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
                  Icons.image_outlined,
                  size: 64.w,
                  color: const Color(0xFFFF6B9D),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildSourceButton(
                        'Camera',
                        Icons.camera_alt_outlined,
                        () => Get.back(result: ImageSource.camera),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildSourceButton(
                        'Gallery',
                        Icons.photo_library_outlined,
                        () => Get.back(result: ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                GestureDetector(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSourceButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B9D),
          borderRadius: BorderRadius.circular(10.w),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20.w),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionDialog(String permissionName) {
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
                  Icons.warning_amber_rounded,
                  size: 64.w,
                  color: const Color(0xFFFF6B9D),
                ),
                SizedBox(height: 16.h),
                Text(
                  '$permissionName Permission Required',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please enable $permissionName access in settings',
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
                              'Settings',
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
}
