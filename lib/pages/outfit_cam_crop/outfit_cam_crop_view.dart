import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:crop_your_image/crop_your_image.dart';
import '../../main.dart';
import 'outfit_cam_crop_logic.dart';

class OutfitCamCropView extends GetView<OutfitCamCropLogic> {
  const OutfitCamCropView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildCropArea()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            'Crop Face',
            style: TextStyle(
              fontSize: 17.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Obx(
            () => GestureDetector(
              onTap: controller.isProcessing.value
                  ? null
                  : controller.onCropPressed,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: controller.isProcessing.value
                      ? Colors.grey
                      : primaryColor,
                  borderRadius: BorderRadius.circular(20.w),
                ),
                child: controller.isProcessing.value
                    ? SizedBox(
                        width: 40.w,
                        height: 20.h,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropArea() {
    return Obx(() {
      final imageData = controller.imageData.value;
      if (imageData == null) {
        return const Center(
          child: CircularProgressIndicator(color: primaryColor),
        );
      }
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Crop(
          controller: controller.cropController,
          image: imageData,
          aspectRatio: null,
          baseColor: Colors.black,
          maskColor: Colors.black.withOpacity(0.7),
          radius: 16,
          onCropped: controller.onImageCropped,
          withCircleUi: false,
          cornerDotBuilder: (size, edgeAlignment) =>
              DotControl(color: primaryColor, size: size),
          interactive: true,
          fixCropRect: false,
          formatDetector: (image) {
            return ImageFormat.png;
          },
        ),
      );
    });
  }
}

class DotControl extends StatelessWidget {
  final Color color;
  final double size;
  const DotControl({super.key, required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    final dotSize = size * 1.4;
    return Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
