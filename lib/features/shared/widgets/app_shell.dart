import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.title,
    required this.currentIndex,
    this.actions,
  });

  final Widget child;
  final String title;
  final int currentIndex;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.mobileBreakpoint;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(currentIndex: currentIndex),
            Expanded(
              child: Column(
                children: [
                  _TopBar(title: title, actions: actions),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      drawer: Drawer(
        child: _Sidebar(currentIndex: currentIndex, isCompact: true),
      ),
      body: child,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          ...?actions,
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.currentIndex, this.isCompact = false});

  final int currentIndex;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCompact ? double.infinity : AppConstants.sidebarWidth,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFD),
        border: Border(
          right: BorderSide(color: Color(0xFFE4EAF2)),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SidebarHeader(),
            const SizedBox(height: 12),
            ..._items.map(
              (item) => _SidebarItem(
                item: item,
                isActive: item.index == currentIndex,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Text(
                'Version ${AppConstants.appVersion}',
                style: const TextStyle(color: Color(0xFF8FA0B3), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFFE3EAF4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.inventory_2_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inventory IMS',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  AppConstants.appTagline,
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.item, required this.isActive});

  final _NavigationItem item;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: isActive
            ? null
            : () {
                AppSnackbar.hide();
                Get.offNamed(item.route);
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: isActive ? Colors.white : const Color(0xFF8C99AB),
              ),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF546273),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.index,
    required this.label,
    required this.icon,
    required this.route,
  });

  final int index;
  final String label;
  final IconData icon;
  final String route;
}

const List<_NavigationItem> _items = [
  _NavigationItem(
      index: 0,
      label: 'Dashboard',
      icon: Icons.dashboard_rounded,
      route: AppRoutes.dashboard),
  _NavigationItem(
      index: 1,
      label: 'Products',
      icon: Icons.inventory_2_rounded,
      route: AppRoutes.products),
  _NavigationItem(
      index: 2,
      label: 'Movements',
      icon: Icons.swap_horiz_rounded,
      route: AppRoutes.movements),
  _NavigationItem(
      index: 3,
      label: 'Export',
      icon: Icons.file_download_rounded,
      route: AppRoutes.export),
];
