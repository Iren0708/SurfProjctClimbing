import 'package:flutter/material.dart';
import 'package:vertical_mobile/app/router/app_shell_branch.dart';
import 'package:go_router/go_router.dart';

/// Таб-бар авторизованной зоны (00-foundations §4.2).
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static final _destinations = [
    (
      icon: Icons.fitness_center_outlined,
      selectedIcon: Icons.fitness_center,
      label: AppShellBranch.tabLabels[AppShellBranch.slots],
    ),
    (
      icon: Icons.event_note_outlined,
      selectedIcon: Icons.event_note,
      label: AppShellBranch.tabLabels[AppShellBranch.bookings],
    ),
    (
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: AppShellBranch.tabLabels[AppShellBranch.profile],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: [
          for (final item in _destinations)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.label,
            ),
        ],
      ),
    );
  }
}
