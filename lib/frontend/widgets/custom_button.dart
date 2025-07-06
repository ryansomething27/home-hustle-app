import 'package:flutter/material.dart';
import '../core/theme.dart';

enum ButtonSize { small, medium, large }
enum ButtonStyle { primary, secondary, outlined, danger, success }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle style;
  final ButtonSize size;
  final IconData? icon;
  final IconData? suffixIcon;
  final bool isLoading;
  final bool isExpanded;
  final double? width;
  final EdgeInsetsGeometry? customPadding;
  final BorderRadius? customBorderRadius;
  final Color? customBackgroundColor;
  final Color? customTextColor;
  final double? elevation;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.style = ButtonStyle.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.suffixIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.width,
    this.customPadding,
    this.customBorderRadius,
    this.customBackgroundColor,
    this.customTextColor,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    
    return SizedBox(
      width: isExpanded ? double.infinity : width,
      child: _buildButton(isDisabled),
    );
  }

  Widget _buildButton(bool isDisabled) {
    final backgroundColor = _getBackgroundColor(isDisabled);
    final textColor = _getTextColor(isDisabled);
    final borderRadius = customBorderRadius ?? BorderRadius.circular(_getBorderRadius());
    final padding = customPadding ?? _getPadding();

    if (style == ButtonStyle.outlined) {
      return OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: padding,
          side: BorderSide(
            color: isDisabled 
                ? AppTheme.cream.withOpacity(0.3)
                : backgroundColor,
            width: 2,
          ),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: _buildContent(textColor),
      );
    }

    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: padding,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        elevation: elevation ?? (style == ButtonStyle.primary ? 2 : 0),
        disabledBackgroundColor: backgroundColor.withOpacity(0.5),
        disabledForegroundColor: textColor.withOpacity(0.5),
      ),
      child: _buildContent(textColor),
    );
  }

  Widget _buildContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: _getTextSize(),
        width: _getTextSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    final textWidget = Text(
      text,
      style: TextStyle(
        fontSize: _getTextSize(),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );

    if (icon != null && suffixIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          textWidget,
          const SizedBox(width: 8),
          Icon(suffixIcon, size: _getIconSize()),
        ],
      );
    } else if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          textWidget,
        ],
      );
    } else if (suffixIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          textWidget,
          const SizedBox(width: 8),
          Icon(suffixIcon, size: _getIconSize()),
        ],
      );
    }

    return textWidget;
  }

  Color _getBackgroundColor(bool isDisabled) {
    if (customBackgroundColor != null) return customBackgroundColor!;
    
    switch (style) {
      case ButtonStyle.primary:
        return AppTheme.cream;
      case ButtonStyle.secondary:
        return AppTheme.primaryDark.withOpacity(0.8);
      case ButtonStyle.outlined:
        return AppTheme.cream;
      case ButtonStyle.danger:
        return Colors.red.shade700;
      case ButtonStyle.success:
        return Colors.green.shade700;
    }
  }

  Color _getTextColor(bool isDisabled) {
    if (customTextColor != null) return customTextColor!;
    
    switch (style) {
      case ButtonStyle.primary:
        return AppTheme.primaryDark;
      case ButtonStyle.secondary:
        return AppTheme.cream;
      case ButtonStyle.outlined:
        return AppTheme.cream;
      case ButtonStyle.danger:
        return Colors.white;
      case ButtonStyle.success:
        return Colors.white;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
    }
  }

  double _getTextSize() {
    switch (size) {
      case ButtonSize.small:
        return 13.0;
      case ButtonSize.medium:
        return 15.0;
      case ButtonSize.large:
        return 17.0;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16.0;
      case ButtonSize.medium:
        return 18.0;
      case ButtonSize.large:
        return 20.0;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case ButtonSize.small:
        return 8.0;
      case ButtonSize.medium:
        return 12.0;
      case ButtonSize.large:
        return 16.0;
    }
  }
}

// Icon-only button variant
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ButtonStyle style;
  final ButtonSize size;
  final bool isLoading;
  final Color? customBackgroundColor;
  final Color? customIconColor;
  final String? tooltip;

  const CustomIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.style = ButtonStyle.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.customBackgroundColor,
    this.customIconColor,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    final backgroundColor = _getBackgroundColor(isDisabled);
    final iconColor = _getIconColor(isDisabled);
    final iconSize = _getIconSize();
    final buttonSize = _getButtonSize();

    Widget button = Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: style == ButtonStyle.outlined ? Colors.transparent : backgroundColor,
        shape: BoxShape.circle,
        border: style == ButtonStyle.outlined
            ? Border.all(color: backgroundColor, width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          customBorder: const CircleBorder(),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                    ),
                  )
                : Icon(
                    icon,
                    color: iconColor,
                    size: iconSize,
                  ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }

  Color _getBackgroundColor(bool isDisabled) {
    if (customBackgroundColor != null) return customBackgroundColor!;
    
    switch (style) {
      case ButtonStyle.primary:
        return AppTheme.cream;
      case ButtonStyle.secondary:
        return AppTheme.cream.withOpacity(0.2);
      case ButtonStyle.outlined:
        return AppTheme.cream;
      case ButtonStyle.danger:
        return Colors.red.shade700;
      case ButtonStyle.success:
        return Colors.green.shade700;
    }
  }

  Color _getIconColor(bool isDisabled) {
    if (customIconColor != null) return customIconColor!;
    
    switch (style) {
      case ButtonStyle.primary:
        return AppTheme.primaryDark;
      case ButtonStyle.secondary:
        return AppTheme.cream;
      case ButtonStyle.outlined:
        return AppTheme.cream;
      case ButtonStyle.danger:
        return Colors.white;
      case ButtonStyle.success:
        return Colors.white;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16.0;
      case ButtonSize.medium:
        return 20.0;
      case ButtonSize.large:
        return 24.0;
    }
  }

  double _getButtonSize() {
    switch (size) {
      case ButtonSize.small:
        return 32.0;
      case ButtonSize.medium:
        return 40.0;
      case ButtonSize.large:
        return 48.0;
    }
  }
}

// Text button variant for inline actions
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final IconData? icon;
  final bool isLoading;

  const CustomTextButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.icon,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? AppTheme.cream;
    final isDisabled = onPressed == null || isLoading;

    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: isLoading
          ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16),
                  const SizedBox(width: 4),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize ?? 14,
                    fontWeight: fontWeight ?? FontWeight.w500,
                  ),
                ),
              ],
            ),
    );
  }
}