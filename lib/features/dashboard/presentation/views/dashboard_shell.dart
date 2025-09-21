import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/domain/entities/user.dart';
import 'package:sami_app/features/superuser/presentation/providers/ai_profiles_provider.dart';
import 'package:sami_app/shared/providers/menu_provider.dart';
import 'package:sami_app/shared/providers/session_provider.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell(
      {required this.navigationShell, required this.destinations, super.key});

  final StatefulNavigationShell navigationShell;
  final List<DashboardDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final aiProfiles = context.watch<AiProfilesProvider>();
    final menuProvider = context.read<MenuProvider>();
    final modules =
        aiProfiles.profiles[aiProfiles.selectedOrg?.activeProfile]?.modules ??
            const [];
    final role = session.user?.role ?? UserRole.viewer;
    menuProvider.updateFor(role: role, modules: modules);
    final menu = context.watch<MenuProvider>();

    final branchMap = <String, int>{};
    for (var i = 0; i < destinations.length; i++) {
      branchMap[destinations[i].path] = i;
    }

    final menuOrder = menu.items.isNotEmpty
        ? menu.items.map((item) => item.path).toList()
        : destinations.map((dest) => dest.path).toList();

    final visibleDestinations = <DashboardDestination>[];
    final visibleBranchIndexes = <int>[];
    for (final path in menuOrder) {
      final branchIndex = branchMap[path];
      if (branchIndex == null) continue;
      final destination = destinations[branchIndex];
      if (!visibleDestinations.any((it) => it.path == destination.path)) {
        visibleDestinations.add(destination);
        visibleBranchIndexes.add(branchIndex);
      }
    }

    if (visibleDestinations.isEmpty) {
      visibleDestinations.addAll(destinations);
      visibleBranchIndexes
          .addAll(List.generate(destinations.length, (index) => index));
    }

    final currentBranchIndex = navigationShell.currentIndex;
    final currentPath = destinations[currentBranchIndex].path;
    final currentVisibleIndex =
        visibleDestinations.indexWhere((dest) => dest.path == currentPath);
    final effectiveIndex = currentVisibleIndex >= 0 ? currentVisibleIndex : 0;
    final currentDestination = visibleDestinations[effectiveIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentDestination.label),
      ),
      drawer: _DashboardDrawer(
        destinations: visibleDestinations,
        branchIndexes: visibleBranchIndexes,
        currentIndex: effectiveIndex,
        session: session,
        onSelected: (index) {
          final destination = visibleDestinations[index];
          if (!_canAccess(session, destination)) {
            _showAccessDenied(context);
            return;
          }
          final branchIndex = visibleBranchIndexes[index];
          if (branchIndex != navigationShell.currentIndex) {
            navigationShell.goBranch(branchIndex);
          }
          Navigator.pop(context);
        },
        onLogout: () async {
          await session.logout();
          if (context.mounted) {
            context.go('/login');
          }
        },
      ),
      body: navigationShell,
    );
  }

  bool _canAccess(SessionProvider session, DashboardDestination destination) {
    if (destination.allowedRoles == null) {
      return true;
    }
    return session.hasAnyRole(destination.allowedRoles!);
  }

  void _showAccessDenied(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('No tienes permisos para acceder a esta sección.')),
    );
  }
}

class _DashboardDrawer extends StatelessWidget {
  const _DashboardDrawer({
    required this.destinations,
    required this.branchIndexes,
    required this.currentIndex,
    required this.session,
    required this.onSelected,
    required this.onLogout,
  });

  final List<DashboardDestination> destinations;
  final List<int> branchIndexes;
  final int currentIndex;
  final SessionProvider session;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final user = session.user;
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (user != null)
              UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  child: Text(user.displayName.substring(0, 1).toUpperCase()),
                ),
                accountName: Text(user.displayName),
                accountEmail: Text(user.role.name.toUpperCase()),
              )
            else
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text('S.A.M.I.',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Menú principal'),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final destination = destinations[index];
                  final isSelected = index == currentIndex;
                  final isEnabled =
                      session.user == null || _canAccess(session, destination);

                  return ListTile(
                    leading: Icon(destination.icon,
                        color: isSelected ? theme.colorScheme.primary : null),
                    title: Text(destination.label),
                    selected: isSelected,
                    enabled: isEnabled,
                    onTap: () => onSelected(index),
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }

  bool _canAccess(SessionProvider session, DashboardDestination destination) {
    if (destination.allowedRoles == null) {
      return true;
    }
    return session.hasAnyRole(destination.allowedRoles!);
  }
}

class DashboardDestination {
  const DashboardDestination({
    required this.label,
    required this.icon,
    required this.path,
    this.selectedIcon,
    this.allowedRoles,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String path;
  final Set<UserRole>? allowedRoles;
}
