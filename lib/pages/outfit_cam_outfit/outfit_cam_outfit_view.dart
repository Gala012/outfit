import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'outfit_cam_outfit_logic.dart';

class OutfitCamOutfitView extends GetView<OutfitCamOutfitLogic> {
  const OutfitCamOutfitView({super.key});
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(child: _buildPreviewArea()),
                SafeArea(top: false, child: _buildBottomTemplateBar()),
              ],
            ),
            _buildTopBar(),
            _buildLoadingOverlay(),
            _buildSaveSuccessDialog(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewArea() {
    return RepaintBoundary(
      key: controller.previewKey,
      child: Obx(() {
        final faceOnTop = controller.faceOnTop.value;
        final selectedIndex = controller.selectedTemplate.value;

        final backgroundWidget = Image.asset(
          controller.backgroundTemplates[selectedIndex],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(color: const Color(0xFF1A1A2E)),
        );

        final templateWidget = Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 450.h,
            child: Image.asset(
              controller.getCurrentTemplate(),
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.transparent,
                child: Icon(
                  Icons.person_outline,
                  size: 120.w,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ),
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            backgroundWidget,
            if (faceOnTop) ...[
              templateWidget,
              _buildFaceLayer(),
            ] else ...[
              _buildFaceLayer(),
              templateWidget,
            ],
          ],
        );
      }),
    );
  }

  Widget _buildFaceLayer() {
    return Obx(() {
      final hasFace = controller.faceDetected.value;
      final faceFile = controller.faceImage.value;
      final isCropMode = controller.isCropMode.value;
      return Center(
        child: Transform.translate(
          offset: controller.facePosition.value,
          child: Transform.rotate(
            angle: controller.faceRotation.value,
            child: Transform.scale(
              scale: controller.faceScale.value,
              child: Transform(
                transform: controller.faceFlipped.value
                    ? (Matrix4.identity()..setEntry(0, 0, -1.0))
                    : Matrix4.identity(),
                alignment: Alignment.center,
                child: GestureDetector(
                  onScaleStart: hasFace ? controller.onFaceScaleStart : null,
                  onScaleUpdate: hasFace ? controller.onFaceScaleUpdate : null,
                  child: Container(
                    width: 280.w,
                    height: 280.w,
                    decoration: BoxDecoration(
                      border: isCropMode
                          ? Border.all(
                              color: primaryColor.withOpacity(0.8),
                              width: 3,
                              style: BorderStyle.solid,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(16.w),
                    ),
                    child: CustomPaint(
                      painter: isCropMode
                          ? _CropGridPainter(
                              color: primaryColor.withOpacity(0.6),
                              strokeWidth: 1.5,
                              borderRadius: 16.w,
                            )
                          : null,
                      child: Stack(
                        children: [
                          if (hasFace && faceFile != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(13.w),
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: Image.file(
                                  faceFile,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(13.w),
                              ),
                            ),
                          if (!hasFace && !isCropMode)
                            Center(
                              child: GestureDetector(
                                onTap: controller.onChangeImageTap,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(25.w),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'Add Face',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (isCropMode)
                            Positioned(
                              top: -40.h,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(15.w),
                                  ),
                                  child: Text(
                                    'Drag to move • Pinch to zoom',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (isCropMode)
                            Positioned(
                              bottom: -60.h,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: controller.onCancelCrop,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24.w,
                                        vertical: 10.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(
                                          25.w,
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.5),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  GestureDetector(
                                    onTap: controller.onConfirmCrop,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24.w,
                                        vertical: 10.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(
                                          25.w,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryColor.withOpacity(
                                              0.4,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'Done',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
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
          child: Obx(
            () => Row(
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
                if (!controller.isCropMode.value)
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
                  )
                else
                  SizedBox(width: 40.w),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTemplateBar() {
    return Container(
      color: const Color(0xFF111111),
      child: Column(
        children: [
          _buildToolbar(),
          SizedBox(
            height: 110.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 0, 6.h),
                  child: Text(
                    'Templates',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    itemCount: controller.originalTemplates.length,
                    itemBuilder: (context, index) {
                      return Obx(() {
                        final isSelected =
                            controller.selectedTemplate.value == index;
                        return GestureDetector(
                          onTap: () => controller.onTemplateTap(index),
                          child: Container(
                            width: 56.w,
                            height: 56.w,
                            margin: EdgeInsets.only(right: 8.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.w),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.w),
                              child: Image.asset(
                                controller.originalTemplates[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFF2A2A2A),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white.withOpacity(0.3),
                                    size: 24.w,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Obx(() {
      final hasFace = controller.faceDetected.value;
      final faceOnTop = controller.faceOnTop.value;
      final isCropMode = controller.isCropMode.value;
      return Container(
        height: 60.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildToolButton(
              icon: Icons.photo_library_outlined,
              label: hasFace ? 'Change' : 'Add Face',
              enabled: !isCropMode,
              onTap: controller.onChangeImageTap,
            ),
            _buildToolButton(
              icon: Icons.crop,
              label: 'Crop',
              enabled: hasFace && !isCropMode,
              onTap: controller.onEnterCropMode,
            ),
            _buildToolButton(
              icon: Icons.rotate_90_degrees_ccw,
              label: 'Rotate',
              enabled: hasFace && !isCropMode,
              onTap: controller.onRotate90Degrees,
            ),
            _buildToolButton(
              icon: Icons.flip,
              label: 'Flip',
              enabled: hasFace && !isCropMode,
              onTap: controller.onFlipTap,
            ),
            _buildToolButton(
              icon: faceOnTop ? Icons.layers : Icons.layers_outlined,
              label: faceOnTop ? 'Top' : 'Back',
              enabled: hasFace && !isCropMode,
              onTap: controller.onToggleLayer,
              isActive: !faceOnTop,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.w),
          border: isActive
              ? Border.all(color: primaryColor.withOpacity(0.5), width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: enabled
                  ? (isActive ? primaryColor : Colors.white)
                  : Colors.white.withOpacity(0.3),
              size: 20.w,
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: enabled
                    ? (isActive ? primaryColor : Colors.white)
                    : Colors.white.withOpacity(0.3),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
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
                    const CircularProgressIndicator(color: primaryColor),
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
          ? _SaveSuccessDialog(onClose: controller.onCloseSaveDialog)
          : const SizedBox.shrink(),
    );
  }
}

class _SaveSuccessDialog extends StatelessWidget {
  final VoidCallback onClose;
  const _SaveSuccessDialog({required this.onClose});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OutfitCamOutfitLogic>();
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
                    child: _dialogButton(
                      'History',
                      Colors.grey[100]!,
                      textColor,
                      controller.onViewHistoryTap,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _dialogButton(
                      'Share',
                      secondaryColor,
                      Colors.white,
                      controller.onShareTap,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _dialogButton(
                      'Done',
                      primaryColor,
                      Colors.white,
                      onClose,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogButton(String label, Color bg, Color fg, VoidCallback onTap) {
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

class _CropGridPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;
  _CropGridPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final width = size.width;
    final height = size.height;
    canvas.drawLine(Offset(width / 3, 0), Offset(width / 3, height), paint);
    canvas.drawLine(
      Offset(width * 2 / 3, 0),
      Offset(width * 2 / 3, height),
      paint,
    );
    canvas.drawLine(Offset(0, height / 3), Offset(width, height / 3), paint);
    canvas.drawLine(
      Offset(0, height * 2 / 3),
      Offset(width, height * 2 / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
