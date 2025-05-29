import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 68,
        decoration: decoration(context),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onItemTapped,
          destinations: [
            // _buildNavItem(Icons.home_rounded, Icons.home_outlined, 'Inicio'),
            _buildNavItem(
              Icons.image_rounded,
              Icons.image_outlined,
              'Galería',
            ),
            _buildNavItem(
              Icons.camera_alt_rounded,
              Icons.camera_alt_outlined,
              'Cámara',
            ),
            // _buildNavItem(
            //   Icons.person_2_rounded,
            //   Icons.person_2_outlined,
            //   'Perfil',
            // ),
          ],
        ));
  }

  NavigationDestination _buildNavItem(
      IconData iconSelected,
      IconData iconUnselected,
      String label,
      ) {
    return NavigationDestination(
      selectedIcon: Icon(iconSelected),
      icon: Icon(iconUnselected),
      label: label,
      tooltip: label,
    );
  }
}


BoxDecoration decoration(BuildContext context) {
  return BoxDecoration(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    gradient: LinearGradient(
      colors: [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.secondary,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}
