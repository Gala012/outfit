import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'outfit_cam_art_filter_logic.dart';

class OutfitCamArtFilterView extends GetView<OutfitCamArtFilterLogic> {
  const OutfitCamArtFilterView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 20.w,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Art Filters',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(children: [Expanded(child: _buildComparePreview())]),
          _buildBottomButton(),
          _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildComparePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Row(
          children: [
            Expanded(
              child: Image.asset(
                'assets/images/filter_samples/filter_samples_01.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[900],
                  child: Icon(
                    Icons.image_outlined,
                    size: 60.w,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.33,
                  0.59,
                  0.11,
                  0,
                  0,
                  0.33,
                  0.59,
                  0.11,
                  0,
                  0,
                  0.33,
                  0.59,
                  0.11,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                ]),
                child: Image.asset(
                  'assets/images/filter_samples/filter_samples_01.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[800],
                    child: Icon(
                      Icons.image_outlined,
                      size: 60.w,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Center(
          child: Container(
            width: 2.w,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
              ],
            ),
          ),
        ),
        Positioned(
          top: 16.h,
          left: 16.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Text(
              'Original',
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ),
        ),
        Positioned(
          top: 16.h,
          right: 16.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Text(
              'Filter',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
          child: GestureDetector(
            onTap: controller.onMakeTap,
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
                  Icon(Icons.auto_awesome, color: Colors.white, size: 20.w),
                  SizedBox(width: 8.w),
                  Text(
                    'Free Create',
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
                      'Loading...',
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
