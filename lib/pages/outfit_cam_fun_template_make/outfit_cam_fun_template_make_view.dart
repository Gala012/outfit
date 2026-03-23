import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'outfit_cam_fun_template_make_logic.dart';
class OutfitCamFunTemplateMakeView
    extends GetView<OutfitCamFunTemplateMakeLogic> {
  const OutfitCamFunTemplateMakeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          _buildTopBar(),
          _buildBottomBar(),
          _buildLoadingOverlay(),
        ],
      ),
    );
  }
  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
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
          ),
        ),
      ),
    );
  }
  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
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
                  Icon(Icons.auto_fix_high, color: Colors.white, size: 20.w),
                  SizedBox(width: 8.w),
                  Text(
                    'Create Now',
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
}
