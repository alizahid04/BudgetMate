import 'package:flutter/material.dart';

import '../Add_Transaction_screen.dart';

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
            _buildAddButton(context),
            navIcon(
              context,
              Icons.track_changes,
              'Icons.track_changes',
              2,
              '/Goal',
            ),
            navIcon(context, Icons.settings, 'Settings', 3, '/settings'),
          ],
        ),
      ),
    );
  }

  Widget navIcon(
    BuildContext context,
    IconData icon,
    String tooltip,
    int index,
    String route,
  ) {
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

  Widget _buildAddButton(BuildContext context) {
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
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddTransactionPage(
                  onTransactionAdded: () {
                    // Refresh logic if needed (optional)
                  },
                ),
              ),
            );
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
