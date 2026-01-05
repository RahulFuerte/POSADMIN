import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_admin/constants/colors.dart';
import 'package:pos_admin/widgets/connection_status_indicator.dart';

/// A consistent AppBar following the design system.
/// 
/// Implements Requirements 2.1, 2.3, 2.4:
/// - White background and zero elevation
/// - Offline/online status indicator when applicable
/// - Consistent icon styling (primaryColor for active, black for inactive)
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showConnectionStatus;
  final bool isOnline;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;

  const CustomAppBar({
    Key? key,
    this.title,
    this.titleWidget,
    this.actions,
    this.showBackButton = false,
    this.showConnectionStatus = false,
    this.isOnline = true,
    this.onBackPressed,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? white,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: primaryColor),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      automaticallyImplyLeading: showBackButton,
      title: titleWidget ??
          (title != null
              ? Row(
                  children: [
                    Text(
                      title!,
                      style: const TextStyle(
                        color: black,
                        fontFamily: 'tabfont',
                        fontSize: 19,
                      ),
                    ),
                    if (showConnectionStatus) ...[
                      const SizedBox(width: 12),
                      ConnectionStatusIndicator(isOnline: isOnline),
                    ],
                  ],
                )
              : null),
      actions: actions,
      iconTheme: const IconThemeData(color: black),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// A zero-height AppBar for splash screens.
/// 
/// Implements Requirement 2.2:
/// - Zero AppBar (toolbarHeight: 0) with white status bar
class ZeroAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ZeroAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 0,
      elevation: 0,
      automaticallyImplyLeading: false,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Size get preferredSize => Size.zero;
}
