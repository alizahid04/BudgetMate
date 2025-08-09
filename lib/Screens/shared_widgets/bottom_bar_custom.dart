import 'package:flutter/material.dart';
import '../Add_Transaction_screen.dart';

class MyAppBar extends StatelessWidget {
  final int selectedIndex;

  const MyAppBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      height: 60,
      shape: const CircularNotchedRectangle(),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navIcon(context, Icons.home, 'Home', 0, '/home'),
            navIcon(context, Icons.swap_vert, 'History', 1, '/history'),
            _buildAddButton(context),
            navIcon(context, Icons.track_changes, 'Goals', 2, '/Goal'),
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
      iconSize: 26, // Standard professional size
      color: selectedIndex == index ? Colors.green[700] : Colors.grey[600],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Material(
      color: Colors.transparent, // Needed for ripple
      child: InkWell(
        customBorder: const CircleBorder(),
        splashColor: Colors.white.withOpacity(0.2),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionPage(
                onTransactionAdded: () {
                  // Optional refresh logic
                },
              ),
            ),
          );
        },
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green[600],
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 10,
                offset: const Offset(0, 4), // Lifted shadow
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 26, // Balanced size for visibility
          ),
        ),
      ),
    );
  }
}
