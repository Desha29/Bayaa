import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  
  static double fontSize(BuildContext context,
      {double mobile = 14, double tablet = 16, double desktop = 18}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  
  static EdgeInsets padding(BuildContext context,
      {EdgeInsets? mobile, EdgeInsets? tablet, EdgeInsets? desktop}) {
    if (isDesktop(context)) {
      return desktop ?? const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    } else if (isTablet(context)) {
      return tablet ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    } else {
      return mobile ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }


  static int gridCount(BuildContext context,
      {int mobile = 2, int tablet = 3, int desktop = 4}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
}
