import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/movement_model.dart';
import '../../shared/widgets/app_shell.dart';
import '../controller/movement_controller.dart';

class MovementListScreen extends StatelessWidget {
  const MovementListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Inventory Movements',
      currentIndex: 2,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.addMovement),
            icon: const Icon(Icons.add),
            label: const Text('Record Movement'),
          ),
        ),
      ],
      child: const _MovementBody(),
    );
  }
}

class _MovementBody extends GetView<MovementController> {
  const _MovementBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.movements.isEmpty) {
          return const _EmptyMovementState();
        }

        final total = controller.movements.length;
        final inwardCount =
            controller.movements.where((item) => item.type == MovementType.inward).length;
        final outwardCount =
            controller.movements.where((item) => item.type == MovementType.outward).length;
        final adjustmentCount =
            controller.movements.where((item) => item.type == MovementType.adjustment).length;

        return Column(
          children: [
            _SummaryStrip(
              total: total,
              inward: inwardCount,
              outward: outwardCount,
              adjustment: adjustmentCount,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 860) {
                    return _CompactMovementList(movements: controller.movements);
                  }
                  return _DesktopMovementTable(movements: controller.movements);
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.total,
    required this.inward,
    required this.outward,
    required this.adjustment,
  });

  final int total;
  final int inward;
  final int outward;
  final int adjustment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            children: [
              Expanded(
                child: _StatChip(
                  title: 'Total',
                  value: total.toString(),
                  color: AppColors.info,
                  icon: Icons.swap_horiz_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  title: 'IN',
                  value: inward.toString(),
                  color: AppColors.stockIn,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  title: 'OUT',
                  value: outward.toString(),
                  color: AppColors.stockOut,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  title: 'ADJUST',
                  value: adjustment.toString(),
                  color: AppColors.stockAdjustment,
                  icon: Icons.tune_rounded,
                ),
              ),
            ],
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SizedBox(
              width: (constraints.maxWidth - 8) / 2,
              child: _StatChip(
                title: 'Total',
                value: total.toString(),
                color: AppColors.info,
                icon: Icons.swap_horiz_rounded,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - 8) / 2,
              child: _StatChip(
                title: 'IN',
                value: inward.toString(),
                color: AppColors.stockIn,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - 8) / 2,
              child: _StatChip(
                title: 'OUT',
                value: outward.toString(),
                color: AppColors.stockOut,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - 8) / 2,
              child: _StatChip(
                title: 'ADJUST',
                value: adjustment.toString(),
                color: AppColors.stockAdjustment,
                icon: Icons.tune_rounded,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopMovementTable extends StatelessWidget {
  const _DesktopMovementTable({required this.movements});

  final List<MovementModel> movements;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 5, child: Text('Product', style: _HeaderStyle.text)),
                Expanded(flex: 2, child: Text('Type', style: _HeaderStyle.text)),
                Expanded(flex: 2, child: Text('Quantity', style: _HeaderStyle.text)),
                Expanded(flex: 4, child: Text('Note', style: _HeaderStyle.text)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: movements.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final movement = movements[index];
                final color = _typeColor(movement.type);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(_typeIcon(movement.type), size: 16, color: color),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                movement.productName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _TypeBadge(type: movement.type),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          movement.quantity.toString(),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          movement.note.isEmpty ? '-' : movement.note,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactMovementList extends StatelessWidget {
  const _CompactMovementList({required this.movements});

  final List<MovementModel> movements;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: movements.length,
      itemBuilder: (context, index) {
        final movement = movements[index];
        final color = _typeColor(movement.type);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_typeIcon(movement.type), color: color, size: 15),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movement.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (movement.note.trim().isNotEmpty)
                      Text(
                        movement.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _TypeBadge(type: movement.type),
                  const SizedBox(height: 2),
                  Text(
                    movement.quantity.toString(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final MovementType type;

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type.code,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _HeaderStyle {
  static const text = TextStyle(
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
    fontSize: 13,
  );
}

Color _typeColor(MovementType type) {
  switch (type) {
    case MovementType.inward:
      return AppColors.stockIn;
    case MovementType.outward:
      return AppColors.stockOut;
    case MovementType.adjustment:
      return AppColors.stockAdjustment;
  }
}

IconData _typeIcon(MovementType type) {
  switch (type) {
    case MovementType.inward:
      return Icons.arrow_downward_rounded;
    case MovementType.outward:
      return Icons.arrow_upward_rounded;
    case MovementType.adjustment:
      return Icons.tune_rounded;
  }
}

class _EmptyMovementState extends StatelessWidget {
  const _EmptyMovementState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.swap_horiz_rounded, size: 74, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          const Text('No movement records found', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.addMovement),
            icon: const Icon(Icons.add),
            label: const Text('Record first movement'),
          ),
        ],
      ),
    );
  }
}
