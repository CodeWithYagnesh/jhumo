import 'package:flutter/material.dart';
import 'package:jhumo/moduls/methods.dart';

class Themer {
  static Color main = Color(0xffCA2828);
  static Color light = Color(0xffFFFFFF);
  static Color light1 = Color(0xff9F9F9F);
  static Color dark = Color(0xff100F10);
  static Color dark1 = Color(0xff272727);

  static Gradient gradientLight =
      LinearGradient(colors: [main, main.withOpacity(0.5)]);
  static Gradient gradientDark =
      LinearGradient(colors: [main, main.withOpacity(0.5)]);
}

void fun() {
  "hello".toPrint;
}

final ThemeData lightTheme = ThemeData(
  popupMenuTheme: PopupMenuThemeData(
      // color: Colors.transparent,
      elevation: 10,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: Themer.main,
            width: 1,
            strokeAlign: BorderSide.strokeAlignOutside),
        borderRadius: BorderRadius.circular(16),
      )),
  fontFamily: "inter",
  colorScheme: ColorScheme.fromSeed(
      seedColor: Themer.main, brightness: Brightness.light),
  useMaterial3: true,
);

class ScrollBehaviorModified extends ScrollBehavior {
  const ScrollBehaviorModified();
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.android:
        return const BouncingScrollPhysics();
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const ClampingScrollPhysics();
    }
  }
}

final ThemeData darkTheme = ThemeData(
  popupMenuTheme: PopupMenuThemeData(
      // color: Colors.transparent,
      elevation: 10,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: Themer.main,
            width: 1,
            strokeAlign: BorderSide.strokeAlignOutside),
        borderRadius: BorderRadius.circular(16),
      )),
  fontFamily: "inter",
  colorScheme:
      ColorScheme.fromSeed(seedColor: Themer.main, brightness: Brightness.dark),
  useMaterial3: true,
);
