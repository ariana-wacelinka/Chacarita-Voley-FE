import 'package:flutter/material.dart';

class SnackbarService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showError(String message) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
