import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../main.dart';
import 'outfit_cam_select_photo_logic.dart';
class OutfitCamSelectPhotoView extends GetView<OutfitCamSelectPhotoLogic> {
  const OutfitCamSelectPhotoView({super.key});
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(),
                Expanded(child: _buildPhotoGrid()),
              ],
            ),
            _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }
  Widget _buildAppBar() {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: textColor, size: 20.w),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Select Photo',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: controller.takePhoto,
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.camera_alt, color: Colors.white, size: 20.w),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPhotoGrid() {
    return Obx(() {
      if (controller.isLoadingPhotos.value) {
        return const Center(
          child: CircularProgressIndicator(color: primaryColor),
        );
      }
      if (controller.photos.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 80.w,
                color: Colors.grey[300],
              ),
              SizedBox(height: 16.h),
              Text(
                'No photos found',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }
      return GridView.builder(
        padding: EdgeInsets.all(2.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2.w,
          mainAxisSpacing: 2.w,
        ),
        itemCount: controller.photos.length,
        itemBuilder: (context, index) {
          final AssetEntity asset = controller.photos[index];
          return GestureDetector(
            onTap: () => controller.selectPhoto(asset),
            child: AssetEntityWidget(asset: asset),
          );
        },
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
class AssetEntityWidget extends StatelessWidget {
  final AssetEntity asset;
  final double? width;
  final double? height;
  const AssetEntityWidget({
    super.key,
    required this.asset,
    this.width,
    this.height,
  });
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize.square(300)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
        }
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Icon(Icons.image, color: Colors.grey[400], size: 40.w),
        );
      },
    );
  }
}
