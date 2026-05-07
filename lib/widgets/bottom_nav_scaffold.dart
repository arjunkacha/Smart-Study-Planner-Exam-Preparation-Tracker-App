import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

/// Bottom navigation scaffold wrapping the main screens
class BottomNavScaffold extends StatelessWidget {
  final Widget child;
  final String location;

  const BottomNavScaffold({
    super.key,
    required this.child,
    required this.location,
  });

  int _getSelectedIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/subjects')) return 1;
    if (location.startsWith('/schedule')) return 2;
    if (location.startsWith('/progress')) return 3;
    if (location.startsWith('/search')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(location);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Home',
                  isSelected: selectedIndex == 0,
                  onTap: () => context.go('/dashboard'),
                ),
                _NavItem(
                  icon: Icons.library_books_outlined,
                  activeIcon: Icons.library_books_rounded,
                  label: 'Subjects',
                  isSelected: selectedIndex == 1,
                  onTap: () => context.go('/subjects'),
                ),
                _NavItem(
                  icon: Icons.calendar_month_outlined,
                  activeIcon: Icons.calendar_month_rounded,
                  label: 'Schedule',
                  isSelected: selectedIndex == 2,
                  onTap: () => context.go('/schedule'),
                ),
                _NavItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart_rounded,
                  label: 'Progress',
                  isSelected: selectedIndex == 3,
                  onTap: () => context.go('/progress'),
                ),
                _NavItem(
                  icon: Icons.search_outlined,
                  activeIcon: Icons.search_rounded,
                  label: 'Search',
                  isSelected: selectedIndex == 4,
                  onTap: () => context.go('/search'),
                ),
              ],
            ),
          ),
        ),
      ),
      // Settings accessible from AppBar action (not in bottom nav to save space)
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.textSecondary,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
