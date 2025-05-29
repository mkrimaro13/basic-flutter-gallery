import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_gallery/pages/camera.dart';
import 'package:media_gallery/pages/gallery.dart';

class HomeController extends GetxController {
  late final PageController pageController;
  var selectedIndex = 0.obs;
  final int initialIndex;

  final List<Widget> pages = [GalleryPage(), CameraPage()];

  HomeController({this.initialIndex = 0});

  @override
  void onInit() {
    super.onInit();
    selectedIndex.value = initialIndex;
    pageController = PageController(initialPage: initialIndex);
    pageController.addListener(() {
      final currentPage = pageController.page?.round() ?? 0;
      if (selectedIndex.value != currentPage) {
        selectedIndex.value = currentPage;
      }
    });
  }

  void onItemTapped(int index) {
    selectedIndex.value = index;
    pageController.jumpToPage(index);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
