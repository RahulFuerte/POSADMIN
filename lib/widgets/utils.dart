import 'package:flutter/material.dart';
import 'package:pos_admin/constants/colors.dart';

/// Shows a styled snackbar with the app's primary color.
void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      content: Text(
        content,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: primaryColor,
      showCloseIcon: true,
      closeIconColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(16),
    ),
  );
}

/// Shows a success snackbar with green background.
void showSuccessSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      content: Text(
        content,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: successColor,
      showCloseIcon: true,
      closeIconColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(16),
    ),
  );
}

/// Shows an error snackbar with red background.
void showErrorSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(
        content,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: errorColor,
      showCloseIcon: true,
      closeIconColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(16),
    ),
  );
}

/// Shows a warning snackbar with orange background.
void showWarningSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      content: Text(
        content,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: warningColor,
      showCloseIcon: true,
      closeIconColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(16),
    ),
  );
}
