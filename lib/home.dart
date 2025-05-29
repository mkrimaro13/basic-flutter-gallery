import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/home.dart';

class HomePage extends StatelessWidget {
  final int? initialIndex;
  const HomePage({super.key, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0, elevation: 0),
      body: RepaintBoundary(
        child: PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: controller.pageController,
          physics: ClampingScrollPhysics(),
          itemCount: controller.pages.length,
          itemBuilder: (context, index) {
            return controller.pages[index];
          },
        ),
      ),
    );
  }
}


