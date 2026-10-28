import 'package:intl/intl.dart';

class AppUtils {
  AppUtils._();

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  static String timeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inDays >= 7) {
      return formatDate(date);
    }
    if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    }
    if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    }
    if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: r'$', decimalDigits: 2).format(amount);
  }

  static String formatNumber(int value) {
    return NumberFormat('#,##0').format(value);
  }
}
