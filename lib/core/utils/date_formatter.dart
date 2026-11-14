import 'package:intl/intl.dart';

class DateFormatter {
  static String formatTimestamp(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  static String formatShortTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String formatShortDate(DateTime dateTime) {
    return DateFormat('dd MMM').format(dateTime);
  }

  static String formatDayOfWeek(DateTime dateTime) {
    return DateFormat('EEEE').format(dateTime);
  }

  static String formatShortDay(DateTime dateTime) {
    return DateFormat('EEE').format(dateTime);
  }

  static String timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('dd MMM').format(dateTime);
    }
  }
}

