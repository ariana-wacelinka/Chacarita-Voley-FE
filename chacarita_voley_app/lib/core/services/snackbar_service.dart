import 'package:flutter/material.dart';

class SnackbarService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static String? _lastErrorMessage;
  static DateTime? _lastErrorAt;
  static const Duration _dedupeWindow = Duration(milliseconds: 1200);

  static void showError(String message) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    final normalized = message.trim();
    final now = DateTime.now();
    final isDuplicate =
        normalized.isNotEmpty &&
        _lastErrorMessage == normalized &&
        _lastErrorAt != null &&
        now.difference(_lastErrorAt!) <= _dedupeWindow;
    if (isDuplicate) return;

    _lastErrorMessage = normalized;
    _lastErrorAt = now;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(normalized), behavior: SnackBarBehavior.floating),
    );
  }
}
