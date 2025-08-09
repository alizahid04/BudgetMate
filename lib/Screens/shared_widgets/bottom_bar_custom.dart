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
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navIcon(context, Icons.home, 'Home', 0, '/home'),
            _navIcon(context, Icons.swap_vert, 'History', 1, '/history'),
            _buildAddButton(context),
            _navIcon(context, Icons.track_changes, 'Goals', 2, '/Goal'),
            _navIcon(context, Icons.settings, 'Settings', 3, '/settings'),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(
      BuildContext context,
      IconData icon,
      String tooltip,
      int index,
      String route,
      ) {
    final bool isSelected = selectedIndex == index;
    final Color activeColor = Colors.green.shade700;
    final Color inactiveColor = Colors.grey.shade600;

    return IconButton(
      onPressed: () {
        // Prevent pushing same route multiple times
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      icon: Icon(icon),
      tooltip: tooltip,
      iconSize: 28, // Slightly bigger for accessibility
      color: isSelected ? activeColor : inactiveColor,
      splashRadius: 26,
      visualDensity: VisualDensity.compact,
      focusColor: activeColor.withOpacity(0.2),
      hoverColor: activeColor.withOpacity(0.1),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        splashColor: Colors.white.withOpacity(0.2),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionPage(
                onTransactionAdded: () {
                  // You can add refresh logic here if needed
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
            color: Colors.green.shade600,
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade600.withOpacity(0.35),
                spreadRadius: 3,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
