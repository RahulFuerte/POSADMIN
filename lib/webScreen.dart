import 'package:flutter/material.dart';

import 'package:pos_admin/constants/colors.dart';

class WebScreen {
  late BuildContext context;
  WebScreen(this.context);

  MediaQueryData get mediaQuery => MediaQuery.of(context);

  Size get size => mediaQuery.size;

  double get infinity => double.infinity;
  double get width => size.width;
  double get height => size.height;
  double get customWebWidth => width / webWidth;
  double get topWebPadding => mediaQuery.viewPadding.top;
  double get bottomWebPadding => mediaQuery.viewPadding.bottom;
}

