import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_gallery/controllers/camera.dart';
import 'package:video_player/video_player.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomCameraController>();
    var cameraMode = true.obs;
    return Scaffold(
      body: SizedBox(
        height: Get.height,
        child: Obx(() {
          // -> Esta fue díficil porque para poder actualizar correctamente la cámara toca validarla primero,
          // y antes lo hjabía intentando solamente como valor reactivo, pero no la iniciaba porque era nula, pero tampoco reintentaba
          // porque estaba validando directamente el preview, y debía realizar la validación y si sale bien ahí si retornar la preview.
          final camCtrl = controller.cameraController.value;
          if (camCtrl == null || !camCtrl.value.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          return CameraPreview(
            camCtrl,
            child: Align(
              alignment:
                  Alignment
                      .bottomCenter, // -> coloca el widget con las opciones en la parte de abajo
              child: Container(
                margin: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  spacing: 12,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            cameraMode.value = true;
                          },
                          child: const Text(
                            'Foto',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            cameraMode.value = false;
                          },
                          child: const Text(
                            'Video',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () =>
                          cameraMode.value
                              ? CameraButtons(controller: controller)
                              : VideoButtons(controller: controller),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class CameraButtons extends StatelessWidget {
  final CustomCameraController controller;
  const CameraButtons({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    Rx<Icon> flashIcon = Icon(Icons.flash_on_outlined).obs;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FloatingActionButton(
          heroTag: "flipCamera",
          onPressed: () async {
            await controller.switchCamera();
          },
          child: const Icon(Icons.flip_camera_android_rounded),
        ),
        FloatingActionButton(
          heroTag: "shotPhoto",
          // https://docs.flutter.dev/cookbook/plugins/picture-using-camera
          onPressed: () async {
            try {
              await controller.cameraController.value
                  ?.initialize(); // -> Se vuelve a esperar que el controlador esté iniciado para evitar errores
              final image =
                  await controller.cameraController.value
                      ?.takePicture(); // -> función para tomar fotos
              // -> ya que flutter/dart recomiendan no llamar al contexto en funciones asíncronas, en caso de que no esté inicializado o haya un error se cierre
              if (!context.mounted) return;
              await Get.to(() => DisplayPictureScreen(imagePath: image!.path));
            } catch (e) {
              // If an error occurs, log the error to the console.
              log(e.toString());
            }
          },

          child: const Icon(Icons.camera_alt),
        ),
        Obx(
          () => FloatingActionButton(
            heroTag: "flashController",
            onPressed: () {
              var actualFlashMode =
                  controller
                      .cameraController
                      .value
                      ?.value
                      .flashMode; // -> ?????? sería Rx<CameraController>, al llamar a .value saca solamente el CameraController, y luego al llamar nuevamnete al .value llama a su instancia, ???
              if (actualFlashMode == FlashMode.off ||
                  actualFlashMode == FlashMode.auto) {
                controller.cameraController.value?.setFlashMode(
                  FlashMode.torch,
                );
                flashIcon.value = Icon(Icons.flash_on_rounded);
              } else {
                controller.cameraController.value?.setFlashMode(FlashMode.off);
                flashIcon.value = Icon(Icons.flash_off_rounded);
              }
            },
            child: flashIcon.value,
          ),
        ),
      ],
    );
  }
}

class VideoButtons extends StatelessWidget {
  final CustomCameraController controller;
  const VideoButtons({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    RxBool isRecording = false.obs;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(
          () =>
              !isRecording.value
                  ? FloatingActionButton(
                    heroTag: "starRecord",
                    // https://docs.flutter.dev/cookbook/plugins/picture-using-camera
                    onPressed: () async {
                      try {
                        await controller.cameraController.value
                            ?.initialize(); // -> Se vuelve a esperar que el controlador esté iniciado para evitar errore
                        await controller.cameraController.value
                            ?.startVideoRecording(); // -> función para iniciar a grabar, no tiene valor de retorno
                        isRecording.value = true;
                      } catch (e) {
                        log(e.toString());
                      }
                    },
                    child: const Icon(Icons.play_arrow_rounded),
                  )
                  : FloatingActionButton(
                    heroTag: "stopRecord",
                    onPressed: () async {
                      try {
                        final finisher =
                            await controller.cameraController.value
                                ?.stopVideoRecording(); // -> función para finalizar de grabar, retorna el archivo en formato XFile (abstracción genérica de archivos, el framework lo resuelve internamente para cada SO)
                        isRecording.value = false;
                        if (!context.mounted) return;
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => DisplayVideoScreen(
                                  videoPath: finisher!.path,
                                ),
                          ),
                        );
                      } catch (e) {
                        log(e.toString());
                      }
                    },
                    child: const Icon(Icons.pause_circle_filled_rounded),
                  ),
        ),
      ],
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  Future<void> _saveImage(BuildContext context) async {
    try {
      final now = DateTime.now();
      final formattedDate = now.toIso8601String().replaceAll(":", "-");

      final fileName = "IMG_$formattedDate.jpg";
      final cameraDir = Directory("/storage/emulated/0/DCIM/Camera");

      if (!await cameraDir.exists()) {
        await cameraDir.create(recursive: true);
      }

      final newPath = "${cameraDir.path}/$fileName";
      // final newFile =
      await File(imagePath).copy(newPath);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Foto guardada")));
        Navigator.of(context).pop(); // Go back to camera
      }
    } catch (e) {
      log("Eror guardando la imágen: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se ha podido guardar")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: Image.file(File(imagePath))),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _saveImage(context),
                  icon: const Icon(Icons.save),
                  label: const Text("Guardar"),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.delete),
                  label: const Text("Eliminar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DisplayVideoScreen extends StatelessWidget {
  final String videoPath;
  const DisplayVideoScreen({super.key, required this.videoPath});

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController controller = VideoPlayerController.file(
      File(videoPath),
    );
    return Scaffold(
      body: Center(
        child:
            controller.value.isInitialized
                ? AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                )
                : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "videoController",
        onPressed: () {
          controller.value.isPlaying ? controller.pause() : controller.play();
        },
        child: Icon(
          controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
