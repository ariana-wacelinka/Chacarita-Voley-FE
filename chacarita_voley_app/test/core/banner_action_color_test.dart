import 'package:chacarita_voley_app/core/utils/banner_action_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bannerActionColor returns success color when isSuccess is true', () {
    const successColor = Colors.white;
    const errorColor = Colors.red;

    expect(
      bannerActionColor(
        isSuccess: true,
        successColor: successColor,
        errorColor: errorColor,
      ),
      successColor,
    );
  });

  test('bannerActionColor returns error color when isSuccess is false', () {
    const successColor = Colors.white;
    const errorColor = Colors.red;

    expect(
      bannerActionColor(
        isSuccess: false,
        successColor: successColor,
        errorColor: errorColor,
      ),
      errorColor,
    );
  });
}
