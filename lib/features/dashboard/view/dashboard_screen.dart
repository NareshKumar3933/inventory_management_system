import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/movement_tile.dart';
import '../../shared/widgets/stat_card.dart';
import '../controller/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell(
      title: 'Dashboard',
      currentIndex: 0,
      child: _DashboardBody(),
    );
  }
}

class _DashboardBody extends GetView<DashboardController> {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: controller.loadDashboard,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          children: const [
            _HeaderBanner(),
            SizedBox(height: 20),
            _KpiSection(),
            SizedBox(height: 20),
            _InsightSection(),
          ],
        ),
      );
    });
  }
}

class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Inventory Overview',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Today ${AppUtils.formatDate(DateTime.now())}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.insights_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _KpiSection extends GetView<DashboardController> {
  const _KpiSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLarge = constraints.maxWidth > 1100;
        final isMedium = constraints.maxWidth > 680;
        final crossAxisCount = isLarge ? 4 : (isMedium ? 2 : 1);

        return GridView.count(
          shrinkWrap: true,
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio:
              crossAxisCount == 1 ? 3.2 : (crossAxisCount == 2 ? 3.0 : 2.25),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StatCard(
              title: 'Total Products',
              value: controller.totalProducts.value.toString(),
              icon: Icons.inventory_2_rounded,
              accent: AppColors.primary,
            ),
            StatCard(
              title: 'Total Stock Units',
              value: AppUtils.formatNumber(controller.totalStock.value),
              icon: Icons.warehouse_rounded,
              accent: AppColors.info,
            ),
            StatCard(
              title: 'Low Stock',
              value: controller.lowStockProducts.length.toString(),
              icon: Icons.warning_amber_rounded,
              accent: AppColors.warning,
              subtitle:
                  controller.lowStockProducts.isEmpty ? 'OK' : 'Attention',
            ),
            StatCard(
              title: 'Recent Movements',
              value: controller.recentMovements.length.toString(),
              icon: Icons.swap_horiz_rounded,
              accent: AppColors.success,
            ),
          ],
        );
      },
    );
  }
}

class _InsightSection extends StatelessWidget {
  const _InsightSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > AppConstants.desktopBreakpoint) {
      return const Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _CategoryChartCard()),
              SizedBox(width: 14),
              Expanded(child: _LowStockCard()),
            ],
          ),
          SizedBox(height: 14),
          _RecentMovementsCard(),
        ],
      );
    }

    if (width > 960) {
      return const Column(
        children: [
          _CategoryChartCard(),
          SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _LowStockCard()),
              SizedBox(width: 14),
              Expanded(child: _RecentMovementsCard()),
            ],
          ),
        ],
      );
    }

    return const Column(
      children: [
        _CategoryChartCard(),
        SizedBox(height: 14),
        _LowStockCard(),
        SizedBox(height: 14),
        _RecentMovementsCard(),
      ],
    );
  }
}

class _CategoryChartCard extends GetView<DashboardController> {
  const _CategoryChartCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Stock by Category',
      child: Obx(() {
        if (controller.categoryStock.isEmpty) {
          return const _EmptyLabel(text: 'No category stock data found.');
        }

        final entries = _buildChartEntries(controller.categoryStock);
        final maxY = entries
            .map((item) => item.value.toDouble())
            .fold<double>(0, (p, c) => c > p ? c : p);
        final interval = maxY <= 50 ? 10.0 : (maxY / 5).ceilToDouble();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 240,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY <= 0 ? 1 : maxY * 1.15,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: interval,
                        reservedSize: 36,
                        getTitlesWidget: (value, _) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                  barGroups: entries.asMap().entries.map((entry) {
                    final isOthers = entry.value.key == _othersCategoryLabel;
                    final color = isOthers
                        ? const Color(0xFF6B7B91)
                        : _palette[entry.key % _palette.length];

                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value.toDouble(),
                          width: 26,
                          borderRadius: BorderRadius.circular(6),
                          color: color,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Custom label row — offset left by reservedSize to align with bars
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Row(
                children: entries.asMap().entries.map((entry) {
                  final isOthers = entry.value.key == _othersCategoryLabel;
                  final color = isOthers
                      ? const Color(0xFF6B7B91)
                      : _palette[entry.key % _palette.length];
                  final label = entry.value.key;

                  return Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }),
    );
  }

  List<MapEntry<String, int>> _buildChartEntries(
      Map<String, int> categoryStock) {
    final sorted = categoryStock.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sorted.length <= _maxChartCategories) {
      return sorted;
    }

    final topItems = sorted.take(_maxChartCategories - 1).toList();
    final othersTotal = sorted
        .skip(_maxChartCategories - 1)
        .fold<int>(0, (sum, entry) => sum + entry.value);
    topItems.add(MapEntry(_othersCategoryLabel, othersTotal));
    return topItems;
  }
}

class _LowStockCard extends GetView<DashboardController> {
  const _LowStockCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Low Stock Products',
      trailing: TextButton(
        onPressed: () => Get.toNamed(AppRoutes.products),
        child: const Text('Open products'),
      ),
      child: Obx(() {
        final items = controller.lowStockProducts;
        if (items.isEmpty) {
          return const _EmptyLabel(text: 'No low-stock products.');
        }

        return Column(
          children: items.take(8).map((item) {
            final warningColor =
                item.quantity == 0 ? AppColors.error : AppColors.warning;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: warningColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: warningColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${item.quantity}/${item.minimumLevel}',
                    style: TextStyle(
                        color: warningColor, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}

class _RecentMovementsCard extends GetView<DashboardController> {
  const _RecentMovementsCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Recent Movements',
      trailing: TextButton(
        onPressed: () => Get.toNamed(AppRoutes.movements),
        child: const Text('View all'),
      ),
      child: Obx(() {
        if (controller.recentMovements.isEmpty) {
          return const _EmptyLabel(text: 'No movements recorded yet.');
        }

        return Column(
          children: controller.recentMovements
              .take(6)
              .map((item) => MovementTile(movement: item))
              .toList(),
        );
      }),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _EmptyLabel extends StatelessWidget {
  const _EmptyLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Center(
        child:
            Text(text, style: const TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}

const List<Color> _palette = [
  AppColors.primary,
  AppColors.info,
  AppColors.success,
  AppColors.warning,
  Color(0xFF0A8475),
  Color(0xFF4267B2),
  Color(0xFF7A8E1D),
];

const int _maxChartCategories = 8;
const String _othersCategoryLabel = 'Others';
