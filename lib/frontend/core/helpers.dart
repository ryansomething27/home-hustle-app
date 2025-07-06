import 'package:flutter/material.dart';
import 'constants.dart';

class Helpers {
  // Currency Formatting
  static String formatCurrency(double amount, CurrencyDisplay displayType) {
    if (displayType == CurrencyDisplay.star) {
      final int stars = amount.round();
      return '$stars⭐';
    } else {
      final isNegative = amount < 0;
      final absAmount = amount.abs();
      final dollars = absAmount.floor();
      final cents = ((absAmount - dollars) * 100).round();
      final formattedDollars = _addCommas(dollars);
      return '${isNegative ? '-' : ''}\$$formattedDollars.${cents.toString().padLeft(2, '0')}';
    }
  }
  
  // Format currency without symbol
  static String formatAmount(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final dollars = absAmount.floor();
    final cents = ((absAmount - dollars) * 100).round();
    final formattedDollars = _addCommas(dollars);
    return '${isNegative ? '-' : ''}$formattedDollars.${cents.toString().padLeft(2, '0')}';
  }
  
  // Add commas to numbers
  static String _addCommas(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    int count = 0;
    
    for (int i = str.length - 1; i >= 0; i--) {
      if (count == 3) {
        buffer.write(',');
        count = 0;
      }
      buffer.write(str[i]);
      count++;
    }
    
    return buffer.toString().split('').reversed.join('');
  }
  
  // Parse currency string to double
  static double? parseCurrency(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanValue);
  }
  
  // Date Formatting
  static String formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
  
  static String formatDateTime(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : 
                (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} • $hour:$minute $period';
  }
  
  static String formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : 
                (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
  
  static String formatMonthYear(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 
                   'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.year}';
  }
  
  static String formatDayOfWeek(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 
                 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }
  
  // Time Ago Formatting
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
  
  // Distance Formatting
  static String formatDistance(double miles) {
    if (miles < 0.1) {
      return 'Less than 0.1 mi';
    } else if (miles < 1) {
      return '${(miles * 10).round() / 10} mi';
    } else {
      return '${miles.round()} mi';
    }
  }
  
  // Number Formatting
  static String formatNumber(int number) {
    return _addCommas(number);
  }
  
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
  
  // Name Formatting
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
  }
  
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalizeFirst(word)).join(' ');
  }
  
  // Role Display
  static String getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.parent:
        return 'Parent';
      case UserRole.child:
        return 'Child';
      case UserRole.employer:
        return 'Employer';
    }
  }
  
  // Account Type Display
  static String getAccountTypeDisplay(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return 'Checking';
      case AccountType.savings:
        return 'Savings';
      case AccountType.investment:
        return 'Investment';
    }
  }
  
  // Job Status Display
  static String getJobStatusDisplay(JobStatus status) {
    switch (status) {
      case JobStatus.open:
        return 'Open';
      case JobStatus.pending:
        return 'Pending';
      case JobStatus.assigned:
        return 'Assigned';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.resigned:
        return 'Resigned';
      case JobStatus.cancelled:
        return 'Cancelled';
    }
  }
  
  // Job Status Color
  static Color getJobStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.open:
        return Colors.blue;
      case JobStatus.pending:
        return Colors.orange;
      case JobStatus.assigned:
        return Colors.purple;
      case JobStatus.completed:
        return Colors.green;
      case JobStatus.resigned:
        return Colors.grey;
      case JobStatus.cancelled:
        return Colors.red;
    }
  }
  
  // Validation Helpers
  static bool isValidEmail(String email) {
    return RegexPatterns.email.hasMatch(email.trim());
  }
  
  static bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return RegexPatterns.phone.hasMatch(cleaned);
  }
  
  static bool isValidCurrency(String amount) {
    return RegexPatterns.currency.hasMatch(amount);
  }
  
  static bool isValidPassword(String password) {
    return password.length >= ValidationConstants.minPasswordLength &&
           password.length <= ValidationConstants.maxPasswordLength;
  }
  
  // Error Handling
  static String getErrorMessage(dynamic error) {
    if (error.toString().contains('network')) {
      return ErrorMessages.networkError;
    } else if (error.toString().contains('permission')) {
      return ErrorMessages.unauthorized;
    } else if (error.toString().contains('email-already-in-use')) {
      return ErrorMessages.emailAlreadyExists;
    } else if (error.toString().contains('wrong-password')) {
      return ErrorMessages.invalidCredentials;
    } else if (error.toString().contains('user-not-found')) {
      return ErrorMessages.invalidCredentials;
    } else {
      return ErrorMessages.serverError;
    }
  }
  
  // UI Helpers
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
  
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 24),
            Expanded(
              child: Text(message ?? 'Loading...'),
            ),
          ],
        ),
      ),
    );
  }
  
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  // Platform Helpers
  static bool isIOS(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }
  
  static bool isAndroid(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.android;
  }
  
  // Age Calculation
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
  
  // Job Schedule Helpers
  static String formatJobSchedule(List<String> days, String time) {
    if (days.isEmpty) return 'Flexible schedule';
    
    final dayAbbr = {
      'Monday': 'Mon',
      'Tuesday': 'Tue',
      'Wednesday': 'Wed',
      'Thursday': 'Thu',
      'Friday': 'Fri',
      'Saturday': 'Sat',
      'Sunday': 'Sun',
    };
    
    final abbreviated = days.map((day) => dayAbbr[day] ?? day).join(', ');
    return '$abbreviated • $time';
  }
  
  // Interest Calculation
  static double calculateInterest(double principal, double rate, int months) {
    return principal * rate * months;
  }
  
  static double calculateCompoundInterest(double principal, double rate, int months) {
    return principal * (1 + rate) * months - principal;
  }
  
  // Truncate Text
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }
  
  // Parse Duration
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '$hours hr${hours > 1 ? 's' : ''} ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return '$minutes min${minutes > 1 ? 's' : ''}';
    }
  }
}