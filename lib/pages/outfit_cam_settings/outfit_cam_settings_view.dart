import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'outfit_cam_settings_logic.dart';

class OutfitCamSettingsView extends GetView<OutfitCamSettingsLogic> {
  const OutfitCamSettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back_ios_new, size: 20.w),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16.h),
          _buildSettingItem(
            icon: Icons.history,
            iconColor: secondaryColor,
            title: 'History',
            subtitle: 'View saved photos',
            onTap: controller.onHistoryTap,
          ),
          const Spacer(),
          _buildVersionInfo(),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10.w),
              ),
              child: Icon(icon, color: iconColor, size: 22.w),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: textColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20.w,
              color: textColor.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Obx(
      () => Text(
        controller.appVersion.value.isEmpty
            ? 'Version 1.0.0'
            : controller.appVersion.value,
        style: TextStyle(fontSize: 13.sp, color: textColor.withOpacity(0.4)),
      ),
    );
  }
}
