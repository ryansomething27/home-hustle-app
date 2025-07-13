import 'package:flutter/material.dart';

import '../constants.dart';

// Global key for scaffold messenger
final GlobalKey<ScaffoldMessengerState> messengerKey = 
    GlobalKey<ScaffoldMessengerState>();

// Show success snackbar
void showSuccessSnackbar(String message, {Duration? duration}) {
  _showSnackbar(
    message: message,
    backgroundColor: kSuccessColor,
    icon: Icons.check_circle,
    duration: duration,
  );
}

// Show error snackbar
void showErrorSnackbar(String message, {Duration? duration}) {
  _showSnackbar(
    message: message,
    backgroundColor: kErrorColor,
    icon: Icons.error,
    duration: duration,
  );
}

// Show warning snackbar
void showWarningSnackbar(String message, {Duration? duration}) {
  _showSnackbar(
    message: message,
    backgroundColor: kWarningColor,
    icon: Icons.warning,
    duration: duration,
  );
}

// Show info snackbar
void showInfoSnackbar(String message, {Duration? duration}) {
  _showSnackbar(
    message: message,
    backgroundColor: kInfoColor,
    icon: Icons.info,
    duration: duration,
  );
}

// Show custom snackbar
void showCustomSnackbar({
  required String message,
  Color? backgroundColor,
  Color? textColor,
  IconData? icon,
  Duration? duration,
  SnackBarAction? action,
}) {
  _showSnackbar(
    message: message,
    backgroundColor: backgroundColor,
    textColor: textColor,
    icon: icon,
    duration: duration,
    action: action,
  );
}

// Private method to show snackbar
void _showSnackbar({
  required String message,
  Color? backgroundColor,
  Color? textColor,
  IconData? icon,
  Duration? duration,
  SnackBarAction? action,
}) {
  final messenger = messengerKey.currentState;
  if (messenger == null) return;

  // Hide any existing snackbar and show new one using cascade
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) 
              Icon(
                icon,
                color: textColor ?? Colors.white,
                size: 20,
              ),
            if (icon != null)
              const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? kPrimaryColor,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kSmallBorderRadius),
        ),
        margin: const EdgeInsets.all(kDefaultPadding),
        action: action,
      ),
    );
}

// Hide current snackbar
void hideCurrentSnackbar() {
  messengerKey.currentState?.hideCurrentSnackBar();
}

// Clear all snackbars
void clearSnackbars() {
  messengerKey.currentState?.clearSnackBars();
}