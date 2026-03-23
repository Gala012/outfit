import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'outfit_cam_cartoon_head_logic.dart';

class OutfitCamCartoonHeadView extends GetView<OutfitCamCartoonHeadLogic> {
  const OutfitCamCartoonHeadView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildPhotoBackground(),
          _buildCartoonHeadOverlay(),
          _buildTopBar(),
          _buildActionButtons(),
          _buildLoadingOverlay(),
          _buildSaveSuccessDialog(),
        ],
      ),
    );
  }

  Widget _buildPhotoBackground() {
    return Obx(() {
      final photo = controller.photoImage.value;
      if (photo == null) {
        return Container(
          color: const Color(0xFF1A1A2E),
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: 80.w,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        );
      }
      return Image.file(
        photo,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    });
  }

  Widget _buildCartoonHeadOverlay() {
    return Obx(() {
      final templatePath = controller.templatePath.value;
      if (templatePath.isEmpty) return const SizedBox.shrink();
      return Center(
        child: GestureDetector(
          onScaleStart: controller.onHeadScaleStart,
          onScaleUpdate: controller.onHeadScaleUpdate,
          child: Transform.translate(
            offset: controller.headPosition.value,
            child: Transform.rotate(
              angle: controller.headRotation.value,
              child: Transform.scale(
                scaleX:
                    (controller.headFlipped.value ? -1 : 1) *
                    controller.headScale.value,
                scaleY: controller.headScale.value,
                child: Image.asset(
                  templatePath,
                  width: 200.w,
                  height: 200.w,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 200.w,
                    height: 200.w,
                    color: Colors.transparent,
                    child: Icon(
                      Icons.face,
                      size: 120.w,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: controller.onBackTap,
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18.w,
                  ),
                ),
              ),
              Text(
                'Cartoon Head',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 40.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
          child: GestureDetector(
            onTap: controller.onSaveTap,
            child: Container(
              width: double.infinity,
              height: 52.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryColor, Color(0xFFFF8FAB)],
                ),
                borderRadius: BorderRadius.circular(26.h),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, color: Colors.white, size: 20.w),
                  SizedBox(width: 8.w),
                  Text(
                    'Save to Album',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Obx(
      () => controller.isLoading.value
          ? Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      controller.loadingMessage.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildSaveSuccessDialog() {
    return Obx(() {
      if (!controller.showSaveSuccess.value) {
        return const SizedBox.shrink();
      }
      return Container(
        color: Colors.black.withOpacity(0.8),
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
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 40.w,
                    color: accentColor,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Saved Successfully!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Your cartoon head photo has been saved to album',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 24.h),
                if (controller.savedImagePath.value.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.w),
                    child: Image.file(
                      File(controller.savedImagePath.value),
                      width: 200.w,
                      height: 200.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogButton(
                        'History',
                        Colors.grey[200]!,
                        textColor,
                        controller.onViewHistoryTap,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildDialogButton(
                        'Share',
                        secondaryColor,
                        Colors.white,
                        controller.onShareTap,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: controller.onDoneTap,
                  child: Container(
                    width: double.infinity,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Center(
                      child: Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
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
