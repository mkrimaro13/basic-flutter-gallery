import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:get/get.dart';

class CustomCameraController extends GetxController {
  final List<CameraDescription> cameras;
  CustomCameraController({required this.cameras});
  final Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  @override
  Future<void> onInit() async {
    super.onInit();
    await initializeBackCamera();
  }

  @override
  void dispose() {
    if (cameraController.value!.value.isInitialized) {
      cameraController.value!.dispose();
    }
    super.dispose();
  }

  Future<void> initializeCamera(CameraDescription cameraDescription) async {
    // Primero se debe inicializar el propio objeto cameraController.
    // Es un objetico de tipo Rx que envuelve dentro de sí un CameraController.
    // Por lo tanto primero debo inicializar el objeto Rx en sí, para poder acceder luego al envoltorio.
    try {
      if (cameraController.value != null &&
          cameraController.value!.value.isInitialized) {
        await cameraController.value!.dispose();
      }

      final newController = CameraController(
        cameraDescription,
        ResolutionPreset.ultraHigh,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
        fps: 30,
      );

      await newController.initialize();
      cameraController.value = newController;
      log(
        'Cámara (${cameraDescription.lensDirection}) inicializada correctamente.',
      );
    } on CameraException catch (e) {
      log('Error al inicializar la cámara: ${e.code} ${e.description}');
    } catch (e) {
      log('Error inesperado al inicializar la cámara: $e');
    }
  }

  Future<void> initializeFrontCamera() async {
    if (cameras.isEmpty) {
      log('No hay cámaras disponibles');
      return;
    }

    CameraDescription? frontCamera;
    try {
      frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } catch (e) {
      // Si no hay cámaras
      log(e.toString());
      log('No hay cámara frontal disponible');
      return;
    }

    await initializeCamera(frontCamera);
  }

  Future<void> initializeBackCamera() async {
    if (cameras.isEmpty) {
      log('No hay cámaras disponibles');
      return;
    }

    CameraDescription? backCamera;
    try {
      backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
    } catch (e) {
      log(e.toString());
      log('No hay cámara trasera disponible');
      return;
    }

    await initializeCamera(backCamera);
  }

  // Función para cambiar entre cámaras.
  Future<void> switchCamera() async {
    if (cameras.length < 2) {
      log('Solo hay una cámara disponible');
      return;
    }

    final controller = cameraController.value;
    if (controller == null || !controller.value.isInitialized) {
      log('El controlador de cámara no está inicializado');
      return;
    }

    final currentLensDirection = controller.description.lensDirection;
    CameraDescription? newCameraDescription;

    if (currentLensDirection == CameraLensDirection.front) {
      newCameraDescription = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
    } else {
      newCameraDescription = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    }

    await initializeCamera(newCameraDescription);
  }
}
