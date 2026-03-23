import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'outfit_cam_history_logic.dart';

class OutfitCamHistoryView extends GetView<OutfitCamHistoryLogic> {
  const OutfitCamHistoryView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('History'),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back_ios_new, size: 20.w),
        ),
        actions: [
          Obx(() {
            if (controller.historyRecords.isEmpty) {
              return const SizedBox.shrink();
            }
            return GestureDetector(
              onTap: controller.onDeleteAllRecords,
              child: Container(
                margin: EdgeInsets.only(right: 16.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline, size: 18.w, color: Colors.red),
                    SizedBox(width: 4.w),
                    Text(
                      'Delete All',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }
        if (controller.historyRecords.isEmpty) {
          return _buildEmptyState();
        }
        return Stack(children: [_buildGrid(), _buildFullscreenViewer()]);
      }),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: secondaryColor),
          SizedBox(height: 16.h),
          Text(
            'Loading history...',
            style: TextStyle(
              fontSize: 14.sp,
              color: textColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 40.w,
              color: secondaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No history yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your saved photos will appear here',
            style: TextStyle(
              fontSize: 13.sp,
              color: textColor.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(12.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: controller.historyRecords.length,
      itemBuilder: (context, index) {
        final record = controller.historyRecords[index];
        final imageFile = File(record.imagePath);
        return GestureDetector(
          onTap: () => controller.onImageTap(index),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.w),
                child: Container(
                  color: Colors.grey[200],
                  child: imageFile.existsSync()
                      ? Image.file(
                          imageFile,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => _buildErrorImage(),
                        )
                      : _buildErrorImage(),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8.w),
                      bottomRight: Radius.circular(8.w),
                    ),
                  ),
                  child: Text(
                    _formatDateTime(record.createdAt),
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Positioned(
                top: 4.h,
                right: 4.w,
                child: GestureDetector(
                  onTap: () => controller.onDeleteSingleRecord(index),
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 16.w),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 30.w,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildFullscreenViewer() {
    return Obx(() {
      if (!controller.showFullscreen.value) {
        return const SizedBox.shrink();
      }
      final selectedIndex = controller.selectedIndex.value;
      if (selectedIndex < 0 ||
          selectedIndex >= controller.historyRecords.length) {
        return const SizedBox.shrink();
      }
      final record = controller.historyRecords[selectedIndex];
      final imageFile = File(record.imagePath);
      return GestureDetector(
        onTap: controller.onCloseFullscreen,
        child: Container(
          color: Colors.black,
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    child: imageFile.existsSync()
                        ? Image.file(
                            imageFile,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.broken_image_outlined,
                              size: 80.w,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          )
                        : Icon(
                            Icons.broken_image_outlined,
                            size: 80.w,
                            color: Colors.white.withOpacity(0.3),
                          ),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  left: 16.w,
                  child: GestureDetector(
                    onTap: controller.onCloseFullscreen,
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 20.w),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16.h,
                  left: 16.w,
                  right: 16.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Created: ${_formatFullDateTime(record.createdAt)}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Type: ${_formatFeatureType(record.featureType)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  String _formatDateTime(String isoDateTime) {
    try {
      final dateTime = DateTime.parse(isoDateTime);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      if (difference.inDays == 0) {
        return 'Today ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
      }
    } catch (e) {
      return '';
    }
  }

  String _formatFullDateTime(String isoDateTime) {
    try {
      final dateTime = DateTime.parse(isoDateTime);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDateTime;
    }
  }

  String _formatFeatureType(String type) {
    switch (type) {
      case 'outfit':
        return 'Outfit Swap';
      case 'fun_template':
        return 'Fun Template';
      case 'cartoon_head':
        return 'Cartoon Head';
      case 'art_filter':
        return 'Art Filter';
      default:
        return type;
    }
  }
}
