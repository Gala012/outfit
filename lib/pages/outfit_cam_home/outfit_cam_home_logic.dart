import 'package:get/get.dart';

class OutfitCamHomeLogic extends GetxController {
  final currentBanner = 0.obs;
  final banners = [
    {
      'backgroundImage': 'assets/images/banners/banners_bg_01.jpg',
      'characterImage': 'assets/images/banners/banners_01.png',
      'title': 'Fun Outfit',
      'subtitle': 'Experience different looks',
      'route': '/outfit_outfit',
    },
    {
      'backgroundImage': 'assets/images/banners/banners_bg_02.jpg',
      'characterImage': 'assets/images/banners/banners_02.png',
      'title': 'Art Filters',
      'subtitle': 'Feel different styles',
      'route': '/art_filter',
    },
    {
      'backgroundImage': 'assets/images/banners/banners_bg_03.jpg',
      'characterImage': 'assets/images/banners/banners_03.png',
      'title': 'Scene Templates',
      'subtitle': 'One tap to create amazing photos',
      'route': '/outfit_fun_template',
    },
  ];
  void onBannerChanged(int index) {
    currentBanner.value = index;
  }

  void onBannerTap(String route) {
    Get.toNamed(route);
  }

  void onOutfitTap() {
    Get.toNamed('/outfit_outfit');
  }

  void onFunTemplateTap() {
    Get.toNamed('/outfit_fun_template');
  }

  void onArtFilterTap() {
    Get.toNamed('/art_filter');
  }

  void onCameraTap() {
    Get.toNamed('/outfit_camera');
  }

  void onSettingsTap() {
    Get.toNamed('/outfit_settings');
  }
}
