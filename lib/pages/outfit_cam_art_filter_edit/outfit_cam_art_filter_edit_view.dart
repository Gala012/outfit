import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'outfit_cam_art_filter_edit_logic.dart';

class OutfitCamArtFilterEditView extends GetView<OutfitCamArtFilterEditLogic> {
  const OutfitCamArtFilterEditView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildPreviewArea()),
              _buildFilterPanel(),
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
      child: Obx(() {
        if (!controller.userImage.existsSync()) {
          return Container(
            color: const Color(0xFF1A1A2E),
            child: Center(
              child: Icon(
                Icons.image_outlined,
                size: 80.w,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          );
        }
        final filterMatrix = controller.currentFilterMatrix;
        final userImageWidget = Image.file(
          controller.userImage,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF1A1A2E),
            child: Icon(
              Icons.broken_image_outlined,
              size: 80.w,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        );
        if (filterMatrix == null) {
          return userImageWidget;
        }
        return ColorFiltered(
          colorFilter: ColorFilter.matrix(filterMatrix),
          child: userImageWidget,
        );
      }),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      color: const Color(0xFF111111),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCategoryTabs(),
          _buildFilterList(),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 42.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final isActive = controller.selectedCategory.value == index;
            return GestureDetector(
              onTap: () => controller.onCategoryTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? secondaryColor
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.w),
                ),
                alignment: Alignment.center,
                child: Text(
                  controller.categories[index],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.6),
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildFilterList() {
    return SizedBox(
      height: 90.h,
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          itemCount: controller.currentFilters.length,
          itemBuilder: (context, index) {
            final filter = controller.currentFilters[index];
            final isSelected = controller.selectedFilter.value == index;
            final filterMatrix = filter['matrix'] as List<double>?;
            return GestureDetector(
              onTap: () => controller.onFilterTap(index),
              child: Container(
                width: 64.w,
                margin: EdgeInsets.only(right: 8.w),
                child: Column(
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.w),
                        border: Border.all(
                          color: isSelected ? primaryColor : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.w),
                        child: _buildFilterThumbnail(filterMatrix),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      filter['name']!,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isSelected
                            ? primaryColor
                            : Colors.white.withOpacity(0.6),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterThumbnail(List<double>? filterMatrix) {
    if (!controller.userImage.existsSync()) {
      return Container(color: const Color(0xFF2A2A2A));
    }
    final imageWidget = Image.file(
      controller.userImage,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: const Color(0xFF2A2A2A)),
    );
    if (filterMatrix == null) {
      return imageWidget;
    }
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(filterMatrix),
      child: imageWidget,
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
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryColor, Color(0xFFFF8FAB)],
                    ),
                    borderRadius: BorderRadius.circular(20.w),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 15.sp,
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
    final controller = Get.find<OutfitCamArtFilterEditLogic>();
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
