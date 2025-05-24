import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

class MediaItem {
  final AssetEntity asset; // -> esta es la imagen o el video en sí misma.
  final double aspectRatio;
  final MediaType type;
  Uint8List? thumbnail; // -> esta es la previsualización de la imagen o el video.

  MediaItem({
    required this.asset,
    required this.aspectRatio,
    required this.type,
    this.thumbnail,
  });
}
enum MediaType { image, video }