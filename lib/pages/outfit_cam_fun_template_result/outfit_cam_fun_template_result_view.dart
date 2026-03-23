import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'outfit_cam_fun_template_result_logic.dart';
class OutfitCamFunTemplateResultView
    extends GetView<OutfitCamFunTemplateResultLogic> {
  const OutfitCamFunTemplateResultView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildPreviewArea()),
              _buildBottomToolbar(),
            ],
          ),
          _buildTopBar(),
          _buildLoadingOverlay(),
          _buildSaveSuccessDialog(),
        ],
      ),
    );
  }
  Widget _buildPreviewArea() {
    return RepaintBoundary(
      key: controller.previewKey,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            controller.templateImage,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF1A1A2E),
              child: Icon(
                Icons.landscape_outlined,
                size: 100.w,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
          _buildPortraitLayer(),
        ],
      ),
    );
  }
  Widget _buildPortraitLayer() {
    return Obx(() {
      if (!controller.portraitFile.existsSync()) {
        return const SizedBox.shrink();
      }
      return Center(
        child: Transform.translate(
          offset: controller.portraitPosition.value,
          child: Transform.rotate(
            angle: controller.portraitRotation.value,
            child: Transform.scale(
              scale: controller.portraitScale.value,
              child: Transform(
                transform: controller.portraitFlipped.value
                    ? (Matrix4.identity()..setEntry(0, 0, -1.0))
                    : Matrix4.identity(),
                alignment: Alignment.center,
                child: GestureDetector(
                  onScaleStart: controller.onPortraitScaleStart,
                  onScaleUpdate: controller.onPortraitScaleUpdate,
                  child: Image.file(
                    controller.portraitFile,
                    fit: BoxFit.contain,
                    width: 280.w,
                    height: 280.w,
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
                onTap: () => Get.back(),
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
              GestureDetector(
                onTap: controller.onSaveTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryColor, Color(0xFFFF8FAB)],
                    ),
                    borderRadius: BorderRadius.circular(20.w),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildBottomToolbar() {
    return SafeArea(
      top: false,
      child: Container(
        color: const Color(0xFF111111),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 60.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildToolButton(
                    icon: Icons.rotate_90_degrees_ccw,
                    label: 'Rotate',
                    onTap: controller.onRotate90Degrees,
                  ),
                  _buildToolButton(
                    icon: Icons.flip,
                    label: 'Flip',
                    onTap: controller.onFlipTap,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: controller.onRemakeTap,
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24.h),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Redo',
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: controller.onSaveTap,
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [primaryColor, Color(0xFFFF8FAB)],
                          ),
                          borderRadius: BorderRadius.circular(24.h),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Save to Album',
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.w)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20.w),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(fontSize: 10.sp, color: Colors.white),
            ),
          ],
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
    return Obx(
      () => controller.showSaveSuccess.value
          ? _SaveSuccessOverlay(onClose: controller.onCloseSaveDialog)
          : const SizedBox.shrink(),
    );
  }
}
class _SaveSuccessOverlay extends StatelessWidget {
  final VoidCallback onClose;
  const _SaveSuccessOverlay({required this.onClose});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OutfitCamFunTemplateResultLogic>();
    return Container(
      color: Colors.black.withOpacity(0.6),
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
                width: 56.w,
                height: 56.w,
                decoration: const BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 32.w),
              ),
              SizedBox(height: 16.h),
              Text(
                'Saved to Album',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 20.h),
              Obx(() {
                final imagePath = controller.savedImagePath.value;
                return Container(
                  height: 120.h,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: imagePath.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.w),
                          child: Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 48.w,
                            color: Colors.grey,
                          ),
                        ),
                );
              }),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: _btn(
                      'History',
                      Colors.grey[100]!,
                      textColor,
                      controller.onViewHistoryTap,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _btn(
                      'Share',
                      secondaryColor,
                      Colors.white,
                      controller.onShareTap,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _btn('Done', primaryColor, Colors.white, onClose),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _btn(String label, Color bg, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42.h,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10.w),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
