import 'package:flutter/material.dart';
import '../resources/app_color.dart';

class AppBoxShadow {
  AppBoxShadow._();

  static List<BoxShadow> get boxShadow => [
        const BoxShadow(
          color: AppColor.shadow,
          offset: Offset(0.0, 3.0),
          blurRadius: 6.0,
        ),
      ];
}
