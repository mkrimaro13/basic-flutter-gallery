import 'dart:developer';

import 'package:get/get.dart';
import 'package:media_gallery/models/media_item.dart';
import 'package:media_gallery/pages/gallery.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryController extends GetxController {
  final RxList<MediaItem> mediaItems = <MediaItem>[].obs; // -> la lista de archivos
  final RxBool isLoading = false.obs; // -> Ya que la lista se obtiene de manera asíncrona esta variable puede servir de control entre ese paso de carga.
  final RxBool hasMore = true.obs; // -> Ya que los resultados se cargan paginados se utiliza para seccionar los resultados y saber cuando se terminó de cargar los resultados
  final RxInt currentPage = 0.obs; // -> La página actual que se está cargando del conjunto páginado
  final RxString selectedFilter = 'All'.obs; // -> la opción del filtro

  static const int pageSize = 50; // -> tamaño del bloque paginado
  List<String> filters = ['All', 'Photos', 'Videos']; // -> los filtros disponibles

  @override
  void onInit() {
    super.onInit();
    loadMedia();
  }

  Future<void> loadMedia({bool refresh = false}) async {
    if (isLoading.value && !refresh) return; // -> previene que se carguen los archivos mas de una vez en simúltaneo

    if (refresh) { // -> si se recarga la página se reinicia la lista de archivos
      currentPage.value = 0;
      mediaItems.clear();
      hasMore.value = true;
    }

    if (!hasMore.value) return; // -> Si ya no hay mas archivos que cargar se sale

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

  // RxList<AssetEntity> mediaList = <AssetEntity>[].obs;
  // Rx<int> currentPage = 0.obs;
  // int pageSize = 50;
  // Rx<bool> isLoading = false.obs;
  // Rx<bool> hasMore = true.obs;
  // final ScrollController scrollController = ScrollController();
  // final PermissionsManager permissionsController = Get.find<PermissionsManager>();
  //
  // @override
  // void onInit() {
  //   super.onInit();
  //   _loadMedia();
  //
  //   // addListener registra una función que se ejecuta cada vez que
  //   // cambia la posición del desplazamiento, cada vez que se haga scroll.
  //   scrollController.addListener(() {
  //     // hasClients verifica si el ScrollController está anclado a una vista
  //     // de desplazamiento.
  //     if (scrollController.hasClients) {
  //       if (hasMore.value &&
  //           !isLoading.value &&
  //           // position.pixels es la posición de desplazamiento actual.
  //           // maxScrollExtent representa la posición de desplazamiento posible
  //           // en píxeles y es el punto mas bajo que el usuario se puede
  //           // desplazar agregarle el -200 indica un umbral, donde el usuario
  //           // se espera que llegue, esto permite que se carguen mas datos
  //           // evitan llegar al final sin contenido.
  //           scrollController.position.pixels >=
  //               scrollController.position.maxScrollExtent - 1000) {
  //         _loadMedia();
  //       }
  //     }
  //   });
  // }
  //
  // Future<void> _loadMedia() async {
  //   if (isLoading.value || !hasMore.value) return;
  //   isLoading.value = true;
  //
  //   // Significa los álbumes de fots y videos
  //   final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
  //     // common -> significa fotos y videos
  //     type: RequestType.common,
  //     // Filtra
  //     filterOption: FilterOptionGroup(
  //       //   imageOption: const FilterOption(
  //       //     sizeConstraint: SizeConstraint(minWidth: 100, minHeight: 100),
  //       //   ),
  //       // -> ordena por fecha de creación en orden descendente
  //       orders: [
  //         const OrderOption(type: OrderOptionType.createDate, asc: false),
  //       ],
  //     ),
  //     hasAll: true,
  //   );
  //   if (paths.isNotEmpty) {
  //     List<AssetEntity> allMedia = <AssetEntity>[];
  //     for (var path in paths) {
  //       log('path: $path');
  //       List<AssetEntity> pathMedia =  await path.getAssetListPaged(page: currentPage.value, size: pageSize);
  //       allMedia.addAll(pathMedia);
  //       log('pathMedia: $pathMedia');
  //     }
  //     final AssetPathEntity allPhotosPath = paths.first;
  //
  //     final List<AssetEntity> newMedia = await allPhotosPath.getAssetListPaged(
  //       page: currentPage.value,
  //       size: pageSize,
  //     );
  //
  //     // Check if the component is still mounted before updating state
  //     if (!isClosed) {
  //       mediaList.addAll(allMedia);
  //       currentPage.value++;
  //       hasMore.value = allMedia.length == pageSize;
  //       isLoading.value = false;
  //     }
  //   } else {
  //     if (!isClosed) {
  //       hasMore.value = false;
  //       isLoading.value = false;
  //     }
  //   }
  // }
  //
  // // Ensure you dispose of the scroll controller
  // @override
  // void onClose() {
  //   scrollController.dispose();
  //   super.onClose();
  // }
}
