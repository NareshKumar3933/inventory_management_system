import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    this.subtitle,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 130;
        final iconSize = compact ? 55.0 : 42.0;
        final iconRadius = compact ? 10.0 : 12.0;
        final valueSize = compact ? 16.0 : 24.0;
        final titleSize = compact ? 10.0 : 13.0;
        final subtitleSize = compact ? 10.0 : 11.0;
        final contentPadding = compact ? 10.0 : 18.0;
        final gapAfterTop = compact ? 6.0 : 14.0;
        final gapAfterValue = compact ? 1.0 : 4.0;

        return Container(
          padding: EdgeInsets.all(contentPadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(iconRadius),
                    ),
                    child: Icon(icon, color: accent, size: compact ? 45 : 34),
                  ),
                  const Spacer(),
                  if (subtitle != null && !compact)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          color: accent,
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: gapAfterTop),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: valueSize,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              SizedBox(height: gapAfterValue),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: titleSize,
                  height: 1.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

