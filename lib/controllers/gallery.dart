import 'dart:developer';

import 'package:get/get.dart';
import 'package:media_gallery/models/media_item.dart';
import 'package:media_gallery/pages/gallery.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryController extends GetxController {
  final RxList<MediaItem> mediaItems =
      <MediaItem>[].obs; // -> la lista de archivos
  final RxBool isLoading =
      false
          .obs; // -> Ya que la lista se obtiene de manera asíncrona esta variable puede servir de control entre ese paso de carga.
  final RxBool hasMore =
      true.obs; // -> Ya que los resultados se cargan paginados se utiliza para seccionar los resultados y saber cuando se terminó de cargar los resultados
  final RxInt currentPage =
      0.obs; // -> La página actual que se está cargando del conjunto páginado
  final RxString selectedFilter = 'All'.obs; // -> la opción del filtro

  static const int pageSize = 50; // -> tamaño del bloque paginado
  List<String> filters = [
    'All',
    'Photos',
    'Videos',
  ]; // -> los filtros disponibles

  @override
  void onInit() {
    super.onInit();
    loadMedia();
  }

  Future<void> loadMedia({bool refresh = false}) async {
    // -> previene que se carguen los archivos mas de una vez en simúltaneo
    if (isLoading.value && !refresh) return;

    if (refresh) {
      // -> si se recarga la página se reinicia la lista de archivos
      currentPage.value = 0;
      mediaItems.clear();
      hasMore.value = true;
    }
    // -> Si ya no hay mas archivos que cargar se sale
    if (!hasMore.value) return;

    isLoading.value = true; // -> indica el inicio de la carga

    try {
      // Permite volver a validar los permisos en caso de que mientras se están cargando los archivos y se pierdan los permisos (casos límites)
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        Get.snackbar(
          'No hay permisos',
          'Por favor brinda acceso a las fotos para continuar',
        );
        isLoading.value = false;
        return;
      }

      // Get albums
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: _getRequestType(),
        onlyAll: true,
      );

      if (albums.isEmpty) {
        hasMore.value = false;
        isLoading.value = false;
        return;
      }

      final AssetPathEntity album = albums.first;
      final List<AssetEntity> assets = await album.getAssetListPaged(
        page: currentPage.value,
        size: pageSize,
      );

      if (assets.isEmpty) {
        hasMore.value = false;
        isLoading.value = false;
        return;
      }

      // Convert to MediaItems with aspect ratios
      // Convierte los "AssetEntity" a "MediaItem" con una relación de aspecto,
      // es decir, con un tamaño diferente de ancho y alto.
      List<MediaItem> newItems = [];
      for (AssetEntity asset in assets) {
        final aspectRatio = asset.width / asset.height;
        final type =
            asset.type == AssetType.image ? MediaType.image : MediaType.video;

        final mediaItem = MediaItem(
          asset: asset,
          aspectRatio: aspectRatio,
          type: type,
          thumbnail: await asset.thumbnailDataWithSize(
            const ThumbnailSize(300, 300),
            quality: 80,
          ),
        );

        newItems.add(mediaItem);
      }

      mediaItems.addAll(newItems);
      currentPage.value++;

      if (assets.length < pageSize) {
        hasMore.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'No se han podido cargar los archivos.');
      log('No se han podido cargar los archivos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  RequestType _getRequestType() {
    switch (selectedFilter.value) {
      case 'Photos':
        return RequestType.image;
      case 'Videos':
        return RequestType.video;
      default:
        return RequestType.common;
    }
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
    loadMedia(refresh: true);
  }

  void openMediaViewer(MediaItem item, int index) {
    Get.to(() => MediaViewerScreen(mediaItem: item, initialIndex: index));
  }

  // Calculate dynamic grid dimensions
  List<List<MediaItem>> createStaggeredGrid(
    List<MediaItem> items,
    int columns,
  ) {
    List<List<MediaItem>> grid = List.generate(columns, (index) => []);
    List<double> columnHeights = List.filled(columns, 0.0);

    for (MediaItem item in items) {
      // Find the shortest column
      int shortestColumn = 0;
      double shortestHeight = columnHeights[0];

      for (int i = 1; i < columns; i++) {
        if (columnHeights[i] < shortestHeight) {
          shortestHeight = columnHeights[i];
          shortestColumn = i;
        }
      }

      // Add item to shortest column
      grid[shortestColumn].add(item);

      // Update column height (normalized height based on aspect ratio)
      double itemHeight = 1.0 / item.aspectRatio;
      columnHeights[shortestColumn] += itemHeight;
    }

    return grid;
  }
}
