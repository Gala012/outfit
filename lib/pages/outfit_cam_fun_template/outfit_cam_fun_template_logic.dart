import 'package:get/get.dart';

class OutfitCamFunTemplateLogic extends GetxController {
  final templates = List.generate(
    12,
    (i) => {
      'image':
          'assets/images/scene_templates/scene_templates_${(i + 1).toString().padLeft(2, '0')}.jpg',
      'title': _templateTitles[i],
    },
  );
  static const _templateTitles = [
    'Nature',
    'Landscape',
    'City',
    'Beach',
    'Mountain',
    'Sunset',
    'Forest',
    'Scenery',
    'Urban',
    'Ocean',
    'Peaks',
    'Dusk',
  ];
  void onTemplateTap(int index) {
    Get.toNamed(
      '/fun_template_make',
      arguments: {
        'templateIndex': index,
        'templateImage': templates[index]['image'],
      },
    );
  }
}
