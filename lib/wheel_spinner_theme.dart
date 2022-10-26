import 'package:flutter/material.dart';

/// The theme for the wheel spinner
/// You can use the constructor [WheelSpinnerThemeData] to create your own theme,
/// or use [WheelSpinnerThemeData.light()] or [WheelSpinnerThemeData.dark()] and then use [copyWith] to
/// override only specifics.
class WheelSpinnerThemeData {
  /// Override box decoration for the control
  final BoxDecoration? boxDecoration;

  /// Override box border for the control's [boxDecoration].
  /// If [boxDecoration] is specified, this is ignored.
  final Border? border;

  /// Override border radius for the control's [boxDecoration].
  /// If [boxDecoration] is specified, this is ignored.
  final BorderRadius? borderRadius;

  /// Override background color for the control's [boxDecoration].
  /// If [boxDecoration] or [gradient] is specified, this is ignored.
  final Color? color;

  /// Override background gradient for the control's [boxDecoration].
  /// If [boxDecoration] is specified, this is ignored.
  final Gradient? gradient;

  /// Amount of lines dividing the control. Defaults to 10.
  final int dividerCount;

  /// Color of the lines dividing the control.
  final Color? dividerColor;

  /// Create a new theme for the wheel spinner
  WheelSpinnerThemeData({
    this.boxDecoration,
    this.border,
    this.borderRadius = defaultBorderRadius,
    this.color,
    this.gradient,
    this.dividerCount = 10,
    this.dividerColor,
  });

  /// default shadow offset for both light+dark themes
  static const double defaultShadowOffset = 0.2;

  /// default border radius for both light+dark themes
  static const BorderRadius defaultBorderRadius =
      BorderRadius.all(Radius.circular(8));

  /// A default light theme
  WheelSpinnerThemeData.light()
      : dividerColor = Colors.grey[600],
        dividerCount = 10,
        border = Border.all(
          width: 1,
          style: BorderStyle.solid,
          color: Colors.grey[600]!,
        ),
        gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [
            0.0,
            defaultShadowOffset,
            1.0 - defaultShadowOffset,
            1.0
          ],
          colors: [
            Colors.grey[350]!,
            Colors.grey[50]!,
            Colors.grey[50]!,
            Colors.grey[350]!
          ],
        ),
        borderRadius = defaultBorderRadius,
        boxDecoration = null,
        color = null;

  /// A default dark theme
  WheelSpinnerThemeData.dark()
      : dividerColor = Colors.grey[800],
        dividerCount = 10,
        border = null,
        gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, defaultShadowOffset, 1 - defaultShadowOffset, 1.0],
          colors: [
            Colors.black,
            Colors.grey[900]!,
            Colors.grey[900]!,
            Colors.black
          ],
        ),
        borderRadius = defaultBorderRadius,
        boxDecoration = null,
        color = null;

  /// Create a new theme based on this one, but with the given properties overridden.
  /// For each property that is null, the original value is used.
  WheelSpinnerThemeData copyWith({
    BoxDecoration? boxDecoration,
    Border? border,
    BorderRadius? borderRadius,
    Color? color,
    Gradient? gradient,
    int? dividerCount,
    Color? dividerColor,
  }) =>
      WheelSpinnerThemeData(
        boxDecoration: boxDecoration ?? this.boxDecoration,
        border: border ?? this.border,
        borderRadius: borderRadius ?? this.borderRadius,
        color: color ?? this.color,
        gradient: gradient ?? this.gradient,
        dividerCount: dividerCount ?? this.dividerCount,
        dividerColor: dividerColor ?? this.dividerColor,
      );
}

/// Theme container widget for the wheel spinner theme.
///
/// Any wheel spinners below this widget in the tree will
/// inherit the theme given in [data], except when overridden manually as a property of the wheel spinner itself.
class WheelSpinnerTheme extends InheritedWidget {
  /// The theme data for the children of this widget
  final WheelSpinnerThemeData data;

  const WheelSpinnerTheme({
    super.key,
    required this.data,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant WheelSpinnerTheme oldWidget) =>
      oldWidget.data != data;

  /// Get the nearest wheel spinner theme data up the widget tree from the given context.
  static WheelSpinnerThemeData? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WheelSpinnerTheme>()?.data;

  /// A default light theme
  static WheelSpinnerThemeData light() => WheelSpinnerThemeData.light();

  /// A default dark theme
  static WheelSpinnerThemeData dark() => WheelSpinnerThemeData.dark();
}
