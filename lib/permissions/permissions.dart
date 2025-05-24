import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_gallery/home.dart';
import 'package:media_gallery/pages/gallery.dart';
import 'package:permission_handler/permission_handler.dart';

// Se solicitan permisos en base a la guía de buenas prácticas de Google/Flutter
// enlace de las recomendaciones:
// https://developer.android.com/training/permissions/requesting
class PermissionsManager extends GetxController {
  // Estados reactivos para los permisos de manera individual
  final Rx<PermissionStatus?> photoPermissionStatus = Rx<PermissionStatus?>(
    null,
  );
  final Rx<PermissionStatus?> videoPermissionStatus = Rx<PermissionStatus?>(
    null,
  );
  final Rx<PermissionStatus?> cameraPermissionStatus = Rx<PermissionStatus?>(
    null,
  );
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkCurrentPermissions();
  }

  Future<bool> _isAndroid13OrHigher() async {
    // El plugin DeiceInfoPlugin permite obtener la información de un dispositivo
    // Se requiere validar la versión del sdk de android, ya que en base a este
    // se deben pedir unos u otros permisos.
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final int sdkInt = androidInfo.version.sdkInt;
    log('Android SDK version: $sdkInt');
    if (Platform.isAndroid && sdkInt < 33) {
      return false;
    } else {
      return true;
    }
  }

  // Solamente checkear el estado de los permisos, se ejecuta al crear
  // la instancia del controlador
  Future<void> checkCurrentPermissions() async {
    try {
      if (await _isAndroid13OrHigher()) {
        final photoStatus = await Permission.photos.status;
        final videoStatus = await Permission.videos.status;
        final cameraStatus = await Permission.camera.status;

        photoPermissionStatus.value = photoStatus;
        videoPermissionStatus.value = videoStatus;
        cameraPermissionStatus.value = cameraStatus;
      } else {
        final storageStatus = await Permission.storage.status;
        photoPermissionStatus.value = storageStatus;
        videoPermissionStatus.value = storageStatus;
        cameraPermissionStatus.value = storageStatus;
      }
    } catch (e) {
      // Fallback in case of any errors
      photoPermissionStatus.value = PermissionStatus.denied;
      videoPermissionStatus.value = PermissionStatus.denied;
    }
  }

  Future<void> requestPermissions() async {
    isLoading.value = true;
    try {
      // De acuerdo a la documentación de permisos de google:
      // https://developer.android.com/reference/android/Manifest.permission
      // Para las versiónes de Android 13 y superiores, se requiere específicar
      // a que datos se requieren permisos, cómo CAMERA, PHOTOS, VIDEOS.
      // Pero para versiones inferiores a android 13 se pide directamente
      // acceso a todo el almacenamiento STORAGE.
      Map<Permission, PermissionStatus> statuses;

      if (await _isAndroid13OrHigher()) {
        statuses =
            await [
              Permission.photos,
              Permission.videos,
              Permission.camera,
            ].request();
        photoPermissionStatus.value = statuses[Permission.photos];
        videoPermissionStatus.value = statuses[Permission.videos];
        cameraPermissionStatus.value = statuses[Permission.camera];
      } else {
        statuses = await [Permission.storage].request();

        final storageStatus =
            statuses[Permission.storage] ?? PermissionStatus.denied;
        photoPermissionStatus.value = storageStatus;
        videoPermissionStatus.value = storageStatus;
        cameraPermissionStatus.value = storageStatus;

        // Update statuses for consistency
        statuses[Permission.photos] = storageStatus;
        statuses[Permission.videos] = storageStatus;
        statuses[Permission.camera] = storageStatus;
      }

      isLoading.value = false;

      // Handle the result
      if (photoPermissionStatus.value == PermissionStatus.granted &&
          videoPermissionStatus.value == PermissionStatus.granted &&
          cameraPermissionStatus.value == PermissionStatus.granted) {
        showSuccessDialog();
      } else if (photoPermissionStatus.value ==
              PermissionStatus.permanentlyDenied ||
          videoPermissionStatus.value == PermissionStatus.permanentlyDenied ||
          cameraPermissionStatus.value == PermissionStatus.permanentlyDenied ||
          photoPermissionStatus.value == PermissionStatus.denied ||
          videoPermissionStatus.value == PermissionStatus.denied ||
          cameraPermissionStatus.value == PermissionStatus.denied) {
        showSettingsDialog();
      } else {
        showDeniedDialog();
      }
    } catch (e) {
      log('Error: ${e.toString()}');
      isLoading.value = false;
      showErrorDialog();
    }
  }

  void showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Se han obtenido los permisos requeridos'),
        content: const Text('Ahora se puedes visualizar tús fotos y videos'),
        actions: [
          TextButton(
            onPressed: () {
              // Get.back();
              navigateToPhotoScreen();
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void showDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('No hemos podido obtener los permisos requeridos'),
        content: const Text(
          'Se requiere acceso a fotos y videos para continuar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              requestPermissions();
            },
            child: const Text('Volver a intentar'),
          ),
        ],
      ),
    );
  }

  void showSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Permisos requeridos'),
        content: const Text(
          'Los permisos para fotos y videos han sido denegados.'
          'Por favor brinda los permisos necesarios para continuar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Abrir los ajustes'),
          ),
        ],
      ),
    );
  }

  void showErrorDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Error'),
        content: const Text(
          'Lo sentimos, algo ha salido mal solicitando los permisos.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Volver.')),
        ],
      ),
    );
  }

  void navigateToPhotoScreen() {
    Get.back();
    Get.off(() => HomePage(initialIndex: 0));
  }

  void skipPermission() {
    Get.back();
    Get.off(() => GalleryPage());
  }

  String getPermissionStatusText(PermissionStatus? status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.provisional:
        return 'Provisional';
      case null:
        return 'Unknown';
      default:
        return 'Unknown';
    }
  }

  Color getPermissionStatusColor(PermissionStatus? status) {
    switch (status) {
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.denied:
        return Colors.orange;
      case PermissionStatus.permanentlyDenied:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
