import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

void MotionSnackBarSuccess(BuildContext context, String message) {
  MotionToast.success(
  title: Text(
      message,
      style: TextStyle(fontWeight: FontWeight.w700),
    ),
    toastDuration: Duration(seconds: 2),
    toastAlignment: Alignment.bottomRight,
    animationType: AnimationType.slideInFromLeft,
    description: SizedBox(),
    animationDuration: Duration(milliseconds: 400),
    animationCurve: Curves.easeInOut,
    opacity: 0.95,
  ).show(context);
}

void MotionSnackBarError(BuildContext context, String message) {
  MotionToast.error(
    title: Text(
      message,
      style: TextStyle(fontWeight: FontWeight.w700),
    ),
    toastDuration: Duration(seconds: 2),
    toastAlignment: Alignment.bottomRight,
    animationType: AnimationType.slideInFromLeft,
    description: SizedBox(),
    animationDuration: Duration(milliseconds: 400),
    animationCurve: Curves.easeInOut,
    opacity: 0.95,
  ).show(context);
}

void MotionSnackBarInfo(BuildContext context, String message) {
  MotionToast.info(
     title: Text(
      message,
      style: TextStyle(fontWeight: FontWeight.w700),
    ),
    toastDuration: Duration(seconds: 2),
    toastAlignment: Alignment.bottomRight,
    animationType: AnimationType.slideInFromLeft,
    description: SizedBox(),
    animationDuration: Duration(milliseconds: 400),
    animationCurve: Curves.easeInOut,
    opacity: 0.95,
  ).show(context);
}

void MotionSnackBarWarning(BuildContext context, String message) {
  MotionToast.warning(
    title: Text(
      message,
      style: TextStyle(fontWeight: FontWeight.w700),
    ),
    toastDuration: Duration(seconds: 2),
    toastAlignment: Alignment.bottomRight,
    animationType: AnimationType.slideInFromLeft,
    description: SizedBox(),
    animationDuration: Duration(milliseconds: 400),
    animationCurve: Curves.easeInOut,
    opacity: 0.95,
  ).show(context);
}
