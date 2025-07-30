import 'package:flutter/material.dart';

/// Extensions that provide convenient access to common BuildContext operations.
extension BuildContextExtensions on BuildContext {
  /// Gets the current theme data.
  ///
  /// Example:
  /// ```dart
  /// final primaryColor = context.theme.primaryColor;
  /// ```
  ThemeData get theme => Theme.of(this);

  /// Gets the current text theme.
  ///
  /// Example:
  /// ```dart
  /// final headlineStyle = context.textTheme.headlineMedium;
  /// ```
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Gets the current color scheme.
  ///
  /// Example:
  /// ```dart
  /// final primaryColor = context.colorScheme.primary;
  /// ```
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Gets the current media query data.
  ///
  /// Example:
  /// ```dart
  /// final screenWidth = context.mediaQuery.size.width;
  /// ```
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Gets the screen size.
  ///
  /// Example:
  /// ```dart
  /// final screenSize = context.screenSize;
  /// final width = context.screenSize.width;
  /// ```
  Size get screenSize => MediaQuery.of(this).size;

  /// Gets the screen width.
  ///
  /// Example:
  /// ```dart
  /// final width = context.screenWidth;
  /// ```
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Gets the screen height.
  ///
  /// Example:
  /// ```dart
  /// final height = context.screenHeight;
  /// ```
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Gets the device pixel ratio.
  ///
  /// Example:
  /// ```dart
  /// final pixelRatio = context.devicePixelRatio;
  /// ```
  double get devicePixelRatio => MediaQuery.of(this).devicePixelRatio;

  /// Gets the screen padding (safe area insets).
  ///
  /// Example:
  /// ```dart
  /// final topPadding = context.padding.top; // Status bar height
  /// ```
  EdgeInsets get padding => MediaQuery.of(this).padding;

  /// Gets the view insets (keyboard height, etc.).
  ///
  /// Example:
  /// ```dart
  /// final keyboardHeight = context.viewInsets.bottom;
  /// ```
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  /// Checks if the device is in dark mode.
  ///
  /// Example:
  /// ```dart
  /// if (context.isDarkMode) {
  ///   // Use dark theme colors
  /// }
  /// ```
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Checks if the device is in portrait orientation.
  ///
  /// Example:
  /// ```dart
  /// if (context.isPortrait) {
  ///   // Show vertical layout
  /// }
  /// ```
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;

  /// Checks if the device is in landscape orientation.
  ///
  /// Example:
  /// ```dart
  /// if (context.isLandscape) {
  ///   // Show horizontal layout
  /// }
  /// ```
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;

  /// Checks if the keyboard is visible.
  ///
  /// Example:
  /// ```dart
  /// if (context.isKeyboardVisible) {
  ///   // Adjust layout for keyboard
  /// }
  /// ```
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Gets responsive breakpoints for the screen width.
  ///
  /// Example:
  /// ```dart
  /// if (context.isTablet) {
  ///   // Show tablet layout
  /// }
  /// ```
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;

  /// Gets the current navigator.
  ///
  /// Example:
  /// ```dart
  /// context.navigator.pop();
  /// ```
  NavigatorState get navigator => Navigator.of(this);

  /// Gets the current scaffold messenger.
  ///
  /// Example:
  /// ```dart
  /// context.scaffoldMessenger.showSnackBar(snackBar);
  /// ```
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);

  /// Gets the current focus scope.
  ///
  /// Example:
  /// ```dart
  /// context.focusScope.unfocus(); // Hide keyboard
  /// ```
  FocusScopeNode get focusScope => FocusScope.of(this);

  /// Pushes a new route and returns the result.
  ///
  /// Example:
  /// ```dart
  /// final result = await context.push(DetailPage());
  /// ```
  Future<T?> push<T extends Object?>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Pushes a new route and replaces the current one.
  ///
  /// Example:
  /// ```dart
  /// context.pushReplacement(HomePage());
  /// ```
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(Widget page) {
    return Navigator.of(this).pushReplacement<T, TO>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Pushes a new route and removes all previous routes.
  ///
  /// Example:
  /// ```dart
  /// context.pushAndClearStack(LoginPage());
  /// ```
  Future<T?> pushAndClearStack<T extends Object?>(Widget page) {
    return Navigator.of(this).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
          (route) => false,
    );
  }

  /// Pops the current route.
  ///
  /// Example:
  /// ```dart
  /// context.pop();
  /// context.pop('result'); // With result
  /// ```
  void pop<T extends Object?>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  /// Checks if the navigator can pop.
  ///
  /// Example:
  /// ```dart
  /// if (context.canPop) {
  ///   context.pop();
  /// }
  /// ```
  bool get canPop => Navigator.of(this).canPop();

  /// Shows a snack bar.
  ///
  /// Example:
  /// ```dart
  /// context.showSnackBar('Operation completed!');
  /// ```
  void showSnackBar(
      String message, {
        Duration duration = const Duration(seconds: 4),
        SnackBarAction? action,
      }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
      ),
    );
  }

  /// Shows an error snack bar.
  ///
  /// Example:
  /// ```dart
  /// context.showErrorSnackBar('Something went wrong!');
  /// ```
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  /// Shows a success snack bar.
  ///
  /// Example:
  /// ```dart
  /// context.showSuccessSnackBar('Operation completed!');
  /// ```
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Hides the keyboard.
  ///
  /// Example:
  /// ```dart
  /// context.hideKeyboard();
  /// ```
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }

  /// Shows a dialog and returns the result.
  ///
  /// Example:
  /// ```dart
  /// final result = await context.showDialog(MyDialog());
  /// ```
  Future<T?> showDialogWidget<T>(Widget dialog) {
    return showDialog<T>(
      context: this,
      builder: (_) => dialog,
    );
  }

  /// Shows a confirmation dialog.
  ///
  /// Example:
  /// ```dart
  /// final confirmed = await context.showConfirmationDialog(
  ///   'Delete Item',
  ///   'Are you sure you want to delete this item?',
  /// );
  /// ```
  Future<bool> showConfirmationDialog(
      String title,
      String content, {
        String confirmText = 'Confirm',
        String cancelText = 'Cancel',
      }) async {
    final result = await showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Shows a bottom sheet and returns the result.
  ///
  /// Example:
  /// ```dart
  /// final result = await context.showBottomSheet(MyBottomSheet());
  /// ```
  Future<T?> showBottomSheet<T>(Widget bottomSheet) {
    return showModalBottomSheet<T>(
      context: this,
      builder: (_) => bottomSheet,
    );
  }

  /// Requests focus for a specific focus node.
  ///
  /// Example:
  /// ```dart
  /// context.requestFocus(myFocusNode);
  /// ```
  void requestFocus(FocusNode focusNode) {
    FocusScope.of(this).requestFocus(focusNode);
  }
}