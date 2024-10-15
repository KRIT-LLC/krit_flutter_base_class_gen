import 'dart:developer';
import 'package:flutter/material.dart';

extension MQuery on BuildContext {
  Size get currentSize => MediaQuery.of(this).size;

  double? get insetsBottom => MediaQuery.of(this).viewInsets.bottom;

  double get topInsets => MediaQuery.of(this).viewInsets.top;

  bool get hasBottomInsets => (insetsBottom ?? 0) != 0;
}

extension ATheme on BuildContext {
  ThemeData get themeData => Theme.of(this);
  bool get isDark => themeData.brightness == Brightness.dark;
}

extension NFocus on BuildContext {
  void moveFocusToNode(FocusNode node) {
    FocusScope.of(this).requestFocus(node);
  }

  /// uses for unfocus with [Navigator] when used [Navigator.push]
  void unFocus({TextEditingController? controller}) {
    FocusScope.of(this).unfocus();
    controller?.clear();
  }
}

extension Nav on BuildContext {
  /// replacing [Navigator.pushNamed] with [BuildContext.navigateTo]
  Future<T?> navigateTo<T extends Object?>(String routeName, {dynamic args}) {
    log('navigate to $routeName with args $args');

    return Navigator.of(this).pushNamed(routeName, arguments: args);
  }

  Future<T?> navigateReplaceTo<T extends Object?>(String routeName,
      {dynamic args}) {
    log('navigate to $routeName ');
    return Navigator.of(this).pushReplacementNamed(routeName, arguments: args);
  }

  navigateUp<T extends Object?>({Object? arg, String? tag}) {
    print('navigated up with arg $arg from $tag');
    return Navigator.of(this).pop(arg);
  }

  void navigateUpToRoot<T extends Object?>() {
    return Navigator.of(this).popUntil((route) => route.isFirst);
  }

  Future<T?> navigateClearStackTo<T extends Object?>(String routeName,
      {Object? arg}) {
    return Navigator.of(this)
        .pushNamedAndRemoveUntil(routeName, (r) => false, arguments: arg);
  }

  void navigateUpTo<T extends Object?>({int steps = 1}) {
    var count = 0;
    return Navigator.of(this).popUntil((route) => count++ == steps);
  }

  Future<void> delayedNavigation(
      Function<T extends Object?>(String route, {dynamic args}) navigate,
      String route,
      {dynamic args}) async {
    Future.delayed(
        const Duration(milliseconds: 50), () => navigate(route, args: args));
  }
}

extension IntValue on int {
  bool get boolValue => this == 0 ? false : true;
}
