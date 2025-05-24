import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_gallery/controllers/gallery.dart';
import 'package:media_gallery/models/media_item.dart';
import 'package:media_gallery/widgets/gallery/custom_upperbar.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GalleryController());
    final ScrollController scrollController = ScrollController();

    // Se agregar un listener (escucha constante mente y si pasa algo se activa) para cargar mas archivos cuando se llega a una cierta parte de la pantalla.
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 500) {
        controller.loadMedia();
      }
    });

    return Scaffold(
      body: Column(
        children: [
          CustomUpperbar(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder:
                            // Lista horizontal con las opciones para filtrar entre imágenes o
                            // videos.
                            (_) => Container(
                              width: double.infinity,
                              height: 100,
                              color: Theme.of(context).scaffoldBackgroundColor,
                              child: Center(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: controller.filters.length,
                                  itemBuilder: (context, index) {
                                    return Obx(() {
                                      final filter = controller.filters[index];
                                      final isSelected =
                                          controller.selectedFilter.value ==
                                          filter;

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        // https://api.flutter.dev/flutter/material/FilterChip-class.html
                                        // Son una alternativa a Checkbox o switch, pero con un
                                        child: FilterChip(
                                          label: Text(filter),
                                          selected: isSelected,
                                          onSelected:
                                              (_) => controller.changeFilter(
                                                filter,
                                              ),
                                          backgroundColor:
                                              Theme.of(
                                                context,
                                              ).secondaryHeaderColor,
                                          selectedColor:
                                              Theme.of(context).primaryColor,
                                          labelStyle: TextStyle(
                                            color:
                                                isSelected
                                                    ? Theme.of(
                                                      context,
                                                    ).textTheme.bodySmall!.color
                                                    : Theme.of(context)
                                                        .appBarTheme
                                                        .foregroundColor,
                                          ),
                                        ),
                                      );
                                    });
                                  },
                                ),
                              ),
                            ),
                      );
                    },
                    icon: Icon(Icons.filter_list_rounded),
                  ),
                  // IconButton(onPressed: () {}, icon: Icon(Icons.search)),
                ],
              ),
            ],
          ),
          // Grilla que muestra los archivos en si
          Expanded(
            child: Obx(() {
              // Si no hay archivos PERO está cargando, muestra el indicador de carga
              if (controller.mediaItems.isEmpty && controller.isLoading.value) {
                return Builder(
                  // -> encerrar el widget en un Builder para acceder al contexto y poder aplicar los colores del tema
                  builder: (BuildContext context) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).appBarTheme.foregroundColor,
                      ),
                    );
                  },
                );
              }
              // Si simplemente no hay archivos
              if (controller.mediaItems.isEmpty) {
                return Builder(
                  builder: (BuildContext context) {
                    return Center(
                      child: Text(
                        'Parece que no hay nada para mostrar aquí... 🧹',
                        style: TextStyle(
                          color: Theme.of(context).appBarTheme.foregroundColor,
                          fontSize: 18,
                        ),
                      ),
                    );
                  },
                );
              }

              // Crea la vista escalonada (No todos los elementos tienen el mismo alto)
              final columns = _getColumnCount(
                Get.width,
              ); // -> es una alternativa a MediaQuery.of(context).size.width, anque internamente funcionan CASI igual, solamente es un Wrapper para hacer la sintaxis mas simple
              final grid = controller.createStaggeredGrid(
                controller.mediaItems,
                columns,
              );

              return RefreshIndicator(
                onRefresh: () => controller.loadMedia(refresh: true),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(4),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              grid
                                  .map(
                                    (column) => Expanded(
                                      child: Column(
                                        children:
                                            column
                                                .map(
                                                  (item) => _buildMediaTile(
                                                    item,
                                                    controller,
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),

                    // Loading indicator
                    if (controller.isLoading.value)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  int _getColumnCount(double width) {
    if (width > 1200) return 4;
    if (width > 800) return 3;
    return 2;
  }

  Widget _buildMediaTile(MediaItem item, GalleryController controller) {
    return Container(
      margin: const EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTap: () {
            final index = controller.mediaItems.indexOf(item);
            controller.openMediaViewer(item, index);
          },
          child: Stack(
            children: [
              // Thumbnail
              AspectRatio(
                aspectRatio: item.aspectRatio,
                child:
                    item.thumbnail != null
                        ? Image.memory(
                          item.thumbnail!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                        : Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
              ),

              // Video indicator
              if (item.type == MediaType.video)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _formatDuration(item.asset.duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Selection overlay
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final index = controller.mediaItems.indexOf(item);
                      controller.openMediaViewer(item, index);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

// Media Viewer Screen
class MediaViewerScreen extends StatelessWidget {
  final MediaItem mediaItem;
  final int initialIndex;

  const MediaViewerScreen({
    Key? key,
    required this.mediaItem,
    required this.initialIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child:
              mediaItem.type == MediaType.image
                  ? FutureBuilder<Uint8List?>(
                    future: mediaItem.asset.originBytes,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.contain,
                        );
                      }
                      return const CircularProgressIndicator(
                        color: Colors.white,
                      );
                    },
                  )
                  : Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 100,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Video Player\n(Implement video player here)',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
