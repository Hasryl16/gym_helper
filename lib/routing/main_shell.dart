import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/theme/app_colors.dart';
import '../shared/theme/app_spacing.dart';
import '../core/constants/app_strings.dart';
import 'route_names.dart';

/// Bottom navigation shell for the 4 main tabs.
class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: navigationShell,
      bottomNavigationBar: _GhNavBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTabTap,
      ),
    );
  }

  void _onTabTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _GhNavBar extends StatelessWidget {
  const _GhNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _destinations = [
    _TabDest(icon: Icons.home_outlined, activeIcon: Icons.home, label: AppStrings.navHome),
    _TabDest(icon: Icons.fitness_center_outlined, activeIcon: Icons.fitness_center, label: AppStrings.navWorkout),
    _TabDest(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: AppStrings.navReports),
    _TabDest(icon: Icons.person_outline, activeIcon: Icons.person, label: AppStrings.navProfile),
  ];

  // Route paths corresponding to each tab index.
  // Used for future deep-link matching logic.
  // ignore: unused_field
  static const _routes = [
    RouteNames.home,
    RouteNames.workout,
    RouteNames.reports,
    RouteNames.profile,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_destinations.length, (i) {
              final dest = _destinations[i];
              final isSelected = i == selectedIndex;
              return Expanded(
                child: _NavItem(
                  dest: dest,
                  isSelected: isSelected,
                  onTap: () => onDestinationSelected(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.dest,
    required this.isSelected,
    required this.onTap,
  });

  final _TabDest dest;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lime indicator bar above icon when selected
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: 3,
            width: isSelected ? 24 : 0,
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
          ),
          Icon(
            isSelected ? dest.activeIcon : dest.icon,
            color: isSelected ? AppColors.accentPrimary : AppColors.textTertiary,
            size: 24,
          ),
          if (isSelected) ...[
            const SizedBox(height: 2),
            Text(
              dest.label,
              style: const TextStyle(
                color: AppColors.accentPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabDest {
  const _TabDest({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
