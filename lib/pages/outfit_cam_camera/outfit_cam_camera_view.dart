import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'outfit_cam_camera_logic.dart';

class OutfitCamCameraView extends GetView<OutfitCamCameraLogic> {
  const OutfitCamCameraView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildCameraPreview(),
                _buildViewfinder(),
                _buildTopBar(),
                _buildGuidanceText(),
                _buildFirstTimeGuide(),
                _buildLoadingOverlay(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Obx(() {
      final cameraController = controller.cameraController.value;
      final isInitialized = controller.isCameraInitialized.value;
      if (!isInitialized || cameraController == null) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF1A1A2E),
          child: Center(
            child: Icon(
              Icons.camera_alt_outlined,
              size: 80.w,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        );
      }
      final aspectRatio = cameraController.value.aspectRatio;
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: aspectRatio * 100,
            child: CameraPreview(cameraController),
          ),
        ),
      );
    });
  }

  Widget _buildViewfinder() {
    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: Center(
          child: SizedBox(
            width: 240.w,
            height: 310.h,
            child: CustomPaint(painter: _DashedOvalPainter()),
          ),
        ),
      ),
    );
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidanceText() {
    return Positioned(
      bottom: 12.h,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.w),
          ),
          child: Text(
            'Please place your face inside the circle',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomIconButton(
              icon: Icons.photo_library_outlined,
              label: 'Album',
              onTap: controller.pickFromGallery,
            ),
            _buildShutterButton(),
            Obx(
              () => _buildBottomIconButton(
                icon: controller.isFrontCamera.value
                    ? Icons.flip_camera_ios
                    : Icons.flip_camera_ios_outlined,
                label: 'Flip',
                onTap: controller.toggleCamera,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShutterButton() {
    return GestureDetector(
      onTap: controller.takePicture,
      child: Container(
        width: 72.w,
        height: 72.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3.w),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28.w),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstTimeGuide() {
    return Obx(() {
      if (!controller.showFirstTimeGuide.value) {
        return const SizedBox.shrink();
      }
      return Positioned(
        top: MediaQuery.of(Get.context!).size.height * 0.35,
        left: 0,
        right: 0,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 32.w),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16.w),
            border: Border.all(color: primaryColor.withOpacity(0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: primaryColor, size: 24.w),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Quick Guide',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.closeGuide,
                    child: Icon(Icons.close, color: Colors.white, size: 20.w),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'Align your face within the circle for best results. After taking photo, choose a cartoon head template to apply.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    });
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
                      controller.loadingText.value,
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
}

class _DashedOvalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final path = Path();
    final centerX = size.width / 2;
    final topY = size.height * 0.05;
    final bottomY = size.height * 0.90;
    path.moveTo(centerX, topY);
    path.cubicTo(
      size.width * 0.9,
      size.height * 0.1,
      size.width * 0.95,
      size.height * 0.25,
      size.width * 0.92,
      size.height * 0.45,
    );
    path.cubicTo(
      size.width * 0.88,
      size.height * 0.6,
      size.width * 0.65,
      size.height * 0.82,
      size.width * 0.55,
      bottomY,
    );
    path.cubicTo(
      size.width * 0.52,
      size.height * 0.92,
      size.width * 0.48,
      size.height * 0.92,
      size.width * 0.45,
      bottomY,
    );
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.82,
      size.width * 0.12,
      size.height * 0.6,
      size.width * 0.08,
      size.height * 0.45,
    );
    path.cubicTo(
      size.width * 0.05,
      size.height * 0.25,
      size.width * 0.1,
      size.height * 0.1,
      centerX,
      topY,
    );
    final dashArray = [12.0, 8.0];
    _drawDashedPath(canvas, path, dashArray, paint);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    List<double> dashArray,
    Paint paint,
  ) {
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < pathMetric.length) {
        final length = dashArray[draw ? 0 : 1];
        final segment = pathMetric.extractPath(distance, distance + length);
        if (draw) {
          canvas.drawPath(segment, paint);
        }
        distance += length;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
