import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../pages/outfit_cam_onboarding/outfit_cam_onboarding_binding.dart';
import '../pages/outfit_cam_onboarding/outfit_cam_onboarding_view.dart';
import '../pages/outfit_cam_home/outfit_cam_home_binding.dart';
import '../pages/outfit_cam_home/outfit_cam_home_view.dart';
import '../pages/outfit_cam_camera/outfit_cam_camera_binding.dart';
import '../pages/outfit_cam_camera/outfit_cam_camera_view.dart';
import '../pages/outfit_cam_outfit/outfit_cam_outfit_binding.dart';
import '../pages/outfit_cam_outfit/outfit_cam_outfit_view.dart';
import '../pages/outfit_cam_select_photo/outfit_cam_select_photo_binding.dart';
import '../pages/outfit_cam_select_photo/outfit_cam_select_photo_view.dart';
import '../pages/outfit_cam_crop/outfit_cam_crop_binding.dart';
import '../pages/outfit_cam_crop/outfit_cam_crop_view.dart';
import '../pages/outfit_cam_fun_template/outfit_cam_fun_template_binding.dart';
import '../pages/outfit_cam_fun_template/outfit_cam_fun_template_view.dart';
import '../pages/outfit_cam_fun_template_make/outfit_cam_fun_template_make_binding.dart';
import '../pages/outfit_cam_fun_template_make/outfit_cam_fun_template_make_view.dart';
import '../pages/outfit_cam_fun_template_result/outfit_cam_fun_template_result_binding.dart';
import '../pages/outfit_cam_fun_template_result/outfit_cam_fun_template_result_view.dart';
import '../pages/outfit_cam_art_filter/outfit_cam_art_filter_binding.dart';
import '../pages/outfit_cam_art_filter/outfit_cam_art_filter_view.dart';
import '../pages/outfit_cam_art_filter_edit/outfit_cam_art_filter_edit_binding.dart';
import '../pages/outfit_cam_art_filter_edit/outfit_cam_art_filter_edit_view.dart';
import '../pages/outfit_cam_settings/outfit_cam_settings_binding.dart';
import '../pages/outfit_cam_settings/outfit_cam_settings_view.dart';
import '../pages/outfit_cam_history/outfit_cam_history_binding.dart';
import '../pages/outfit_cam_history/outfit_cam_history_view.dart';
import '../pages/outfit_cam_cartoon_head/outfit_cam_cartoon_head_binding.dart';
import '../pages/outfit_cam_cartoon_head/outfit_cam_cartoon_head_view.dart';
import 'db_outfitcam/data.dart';

const Color primaryColor = Color(0xFFFF5E78);
const Color secondaryColor = Color(0xFF9F7AEA);
const Color accentColor = Color(0xFF34D399);
const Color bgColor = Color(0xFFFAFAFC);
const Color textColor = Color(0xFF1F2937);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Get.putAsync(() async => OutfitCamDatabase());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          getPages: Outfit,
          initialRoute: '/outfit_home',
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: primaryColor,
            scaffoldBackgroundColor: bgColor,
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              secondary: secondaryColor,
              surface: Color(0xFFFFFFFF),
            ),
            appBarTheme: AppBarTheme(
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              backgroundColor: Colors.white,
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17.sp,
                color: textColor,
              ),
              iconTheme: const IconThemeData(size: 22, color: textColor),
            ),
          ),
        );
      },
    );
  }
}
List<GetPage<dynamic>> Outfit = [
  GetPage(
    name: '/onboarding',
    page: () => const OutfitCamOnboardingView(),
    binding: OutfitCamOnboardingBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/outfit_home',
    page: () => const OutfitCamHomeView(),
    binding: OutfitCamHomeBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/outfit_camera',
    page: () => const OutfitCamCameraView(),
    binding: OutfitCamCameraBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/outfit_outfit',
    page: () => const OutfitCamOutfitView(),
    binding: OutfitCamOutfitBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/outfit_select_photo',
    page: () => const OutfitCamSelectPhotoView(),
    binding: OutfitCamSelectPhotoBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/outfit_crop',
    page: () => const OutfitCamCropView(),
    binding: OutfitCamCropBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/outfit_fun_template',
    page: () => const OutfitCamFunTemplateView(),
    binding: OutfitCamFunTemplateBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/fun_template_make',
    page: () => const OutfitCamFunTemplateMakeView(),
    binding: OutfitCamFunTemplateMakeBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/fun_template_result',
    page: () => const OutfitCamFunTemplateResultView(),
    binding: OutfitCamFunTemplateResultBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/art_filter',
    page: () => const OutfitCamArtFilterView(),
    binding: OutfitCamArtFilterBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/art_filter_edit',
    page: () => const OutfitCamArtFilterEditView(),
    binding: OutfitCamArtFilterEditBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/outfit_settings',
    page: () => const OutfitCamSettingsView(),
    binding: OutfitCamSettingsBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/outfit_history',
    page: () => const OutfitCamHistoryView(),
    binding: OutfitCamHistoryBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/outfit_cartoon_head',
    page: () => const OutfitCamCartoonHeadView(),
    binding: OutfitCamCartoonHeadBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
];