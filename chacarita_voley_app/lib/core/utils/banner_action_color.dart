import 'package:flutter/material.dart';

Color bannerActionColor({
  required bool isSuccess,
  required Color successColor,
  required Color errorColor,
}) {
  return isSuccess ? successColor : errorColor;
}
