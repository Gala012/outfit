import 'package:get/get.dart';
class OutfitCamOnboardingLogic extends GetxController {
  final currentPage = 0.obs;
  final pages = [
    {
      'image': 'assets/images/onboarding/onboarding_01.jpg',
      'title': 'Fun Outfit',
      'subtitle': 'Paste your face onto cartoon characters\nand experience different styles',
    },
    {
      'image': 'assets/images/onboarding/onboarding_02.jpg',
      'title': 'Scene Templates',
      'subtitle': 'Merge your portrait into amazing\nscene backgrounds with one tap',
    },
    {
      'image': 'assets/images/onboarding/onboarding_03.jpg',
      'title': 'Art Filters',
      'subtitle': 'Apply stunning artistic filters\nto create stylized photos',
    },
  ];
  void onPageChanged(int index) {
    currentPage.value = index;
  }
  void onSkipTap() {
    Get.offNamed('/outfit_home');
  }
  void onNextTap() {
    if (currentPage.value < pages.length - 1) {
      currentPage.value++;
    } else {
      Get.offNamed('/outfit_home');
    }
  }
}
