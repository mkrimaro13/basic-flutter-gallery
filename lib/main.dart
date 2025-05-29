import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_gallery/controllers/camera.dart';
import 'package:media_gallery/controllers/gallery.dart';
import 'package:media_gallery/home.dart';
import 'package:media_gallery/pages/permissions.dart';
import 'package:media_gallery/permissions/permissions.dart';
import 'package:media_gallery/style/colors.dart';
import 'package:media_gallery/style/theme.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  Get.put(PermissionsManager());
  Get.put(GalleryController());
  final List<CameraDescription> cameras =
      await availableCameras(); // -> obtiene las cámaras
  log(cameras.toString());
  Get.put(CustomCameraController(cameras: cameras));
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
