import 'package:flutter/material.dart';

/// Extensions that provide Kotlin-style utilities for Flutter widgets.
extension WidgetExtensions on Widget {
  /// Wraps this widget with padding using EdgeInsets.all().
  ///
  /// Example:
  /// ```dart
  /// Text('Hello').padding(16.0)
  /// // Equivalent to: Padding(padding: EdgeInsets.all(16.0), child: Text('Hello'))
  /// ```
  Widget padding(double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: this,
    );
  }

  /// Wraps this widget with symmetric padding.
  ///
  /// Example:
  /// ```dart
  /// Text('Hello').paddingSymmetric(horizontal: 16.0, vertical: 8.0)
  /// ```
  Widget paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  /// Wraps this widget with specific padding for each side.
  ///
  /// Example:
  /// ```dart
  /// Text('Hello').paddingOnly(left: 16.0, top: 8.0)
  /// ```
  Widget paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }

  /// Wraps this widget with a margin using Container.
  ///
  /// Example:
  /// ```dart
  /// Text('Hello').margin(16.0)
  /// ```
  Widget margin(double margin) {
    return Container(
      margin: EdgeInsets.all(margin),
      child: this,
    );
  }

  /// Wraps this widget with symmetric margin.
  ///
  /// Example:
  /// ```dart
  /// Text('Hello').marginSymmetric(horizontal: 16.0, vertical: 8.0)
  /// ```
  Widget marginSymmetric({double horizontal = 0.0, double vertical = 0.0}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  /// Centers this widget.
  ///
  /// Example:
  /// ```dart
  /// Text('Centered').center()
  /// // Equivalent to: Center(child: Text('Centered'))
  /// ```
  Widget center() {
    return Center(child: this);
  }

  /// Expands this widget to fill available space.
  ///
  /// Example:
  /// ```dart
  /// Text('Expanded').expanded()
  /// // Equivalent to: Expanded(child: Text('Expanded'))
  /// ```
  Widget expanded({int flex = 1}) {
    return Expanded(flex: flex, child: this);
  }

  /// Makes this widget flexible.
  ///
  /// Example:
  /// ```dart
  /// Text('Flexible').flexible()
  /// ```
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(flex: flex, fit: fit, child: this);
  }

  /// Wraps this widget with a Container with optional styling.
  ///
  /// Example:
  /// ```dart
  /// Text('Styled').container(
  ///   color: Colors.blue,
  ///   width: 200,
  ///   height: 100,
  /// )
  /// ```
  Widget container({
    Color? color,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Decoration? decoration,
    BoxConstraints? constraints,
    AlignmentGeometry? alignment,
  }) {
    return Container(
      color: color,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      constraints: constraints,
      alignment: alignment,
      child: this,
    );
  }

  /// Aligns this widget within its parent.
  ///
  /// Example:
  /// ```dart
  /// Text('Aligned').align(Alignment.topRight)
  /// ```
  Widget align(AlignmentGeometry alignment) {
    return Align(alignment: alignment, child: this);
  }

  /// Positions this widget within a Stack.
  ///
  /// Example:
  /// ```dart
  /// Text('Positioned').positioned(top: 10, left: 20)
  /// ```
  Widget positioned({
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
  }) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      child: this,
    );
  }

  /// Wraps this widget with opacity.
  ///
  /// Example:
  /// ```dart
  /// Text('Semi-transparent').opacity(0.5)
  /// ```
  Widget opacity(double opacity) {
    return Opacity(opacity: opacity, child: this);
  }

  /// Makes this widget invisible while maintaining its space.
  ///
  /// Example:
  /// ```dart
  /// Text('Hidden').invisible()
  /// ```
  Widget invisible({bool invisible = true}) {
    return Visibility(
      visible: !invisible,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: this,
    );
  }

  /// Shows or hides this widget.
  ///
  /// Example:
  /// ```dart
  /// Text('Conditional').visible(showText)
  /// ```
  Widget visible(bool visible) {
    return Visibility(visible: visible, child: this);
  }

  /// Adds a tap gesture to this widget.
  ///
  /// Example:
  /// ```dart
  /// Text('Clickable').onTap(() => print('Tapped!'))
  /// ```
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }

  /// Adds a long press gesture to this widget.
  ///
  /// Example:
  /// ```dart
  /// Text('Long press me').onLongPress(() => print('Long pressed!'))
  /// ```
  Widget onLongPress(VoidCallback onLongPress) {
    return GestureDetector(onLongPress: onLongPress, child: this);
  }

  /// Wraps this widget with a Card.
  ///
  /// Example:
  /// ```dart
  /// Text('In Card').card(elevation: 4.0)
  /// ```
  Widget card({
    double? elevation,
    Color? color,
    EdgeInsetsGeometry? margin,
    ShapeBorder? shape,
  }) {
    return Card(
      elevation: elevation,
      color: color,
      margin: margin,
      shape: shape,
      child: this,
    );
  }

  /// Wraps this widget with a rounded Container.
  ///
  /// Example:
  /// ```dart
  /// Text('Rounded').rounded(radius: 12.0, color: Colors.blue)
  /// ```
  Widget rounded({
    double radius = 8.0,
    Color? color,
    Border? border,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: border,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: this,
    );
  }

  /// Clips this widget with rounded corners.
  ///
  /// Example:
  /// ```dart
  /// Image.network(url).clipRRect(radius: 12.0)
  /// ```
  Widget clipRRect({double radius = 8.0}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: this,
    );
  }

  /// Wraps this widget with a Hero for page transitions.
  ///
  /// Example:
  /// ```dart
  /// Image.network(url).hero('image-hero')
  /// ```
  Widget hero(String tag) {
    return Hero(tag: tag, child: this);
  }

  /// Applies a scale transformation to this widget.
  ///
  /// Example:
  /// ```dart
  /// Text('Scaled').scale(1.2)
  /// ```
  Widget scale(double scale) {
    return Transform.scale(scale: scale, child: this);
  }

  /// Applies a rotation transformation to this widget.
  ///
  /// Example:
  /// ```dart
  /// Text('Rotated').rotate(0.1) // Rotate by 0.1 radians
  /// ```
  Widget rotate(double angle) {
    return Transform.rotate(angle: angle, child: this);
  }
}

/// Extensions for lists of widgets to create common Flutter layouts.
extension WidgetListExtensions on List<Widget> {
  /// Creates a Column from this list of widgets.
  ///
  /// Example:
  /// ```dart
  /// [Text('A'), Text('B'), Text('C')].column()
  /// ```
  Widget column({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: this,
    );
  }

  /// Creates a Row from this list of widgets.
  ///
  /// Example:
  /// ```dart
  /// [Icon(Icons.star), Text('Rating')].row()
  /// ```
  Widget row({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: this,
    );
  }

  /// Creates a Wrap from this list of widgets.
  ///
  /// Example:
  /// ```dart
  /// chips.wrap(spacing: 8.0)
  /// ```
  Widget wrap({
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    double spacing = 0.0,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
  }) {
    return Wrap(
      direction: direction,
      alignment: alignment,
      spacing: spacing,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      crossAxisAlignment: crossAxisAlignment,
      children: this,
    );
  }

  /// Creates a Stack from this list of widgets.
  ///
  /// Example:
  /// ```dart
  /// [background, foreground].stack()
  /// ```
  Widget stack({
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    TextDirection? textDirection,
    StackFit fit = StackFit.loose,
    Clip clipBehavior = Clip.hardEdge,
  }) {
    return Stack(
      alignment: alignment,
      textDirection: textDirection,
      fit: fit,
      clipBehavior: clipBehavior,
      children: this,
    );
  }

  /// Adds separators between widgets.
  ///
  /// Example:
  /// ```dart
  /// widgets.separated(Divider())
  /// ```
  List<Widget> separated(Widget separator) {
    if (isEmpty) return this;

    final result = <Widget>[];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(separator);
      }
    }
    return result;
  }

  /// Adds spacing between widgets.
  ///
  /// Example:
  /// ```dart
  /// widgets.spaced(16.0)
  /// ```
  List<Widget> spaced(double spacing) {
    return separated(SizedBox(height: spacing, width: spacing));
  }
}