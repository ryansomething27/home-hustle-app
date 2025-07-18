import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Loading indicator types
enum LoadingIndicatorType {
  circular,
  linear,
  dots,
  pulse,
}

/// Loading indicator sizes
enum LoadingIndicatorSize {
  small,
  medium,
  large,
}

/// Custom loading indicator widget with various styles
class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({
    super.key,
    this.type = LoadingIndicatorType.circular,
    this.size = LoadingIndicatorSize.medium,
    this.color,
    this.backgroundColor,
    this.strokeWidth,
    this.message,
    this.messageStyle,
    this.spacing = kDefaultPadding,
  });

  final LoadingIndicatorType type;
  final LoadingIndicatorSize size;
  final Color? color;
  final Color? backgroundColor;
  final double? strokeWidth;
  final String? message;
  final TextStyle? messageStyle;
  final double spacing;

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _dotController;
  late AnimationController _pulseController;
  late Animation<double> _dotAnimation1;
  late Animation<double> _dotAnimation2;
  late Animation<double> _dotAnimation3;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize dot animation controller
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    // Initialize pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Create staggered animations for dots
    _dotAnimation1 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _dotController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _dotAnimation2 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _dotController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeInOut),
      ),
    );

    _dotAnimation3 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _dotController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeInOut),
      ),
    );

    // Create pulse animation
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _dotController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  double _getSize() {
    switch (widget.size) {
      case LoadingIndicatorSize.small:
        return 24;
      case LoadingIndicatorSize.medium:
        return 36;
      case LoadingIndicatorSize.large:
        return 48;
    }
  }

  double _getStrokeWidth() {
    if (widget.strokeWidth != null) {
      return widget.strokeWidth!;
    }

    switch (widget.size) {
      case LoadingIndicatorSize.small:
        return 2;
      case LoadingIndicatorSize.medium:
        return 3;
      case LoadingIndicatorSize.large:
        return 4;
    }
  }

  Widget _buildCircularIndicator(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: _getSize(),
      height: _getSize(),
      child: CircularProgressIndicator(
        strokeWidth: _getStrokeWidth(),
        valueColor: AlwaysStoppedAnimation<Color>(color),
        backgroundColor: widget.backgroundColor,
      ),
    );
  }

  Widget _buildLinearIndicator(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: _getSize() * 3,
      child: LinearProgressIndicator(
        minHeight: _getStrokeWidth(),
        valueColor: AlwaysStoppedAnimation<Color>(color),
        backgroundColor: widget.backgroundColor ?? color.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildDotsIndicator(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final dotSize = _getSize() / 3;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _dotAnimation1,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -10 * _dotAnimation1.value),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
        SizedBox(width: dotSize / 2),
        AnimatedBuilder(
          animation: _dotAnimation2,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -10 * _dotAnimation2.value),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
        SizedBox(width: dotSize / 2),
        AnimatedBuilder(
          animation: _dotAnimation3,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -10 * _dotAnimation3.value),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPulseIndicator(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final size = _getSize();

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.3 + (0.3 * _pulseAnimation.value)),
          ),
          child: Center(
            child: Container(
              width: size * 0.6,
              height: size * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndicator(BuildContext context) {
    switch (widget.type) {
      case LoadingIndicatorType.circular:
        return _buildCircularIndicator(context);
      case LoadingIndicatorType.linear:
        return _buildLinearIndicator(context);
      case LoadingIndicatorType.dots:
        return _buildDotsIndicator(context);
      case LoadingIndicatorType.pulse:
        return _buildPulseIndicator(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final indicator = _buildIndicator(context);

    if (widget.message == null) {
      return indicator;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        SizedBox(height: widget.spacing),
        Text(
          widget.message!,
          style: widget.messageStyle ??
              Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    required this.isLoading, required this.child, super.key,
    this.indicator = const LoadingIndicator(),
    this.backgroundColor,
    this.opacity = 0.5,
  });

  final bool isLoading;
  final Widget child;
  final Widget indicator;
  final Color? backgroundColor;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: (backgroundColor ?? Colors.black).withValues(alpha: opacity),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(kLargePadding),
                    child: indicator,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Skeleton loader for content placeholders
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({
    super.key,
    this.width,
    this.height = 20,
    this.borderRadius = kSmallBorderRadius,
    this.baseColor,
    this.highlightColor,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.baseColor ??
        (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final highlightColor = widget.highlightColor ??
        (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}