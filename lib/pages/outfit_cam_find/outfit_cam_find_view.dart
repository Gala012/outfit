import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'outfit_cam_find_logic.dart';

class OutfitCamFindView extends GetView<OutfitCamFindLogic> {
  const OutfitCamFindView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(
          () => controller.oqgjvawx.value
              ? const CircularProgressIndicator(color: Colors.black)
              : buildError(),
        ),
      ),
    );
  }

  Widget buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              controller.wuyrjp();
            },
            icon: const Icon(
              Icons.restart_alt,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }
}
