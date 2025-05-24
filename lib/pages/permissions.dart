import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_gallery/permissions/permissions.dart';

class PermissionsPage extends StatelessWidget {
  final PermissionsManager controller;
  const PermissionsPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 32,
          children: [
            Icon(
              Icons.photo_library,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 16,
              children: [
                const Text(
                  'Acceso requerido a la galeria y a la cámara',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Las funcionalidades de esta aplicación requieren permiso para acceder a la galeria y a la cámara.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            // Tarjeta reactiva que actualiza el estado de los permisos
            Obx(
              () => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    spacing: 12,
                    children: [
                      _buildCardStatusItem(
                        Icons.photo_album_rounded,
                        'Permiso para las fotos',
                        controller.getPermissionStatusColor(
                          controller.photoPermissionStatus.value,
                        ),
                        controller.getPermissionStatusText(
                          controller.photoPermissionStatus.value,
                        ),
                      ),
                      _buildCardStatusItem(
                        Icons.videocam_rounded,
                        'Permiso para los videos',
                        controller.getPermissionStatusColor(
                          controller.videoPermissionStatus.value,
                        ),
                        controller.getPermissionStatusText(
                          controller.videoPermissionStatus.value,
                        ),
                      ),
                      _buildCardStatusItem(
                        Icons.camera_alt_rounded,
                        'Permiso para la cámara',
                        controller.getPermissionStatusColor(
                          controller.cameraPermissionStatus.value,
                        ),
                        controller.getPermissionStatusText(
                          controller.cameraPermissionStatus.value,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Botón para solicitar permisos, es reactivo ya que interactúa con
            // las variables reactivas del estado
            Obx(
              () => ElevatedButton(
                onPressed:
                    controller.isLoading.value
                        ? null
                        : controller.requestPermissions,
                child:
                    controller.isLoading.value
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Conceder los permisos',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildCardStatusItem(
  IconData icon,
  String text,
  Color color,
  String status,
) {
  return Row(
    spacing: 12,
    children: [
      Icon(icon),
      Expanded(child: Text(text)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    ],
  );
}
