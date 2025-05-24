import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_gallery/pages/permissions.dart';
import 'package:media_gallery/permissions/permissions.dart';
import 'package:media_gallery/style/colors.dart';
import 'package:media_gallery/style/theme.dart';
import 'package:permission_handler/permission_handler.dart';

import 'home.dart';

void main() {
  Get.put(PermissionsManager());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PermissionsManager());
    return GetMaterialApp(
      title: 'Gallery',
      themeMode: ThemeMode.system,
      theme: appTheme(Brightness.light, LightThemeColors.instance),
      darkTheme: appTheme(Brightness.dark, DarkThemeColors.instance),
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child:
        // Puede ser un poco de código repetido junto con el código del
        // controlador, pero la idea es revisar primero los permisos y si
        // están evitar la redirección innecesaria hacía la página de permisos.
        Obx(
          () =>
              controller.photoPermissionStatus.value ==
                          PermissionStatus.granted &&
                      controller.videoPermissionStatus.value ==
                          PermissionStatus.granted &&
                      controller.cameraPermissionStatus.value ==
                          PermissionStatus.granted
                  ? HomePage(initialIndex: 0)
                  : PermissionsPage(controller: controller),
        ),
      ),
    );
  }
}
