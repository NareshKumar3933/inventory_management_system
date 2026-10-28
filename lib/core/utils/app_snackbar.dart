import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

enum AppSnackbarType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static const double _maxWidth = 560;
  static const EdgeInsets _margin = EdgeInsets.all(12);
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );
  static const double _radius = 12;

  static void hide() {
    final context = Get.context;
    if (context == null) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Get.closeCurrentSnackbar();
  }

  static void hideSnackBar() => hide();

  static void customToast({
    required String message,
    int durationSeconds = 3,
  }) {
    final context = Get.context;
    if (context == null) return;

    final background = AppColors.textSecondary.withValues(alpha: 0.92);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: durationSeconds),
        margin: _margin,
        padding: _padding,
        backgroundColor: background,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius)),
        content: Center(
          child: Text(
            message,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  static void show({
    required String title,
    required String message,
    AppSnackbarType type = AppSnackbarType.info,
    int durationSeconds = 2,
  }) {
    final config = _styleFor(type);
    final context = Get.context;

    if (context != null) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: durationSeconds),
          margin: _margin,
          padding: _padding,
          backgroundColor: config.background,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radius)),
          content: Row(
            children: [
              Icon(config.icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    if (message.trim().isNotEmpty)
                      Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      maxWidth: _maxWidth,
      colorText: Colors.white,
      backgroundColor: config.background,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: durationSeconds),
      margin: _margin,
      icon: Icon(config.icon, color: Colors.white, size: 18),
      borderRadius: _radius,
    );
  }

  static void success({
    required String title,
    String message = '',
    int durationSeconds = 3,
  }) {
    show(
      title: title,
      message: message,
      type: AppSnackbarType.success,
      durationSeconds: durationSeconds,
    );
  }

  static void successSnackBar({
    required String title,
    String message = '',
    int duration = 3,
  }) {
    success(title: title, message: message, durationSeconds: duration);
  }

  static void warning({
    required String title,
    String message = '',
    int durationSeconds = 3,
  }) {
    show(
      title: title,
      message: message,
      type: AppSnackbarType.warning,
      durationSeconds: durationSeconds,
    );
  }

  static void warningSnackBar({
    required String title,
    String message = '',
    int duration = 3,
  }) {
    warning(title: title, message: message, durationSeconds: duration);
  }

  static void error({
    required String title,
    String message = '',
    int durationSeconds = 3,
  }) {
    show(
      title: title,
      message: message,
      type: AppSnackbarType.error,
      durationSeconds: durationSeconds,
    );
  }

  static void errorSnackBar({
    required String title,
    String message = '',
    int duration = 3,
  }) {
    error(title: title, message: message, durationSeconds: duration);
  }

  static _SnackbarStyle _styleFor(AppSnackbarType type) {
    switch (type) {
      case AppSnackbarType.success:
        return const _SnackbarStyle(
            AppColors.success, Icons.check_circle_rounded);
      case AppSnackbarType.error:
        return const _SnackbarStyle(AppColors.error, Icons.error_rounded);
      case AppSnackbarType.warning:
        return const _SnackbarStyle(AppColors.warning, Icons.warning_rounded);
      case AppSnackbarType.info:
        return const _SnackbarStyle(AppColors.info, Icons.info_rounded);
    }
  }
}

class _SnackbarStyle {
  const _SnackbarStyle(this.background, this.icon);

  final Color background;
  final IconData icon;
}
