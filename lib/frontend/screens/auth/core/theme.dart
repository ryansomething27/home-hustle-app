import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';

/// App theme configuration for Material Design 3
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();
  
  /// Light theme configuration
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimaryColor,
      brightness: Brightness.light,
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      error: kErrorColor,
      surface: Colors.white,
      background: const Color(0xFFF8F9FA),
    ),
    
    // App Bar Theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(
        color: Colors.black87,
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        ),
        side: BorderSide(color: kPrimaryColor, width: 1.5),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      elevation: 2,
      margin: const EdgeInsets.all(kSmallPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: BorderSide(color: kPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: BorderSide(color: kErrorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: BorderSide(color: kErrorColor, width: 2),
      ),
      labelStyle: TextStyle(
        color: Colors.grey[700],
        fontSize: 16,
      ),
      hintStyle: TextStyle(
        color: Colors.grey[500],
        fontSize: 16,
      ),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 8,
      selectedItemColor: kPrimaryColor,
      unselectedItemColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kSmallBorderRadius),
      ),
    ),
    
    // Dialog Theme
    dialogTheme: DialogThemeData(
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
      ),
    ),
    
    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kSmallBorderRadius),
      ),
    ),
    
    // List Tile Theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kSmallPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
      ),
    ),
    
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: Colors.grey[300],
      thickness: 1,
      space: kDefaultPadding * 2,
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
  
  /// Dark theme configuration
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimaryColor,
      brightness: Brightness.dark,
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      error: kErrorColor,
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
    ),
    
    // App Bar Theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: const Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        ),
        side: BorderSide(color: kPrimaryColor, width: 1.5),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      elevation: 2,
      color: const Color(0xFF2A2A2A),
      margin: const EdgeInsets.all(kSmallPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: BorderSide(color: Colors.grey[700]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: BorderSide(color: kPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: BorderSide(color: kErrorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: BorderSide(color: kErrorColor, width: 2),
      ),
      labelStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: 16,
      ),
      hintStyle: TextStyle(
        color: Colors.grey[600],
        fontSize: 16,
      ),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 8,
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: kPrimaryColor,
      unselectedItemColor: Colors.grey[500],
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kSmallBorderRadius),
      ),
    ),
    
    // Dialog Theme
    dialogTheme: DialogThemeData(
      elevation: 16,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
      ),
    ),
    
    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kSmallBorderRadius),
      ),
    ),
    
    // List Tile Theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kSmallPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
      ),
    ),
    
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: Colors.grey[800],
      thickness: 1,
      space: kDefaultPadding * 2,
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
  
  /// Get theme based on brightness
  static ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.light ? lightTheme : darkTheme;
  }
  
  /// Custom theme extensions for role-specific styling
  static ThemeData getAdultTheme({required Brightness brightness}) {
    final baseTheme = getTheme(brightness);
    return baseTheme.copyWith(
      // Adult-specific customizations can go here
      // For example, different primary color shade or specific component styling
    );
  }
  
  static ThemeData getChildTheme({required Brightness brightness}) {
    final baseTheme = getTheme(brightness);
    return baseTheme.copyWith(
      // Child-specific customizations can go here
      // For example, more playful colors or larger text
      textTheme: baseTheme.textTheme.apply(
        fontSizeFactor: 1.1, // Slightly larger text for children
      ),
    );
  }
}