import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hosts the five [StatefulShellBranch]es (home/news/events/alerts/settings)
/// that need branch state preserved across navigation. Navigation chrome
/// lives entirely in [AppDrawer] — every branch screen already opens its own
/// `Scaffold(appBar: ..., drawer: const AppDrawer())`, so this shell adds no
/// chrome of its own (no bottom bar): the drawer is the single navigation
/// surface across the whole app, reachable from any screen.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) => navigationShell;
}
