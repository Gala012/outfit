import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'outfit_cam_home_logic.dart';

class OutfitCamHomeView extends GetView<OutfitCamHomeLogic> {
  const OutfitCamHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBannerCarousel(),
                  SizedBox(height: 24.h),
                  _buildOutfitEntry(),
                  SizedBox(height: 14.h),
                  _buildBottomGrid(),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
            _buildSettingsButton(),
            _buildCameraButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsButton() {
    return Positioned(
      top: 42.h,
      right: 16.w,
      child: GestureDetector(
        onTap: controller.onSettingsTap,
        child: Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(50.w),
          ),
          child: Icon(Icons.settings_outlined, size: 22.w, color: textColor),
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return SizedBox(
      height: 260.h,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: controller.banners.length,
            onPageChanged: controller.onBannerChanged,
            itemBuilder: (context, index) {
              final banner = controller.banners[index];
              return GestureDetector(
                onTap: () => controller.onBannerTap(banner['route']!),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      banner['backgroundImage']!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF5E78), Color(0xFF9F7AEA)],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 32.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  banner['title']!,
                                  style: TextStyle(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  banner['subtitle']!,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white.withOpacity(0.9),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 180.w,
                          padding: EdgeInsets.only(top: 24.h),
                          child: Image.asset(
                            banner['characterImage']!,
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomRight,
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 10.h,
            left: 0,
            right: 0,
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(controller.banners.length, (index) {
                  final isActive = index == controller.currentBanner.value;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    width: isActive ? 20.w : 6.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitEntry() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GestureDetector(
        onTap: controller.onOutfitTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.w),
            child: Column(
              children: [
                SizedBox(
                  height: 172.h,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Image.asset(
                              'assets/images/cover/cover_1.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFEEE5FF),
                                child: Icon(
                                  Icons.person_outline,
                                  size: 60.w,
                                  color: secondaryColor,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Image.asset(
                              'assets/images/cover/cover_2.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFFFE5EA),
                                child: Icon(
                                  Icons.person,
                                  size: 60.w,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 2.w,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(color: const Color(0xFF15A78E)),
                  child: Text(
                    'Fun Outfit',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildBottomGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: _buildGridCard(
              title: 'Scene Templates',
              image: 'assets/images/cover/cover_3.png',
              backgroundColor: const Color(0xFFFF5E78),
              onTap: controller.onFunTemplateTap,
            ),
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: _buildGridCard(
              title: 'Art Filters',
              image: 'assets/images/cover/cover_4.jpg',
              backgroundColor: const Color(0xFFFFB366),
              onTap: controller.onArtFilterTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard({
    required String title,
    required String image,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.w),
          child: Column(
            children: [
              SizedBox(
                height: 150.h,
                width: double.infinity,
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: backgroundColor.withOpacity(0.3),
                    child: Icon(
                      Icons.image,
                      size: 40.w,
                      color: backgroundColor,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(color: backgroundColor),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraButton() {
    return Positioned(
      bottom: 18.h,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: controller.onCameraTap,
          child: Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, Color(0xFFFF8FAB)],
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(Icons.camera_alt, color: Colors.white, size: 28.w),
          ),
        ),
      ),
    );
  }
}
