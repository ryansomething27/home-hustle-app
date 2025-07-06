import 'package:flutter/material.dart';
import '../core/theme.dart';

enum LoadingSize { small, medium, large }
enum LoadingStyle { circular, linear, dots, custom }

class LoadingIndicator extends StatelessWidget {
  final LoadingSize size;
  final LoadingStyle style;
  final String? message;
  final Color? color;
  final double? value;
  final bool showBackground;
  final EdgeInsetsGeometry? padding;

  const LoadingIndicator({
    Key? key,
    this.size = LoadingSize.medium,
    this.style = LoadingStyle.circular,
    this.message,
    this.color,
    this.value,
    this.showBackground = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget indicator = _buildIndicator();
    
    if (message != null) {
      indicator = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          indicator,
          SizedBox(height: _getSpacing()),
          Text(
            message!,
            style: TextStyle(
              color: color ?? AppTheme.cream,
              fontSize: _getTextSize(),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (padding != null) {
      indicator = Padding(padding: padding!, child: indicator);
    }

    if (showBackground) {
      return Container(
        color: AppTheme.primaryDark.withOpacity(0.9),
        child: Center(child: indicator),
      );
    }

    return Center(child: indicator);
  }

  Widget _buildIndicator() {
    switch (style) {
      case LoadingStyle.circular:
        return _buildCircularIndicator();
      case LoadingStyle.linear:
        return _buildLinearIndicator();
      case LoadingStyle.dots:
        return _buildDotsIndicator();
      case LoadingStyle.custom:
        return _buildCustomIndicator();
    }
  }

  Widget _buildCircularIndicator() {
    return SizedBox(
      width: _getSize(),
      height: _getSize(),
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: _getStrokeWidth(),
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppTheme.cream),
        backgroundColor: (color ?? AppTheme.cream).withOpacity(0.2),
      ),
    );
  }

  Widget _buildLinearIndicator() {
    return SizedBox(
      width: _getLinearWidth(),
      child: LinearProgressIndicator(
        value: value,
        minHeight: _getStrokeWidth(),
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppTheme.cream),
        backgroundColor: (color ?? AppTheme.cream).withOpacity(0.2),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 200)),
          builder: (context, value, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: _getDotSize(),
              height: _getDotSize(),
              decoration: BoxDecoration(
                color: (color ?? AppTheme.cream).withOpacity(0.3 + (value * 0.7)),
                shape: BoxShape.circle,
              ),
            );
          },
          onEnd: () {
            // Loop animation would go here in a stateful widget
          },
        );
      }),
    );
  }

  Widget _buildCustomIndicator() {
    // Placeholder for future custom animation (e.g., Home Hustle logo)
    return Container(
      width: _getSize(),
      height: _getSize(),
      decoration: BoxDecoration(
        color: AppTheme.cream.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'HH',
          style: TextStyle(
            color: color ?? AppTheme.cream,
            fontSize: _getSize() * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  double _getSize() {
    switch (size) {
      case LoadingSize.small:
        return 20.0;
      case LoadingSize.medium:
        return 36.0;
      case LoadingSize.large:
        return 56.0;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case LoadingSize.small:
        return 2.0;
      case LoadingSize.medium:
        return 3.0;
      case LoadingSize.large:
        return 4.0;
    }
  }

  double _getLinearWidth() {
    switch (size) {
      case LoadingSize.small:
        return 100.0;
      case LoadingSize.medium:
        return 200.0;
      case LoadingSize.large:
        return 300.0;
    }
  }

  double _getDotSize() {
    switch (size) {
      case LoadingSize.small:
        return 6.0;
      case LoadingSize.medium:
        return 10.0;
      case LoadingSize.large:
        return 14.0;
    }
  }

  double _getSpacing() {
    switch (size) {
      case LoadingSize.small:
        return 8.0;
      case LoadingSize.medium:
        return 12.0;
      case LoadingSize.large:
        return 16.0;
    }
  }

  double _getTextSize() {
    switch (size) {
      case LoadingSize.small:
        return 12.0;
      case LoadingSize.medium:
        return 14.0;
      case LoadingSize.large:
        return 16.0;
    }
  }
}

// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isVisible;
  final Widget child;
  final Color? backgroundColor;

  const LoadingOverlay({
    Key? key,
    required this.child,
    this.isVisible = false,
    this.message,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isVisible)
          Positioned.fill(
            child: Container(
              color: backgroundColor ?? AppTheme.primaryDark.withOpacity(0.9),
              child: LoadingIndicator(
                size: LoadingSize.large,
                message: message,
                showBackground: false,
              ),
            ),
          ),
      ],
    );
  }
}

// Inline loading for buttons and small spaces
class InlineLoadingIndicator extends StatelessWidget {
  final LoadingSize size;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  const InlineLoadingIndicator({
    Key? key,
    this.size = LoadingSize.small,
    this.color,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget indicator = LoadingIndicator(
      size: size,
      color: color,
      showBackground: false,
    );

    if (margin != null) {
      return Container(
        margin: margin,
        child: indicator,
      );
    }

    return indicator;
  }
}

// Skeleton loader for content placeholders
class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoader({
    Key? key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 20,
      margin: margin,
      decoration: BoxDecoration(
        color: AppTheme.cream.withOpacity(0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

// List skeleton loader
class ListSkeletonLoader extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;

  const ListSkeletonLoader({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          height: itemHeight,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SkeletonLoader(
                width: itemHeight - 20,
                height: itemHeight - 20,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SkeletonLoader(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                    const SizedBox(height: 8),
                    SkeletonLoader(
                      height: 12,
                      width: MediaQuery.of(context).size.width * 0.3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}