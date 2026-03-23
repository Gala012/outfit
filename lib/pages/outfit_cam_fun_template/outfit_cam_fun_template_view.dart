import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'outfit_cam_fun_template_logic.dart';

class OutfitCamFunTemplateView extends GetView<OutfitCamFunTemplateLogic> {
  const OutfitCamFunTemplateView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Scene Templates'),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back_ios_new, size: 20.w),
        ),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.75,
        ),
        itemCount: controller.templates.length,
        itemBuilder: (context, index) {
          final template = controller.templates[index];
          return GestureDetector(
            onTap: () => controller.onTemplateTap(index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.w),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    template['image']!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: secondaryColor.withOpacity(0.2),
                      child: Icon(
                        Icons.landscape_outlined,
                        size: 48.w,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10.w, 20.h, 10.w, 10.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                      child: Text(
                        template['title']!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
