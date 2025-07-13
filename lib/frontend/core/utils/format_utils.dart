import 'package:intl/intl.dart';

/// Utility class containing all formatting functions used throughout the app
class FormatUtils {
  // Private constructor to prevent instantiation
  FormatUtils._();
  
  // Date/Time Formatters
  static final DateFormat _dateFormatter = DateFormat('MMM d, yyyy');
  static final DateFormat _dateTimeFormatter = DateFormat('MMM d, yyyy h:mm a');
  static final DateFormat _timeFormatter = DateFormat('h:mm a');
  static final DateFormat _dayMonthFormatter = DateFormat('MMM d');
  static final DateFormat _monthYearFormatter = DateFormat('MMMM yyyy');
  static final DateFormat _fullDateFormatter = DateFormat('EEEE, MMMM d, yyyy');
  static final DateFormat _shortDateFormatter = DateFormat('MM/dd/yy');
  
  // Currency Formatter
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 2,
  );
  
  // Number Formatters
  static final NumberFormat _decimalFormatter = NumberFormat.decimalPattern('en_US');
  static final NumberFormat _compactFormatter = NumberFormat.compact(locale: 'en_US');
  
  /// Formats currency values
  static String formatCurrency(double amount, {bool showSymbol = true}) {
    if (!showSymbol) {
      return amount.toStringAsFixed(2);
    }
    return _currencyFormatter.format(amount);
  }
  
  /// Formats currency from cents (useful for API responses)
  static String formatCurrencyFromCents(int cents, {bool showSymbol = true}) {
    return formatCurrency(cents / 100, showSymbol: showSymbol);
  }
  
  /// Formats date to "Jan 1, 2024" format
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }
  
  /// Formats date and time to "Jan 1, 2024 3:30 PM" format
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormatter.format(dateTime);
  }
  
  /// Formats time to "3:30 PM" format
  static String formatTime(DateTime time) {
    return _timeFormatter.format(time);
  }
  
  /// Formats date to "Jan 1" format (no year)
  static String formatDayMonth(DateTime date) {
    return _dayMonthFormatter.format(date);
  }
  
  /// Formats date to "January 2024" format
  static String formatMonthYear(DateTime date) {
    return _monthYearFormatter.format(date);
  }
  
  /// Formats date to "Monday, January 1, 2024" format
  static String formatFullDate(DateTime date) {
    return _fullDateFormatter.format(date);
  }
  
  /// Formats date to "01/01/24" format
  static String formatShortDate(DateTime date) {
    return _shortDateFormatter.format(date);
  }
  
  /// Formats relative time (e.g., "2 hours ago", "3 days ago")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
  
  /// Formats phone number to (123) 456-7890 format
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-numeric characters
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length != 10) {
      return phoneNumber; // Return original if not 10 digits
    }
    
    return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
  }
  
  /// Formats name with proper capitalization
  static String formatName(String name) {
    if (name.isEmpty) {
      return name;
    }
    
    return name.split(' ').map((word) {
      if (word.isEmpty) {
        return word;
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  /// Formats full name from first and last name
  static String formatFullName(String firstName, String lastName) {
    final formattedFirst = formatName(firstName.trim());
    final formattedLast = formatName(lastName.trim());
    return '$formattedFirst $formattedLast'.trim();
  }
  
  /// Formats initials from name
  static String formatInitials(String firstName, String lastName) {
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }
  
  /// Formats number with thousand separators
  static String formatNumber(num number, {int? decimalPlaces}) {
    if (decimalPlaces != null) {
      return NumberFormat.decimalPattern('en_US')
          .format(double.parse(number.toStringAsFixed(decimalPlaces)));
    }
    return _decimalFormatter.format(number);
  }
  
  /// Formats number as percentage
  static String formatPercent(double value, {int decimalPlaces = 0}) {
    final formatter = NumberFormat.percentPattern('en_US')
      ..minimumFractionDigits = decimalPlaces
      ..maximumFractionDigits = decimalPlaces;
    return formatter.format(value);
  }
  
  /// Formats large numbers in compact form (e.g., 1.2K, 3.4M)
  static String formatCompactNumber(num number) {
    return _compactFormatter.format(number);
  }
  
  /// Formats file size in human-readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  /// Formats duration in human-readable format
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      final days = duration.inDays;
      final hours = duration.inHours.remainder(24);
      return '$days ${days == 1 ? 'day' : 'days'}${hours > 0 ? ' $hours ${hours == 1 ? 'hour' : 'hours'}' : ''}';
    } else if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      return '$hours ${hours == 1 ? 'hour' : 'hours'}${minutes > 0 ? ' $minutes ${minutes == 1 ? 'minute' : 'minutes'}' : ''}';
    } else if (duration.inMinutes > 0) {
      final minutes = duration.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    } else {
      final seconds = duration.inSeconds;
      return '$seconds ${seconds == 1 ? 'second' : 'seconds'}';
    }
  }
  
  /// Formats job status for display
  static String formatJobStatus(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'pending_approval':
        return 'Pending Approval';
      default:
        return formatName(status.replaceAll('_', ' '));
    }
  }
  
  /// Formats account type for display
  static String formatAccountType(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'adult':
        return 'Adult';
      case 'child':
        return 'Child';
      default:
        return formatName(accountType);
    }
  }
  
  /// Formats job type for display
  static String formatJobType(String jobType) {
    switch (jobType.toLowerCase()) {
      case 'family':
        return 'Family Job';
      case 'public':
        return 'Public Job';
      default:
        return formatName(jobType);
    }
  }
  
  /// Truncates text with ellipsis
  static String truncateText(String text, int maxLength, {String ellipsis = '...'}) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }
  
  /// Formats age from birth date
  static String formatAge(DateTime birthDate) {
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return '$age ${age == 1 ? 'year' : 'years'} old';
  }
  
  /// Formats time range (e.g., "9:00 AM - 5:00 PM")
  static String formatTimeRange(DateTime start, DateTime end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }
  
  /// Formats date range
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year) {
      if (start.month == end.month && start.day == end.day) {
        // Same day
        return formatDate(start);
      } else if (start.month == end.month) {
        // Same month
        return '${_dayMonthFormatter.format(start)} - ${formatDate(end)}';
      } else {
        // Different months, same year
        return '${_dayMonthFormatter.format(start)} - ${formatDate(end)}';
      }
    } else {
      // Different years
      return '${formatDate(start)} - ${formatDate(end)}';
    }
  }
  
  /// Formats ordinal numbers (1st, 2nd, 3rd, etc.)
  static String formatOrdinal(int number) {
    if (number >= 11 && number <= 13) {
      return '${number}th';
    }
    
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }
}