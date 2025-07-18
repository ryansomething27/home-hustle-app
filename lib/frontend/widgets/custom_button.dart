import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Button style types
enum CustomButtonStyle {
  primary,
  secondary,
  outline,
  text,
  danger,
  success,
}

/// Button size variants
enum ButtonSize {
  small,
  medium,
  large,
}

/// Custom button widget with multiple style variants
class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.text, required this.onPressed, super.key,
    this.style = CustomButtonStyle.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.iconPosition = IconPosition.start,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = false,
    this.borderRadius,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.elevation,
    this.loadingIndicatorColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final CustomButtonStyle style;
  final ButtonSize size;
  final IconData? icon;
  final IconPosition iconPosition;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;
  final double? borderRadius;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? elevation;
  final Color? loadingIndicatorColor;

  EdgeInsets _getPadding() {
    if (padding != null) {
      return padding!;
    }

    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: kDefaultPadding,
          vertical: kSmallPadding,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: kLargePadding,
          vertical: kDefaultPadding,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: kLargePadding * 1.5,
          vertical: kDefaultPadding * 1.25,
        );
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 18;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    if (backgroundColor != null) {
      return backgroundColor!;
    }

    final colorScheme = Theme.of(context).colorScheme;
    
    switch (style) {
      case CustomButtonStyle.primary:
        return colorScheme.primary;
      case CustomButtonStyle.secondary:
        return colorScheme.secondary;
      case CustomButtonStyle.danger:
        return kErrorColor;
      case CustomButtonStyle.success:
        return kSuccessColor;
      case CustomButtonStyle.outline:
      case CustomButtonStyle.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor(BuildContext context) {
    if (textColor != null) {
      return textColor!;
    }

    final colorScheme = Theme.of(context).colorScheme;

    switch (style) {
      case CustomButtonStyle.primary:
        return colorScheme.onPrimary;
      case CustomButtonStyle.secondary:
        return colorScheme.onSecondary;
      case CustomButtonStyle.danger:
        return Colors.white;
      case CustomButtonStyle.success:
        return Colors.white;
      case CustomButtonStyle.outline:
        return borderColor ?? colorScheme.primary;
      case CustomButtonStyle.text:
        return colorScheme.primary;
    }
  }

  Color _getBorderColor(BuildContext context) {
    if (borderColor != null) {
      return borderColor!;
    }

    final colorScheme = Theme.of(context).colorScheme;

    switch (style) {
      case CustomButtonStyle.outline:
        return colorScheme.primary;
      case CustomButtonStyle.danger:
        return kErrorColor;
      case CustomButtonStyle.success:
        return kSuccessColor;
      default:
        return Colors.transparent;
    }
  }

  Widget _buildButtonContent(BuildContext context) {
    final content = [
      if (isLoading)
        SizedBox(
          width: _getIconSize(),
          height: _getIconSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              loadingIndicatorColor ?? _getTextColor(context),
            ),
          ),
        )
      else if (icon != null && iconPosition == IconPosition.start)
        Icon(
          icon,
          size: _getIconSize(),
          color: _getTextColor(context),
        ),
      if ((icon != null || isLoading) && iconPosition == IconPosition.start)
        const SizedBox(width: kSmallPadding),
      Flexible(
        child: Text(
          text,
          style: TextStyle(
            fontSize: _getFontSize(),
            fontWeight: FontWeight.w600,
            color: _getTextColor(context),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (icon != null && iconPosition == IconPosition.end && !isLoading)
        const SizedBox(width: kSmallPadding),
      if (icon != null && iconPosition == IconPosition.end && !isLoading)
        Icon(
          icon,
          size: _getIconSize(),
          color: _getTextColor(context),
        ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isDisabled && !isLoading;
    final effectiveOnPressed = isEnabled ? onPressed : null;

    Widget button;

    switch (style) {
      case CustomButtonStyle.text:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? kDefaultBorderRadius,
              ),
            ),
            foregroundColor: _getTextColor(context),
          ),
          child: _buildButtonContent(context),
        );
        break;

      case CustomButtonStyle.outline:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            padding: _getPadding(),
            side: BorderSide(
              color: _getBorderColor(context),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? kDefaultBorderRadius,
              ),
            ),
            foregroundColor: _getTextColor(context),
          ),
          child: _buildButtonContent(context),
        );
        break;

      default:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            padding: _getPadding(),
            backgroundColor: _getBackgroundColor(context),
            foregroundColor: _getTextColor(context),
            elevation: elevation ?? (style == CustomButtonStyle.text ? 0 : kDefaultElevation),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? kDefaultBorderRadius,
              ),
            ),
          ),
          child: _buildButtonContent(context),
        );
        break;
    }

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

/// Icon position in button
enum IconPosition {
  start,
  end,
}