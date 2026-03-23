import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'outfit_cam_onboarding_logic.dart';
class OutfitCamOnboardingView extends GetView<OutfitCamOnboardingLogic> {
  const OutfitCamOnboardingView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          PageView.builder(
            itemCount: controller.pages.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (context, index) {
              final page = controller.pages[index];
              return _buildPage(page);
            },
          ),
          _buildTopBar(),
          _buildBottomBar(),
        ],
      ),
    );
  }
  Widget _buildPage(Map<String, String> page) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFEEE5FF),
            ),
            child: Image.asset(
              page['image']!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFEEE5FF),
                child: Icon(Icons.image_outlined, size: 80.w, color: secondaryColor),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  page['title']!,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  page['subtitle']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: textColor.withOpacity(0.6),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 120.h),
      ],
    );
  }
  Widget _buildTopBar() {
    return Positioned(
      top: 60.h,
      right: 24.w,
      child: GestureDetector(
        onTap: controller.onSkipTap,
        child: Text(
          'Skip',
          style: TextStyle(
            fontSize: 15.sp,
            color: textColor.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
  Widget _buildBottomBar() {
    return Positioned(
      bottom: 48.h,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(controller.pages.length, (index) {
              final isActive = index == controller.currentPage.value;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: isActive ? 24.w : 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: isActive ? primaryColor : primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4.w),
                ),
              );
            }),
          )),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Obx(() => GestureDetector(
              onTap: controller.onNextTap,
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
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    controller.currentPage.value == controller.pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}
