import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget {
  final int selectedIndex;

  const MyAppBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.transparent,
      shape: const CircularNotchedRectangle(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navIcon(context, Icons.home, 'Home', 0, '/home'),
            navIcon(context, Icons.swap_vert, 'History', 1, '/history'),
          _buildAddButton(),
            navIcon(context, Icons.savings, 'Icons.track_changes', 2,  '/goals'),
            navIcon(context, Icons.settings, 'Settings', 3, '/settings'),
          ],
        ),
      ),
    );
  }

  Widget navIcon(BuildContext context, IconData icon, String tooltip, int index, String route) {
    return IconButton(
      onPressed: () {
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      icon: Icon(icon),
      tooltip: tooltip,
      iconSize: 40,
      color: selectedIndex == index ? Colors.green[700] : Colors.grey[700],
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green[600],
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.5),
            spreadRadius: 6,
            blurRadius: 14,
          ),
        ],
      ),
      child: Center(
        child: IconButton(
          onPressed: () {
            // Navigate to add transaction
          },
          icon: const Icon(Icons.add),
          color: Colors.white,
          iconSize: 40,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: 'Add',
          splashRadius: 28,
        ),
      ),
    );
  }
}
