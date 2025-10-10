import 'package:flutter/material.dart';

Color _rgba(int r, int g, int b, double a) =>
    Color.fromARGB((a * 255).round(), r, g, b);

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({


    required this.secondaryButton,
    required this.green,
    required this.permanentWhite,
    required this.gray,
    required this.text,
    required this.background,
    required this.lightGray,
    required this.redToRosita,
    required this.placeholder,
    required this.drawer,
    required this.card1,
    required this.card2,
    required this.card3,
    required this.card4,
    required this.stroke,
    required this.redToWhite,
    required this.blue,
    required this.pending,
    required this.strokeToNoStroke,
  });

  final Color secondaryButton;
  final Color green;
  final Color permanentWhite;
  final Color gray;
  final Color text;
  final Color background;
  final Color lightGray;
  final Color redToRosita;
  final Color placeholder;
  final Color drawer;
  final Color card1;
  final Color card2;
  final Color card3;
  final Color card4;
  final Color stroke;
  final Color redToWhite;
  final Color blue;
  final Color pending;
  final Color strokeToNoStroke;

  @override
  AppTokens copyWith({
    Color? secondaryButton,
    Color? green,
    Color? permanentWhite,
    Color? gray,
    Color? text,
    Color? background,
    Color? lightGray,
    Color? redToRosita,
    Color? placeholder,
    Color? drawer,
    Color? card1,
    Color? card2,
    Color? card3,
    Color? card4,
    Color? stroke,
    Color? redToWhite,
    Color? blue,
    Color? pending,
    Color? strokeToNoStroke,
  }) {
    return AppTokens(
      secondaryButton: secondaryButton ?? this.secondaryButton,
      green: green ?? this.green,
      permanentWhite: permanentWhite ?? this.permanentWhite,
      gray: gray ?? this.gray,
      text: text ?? this.text,
      background: background ?? this.background,
      lightGray: lightGray ?? this.lightGray,
      redToRosita: redToRosita ?? this.redToRosita,
      placeholder: placeholder ?? this.placeholder,
      drawer: drawer ?? this.drawer,
      card1: card1 ?? this.card1,
      card2: card2 ?? this.card2,
      card3: card3 ?? this.card3,
      card4: card4 ?? this.card4,
      stroke: stroke ?? this.stroke,
      redToWhite: redToWhite ?? this.redToWhite,
      blue: blue ?? this.blue,
      pending: pending ?? this.pending,
      strokeToNoStroke: strokeToNoStroke ?? this.strokeToNoStroke,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    Color lerpC(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppTokens(
      secondaryButton: lerpC(secondaryButton, other.secondaryButton),
      green: lerpC(green, other.green),
      permanentWhite: lerpC(permanentWhite, other.permanentWhite),
      gray: lerpC(gray, other.gray),
      text: lerpC(text, other.text),
      background: lerpC(background, other.background),
      lightGray: lerpC(lightGray, other.lightGray),
      redToRosita: lerpC(redToRosita, other.redToRosita),
      placeholder: lerpC(placeholder, other.placeholder),
      drawer: lerpC(drawer, other.drawer),
      card1: lerpC(card1, other.card1),
      card2: lerpC(card2, other.card2),
      card3: lerpC(card3, other.card3),
      card4: lerpC(card4, other.card4),
      stroke: lerpC(stroke, other.stroke),
      redToWhite: lerpC(redToWhite, other.redToWhite),
      blue: lerpC(blue, other.blue),
      pending: lerpC(pending, other.pending),
      strokeToNoStroke: lerpC(strokeToNoStroke, other.strokeToNoStroke),
    );
  }
}

extension AppTokensX on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}

class AppTheme {


  static ColorScheme get _lightScheme => ColorScheme(
    brightness: Brightness.light,
    primary: const Color(0xFF8C0C10),

    onPrimary: Colors.white,
    secondary: const Color(0xFF0059FF),

    onSecondary: Colors.white,
    tertiary: const Color(0xFF4E9644),

    onTertiary: Colors.white,
    error: const Color(0xFFB3261E),
    onError: Colors.white,
    background: const Color(0xFFFFFFFF),

    onBackground: const Color(0xFF0C0C0C),

    surface: const Color(0xFFFFFFFF),

    onSurface: const Color(0xFF212121),
    outline: const Color(0xFFDBDBDB),

    surfaceVariant: const Color(0xFFEBEBEB),

    onSurfaceVariant: const Color(0xFF212121),
  );

  static final _lightTokens = AppTokens(
    secondaryButton: const Color(0xFF333333),

    green: const Color(0xFF4E9644),

    permanentWhite: const Color(0xFFFFFFFF),
    gray: const Color(0xFF212121),
    text: const Color(0xFF0C0C0C),
    background: const Color(0xFFFFFFFF),
    lightGray: const Color(0xFFEBEBEB),
    redToRosita: const Color(0xFF8C0C10),
    placeholder: _rgba(33, 33, 33, 0.7),
    drawer: const Color(0xFFFFFFFF),
    card1: const Color(0xFFFFFFFF),
    card2: const Color(0xFFFFFFFF),
    card3: const Color(0xFFFFFFFF),
    card4: const Color(0x1AFF7878),

    stroke: const Color(0xFFDBDBDB),
    redToWhite: const Color(0xFF8C0C10),
    blue: const Color(0xFF0059FF),
    pending: const Color(0xFFFF8400),
    strokeToNoStroke: const Color(0xFFD9D9D9),
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: _lightScheme,
        scaffoldBackgroundColor: _lightScheme.background,
        appBarTheme: AppBarTheme(
          backgroundColor: _lightScheme.surface,
          foregroundColor: _lightScheme.onSurface,
          elevation: 0,
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: _lightTokens.drawer,
        ),
        cardTheme: CardThemeData(
          color: _lightTokens.card1,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: _lightTokens.stroke),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: _lightTokens.placeholder),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _lightTokens.stroke),
          ),
        ),
        extensions: [_lightTokens],
      );



  static final _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: const Color(0xFFDD2D2D),

    onPrimary: Colors.white,
    secondary: const Color(0xFF74A5FF),

    onSecondary: Colors.black,
    tertiary: _rgba(84, 202, 68, 0.66),

    onTertiary: Colors.black,
    error: const Color(0xFFFFB4A9),
    onError: const Color(0xFF680003),
    background: const Color(0xFF0C0C0C),

    onBackground: Colors.white,
    surface: const Color(0xFF121212),
    onSurface: Colors.white,
    outline: _rgba(255, 255, 255, 0.5),

    surfaceVariant: _rgba(50, 50, 50, 0.7),

    onSurfaceVariant: Colors.white,
  );

  static final _darkTokens = AppTokens(
    secondaryButton: _rgba(140, 140, 140, 0.5),

    green: _rgba(84, 202, 68, 0.66),

    permanentWhite: const Color(0xFFFFFFFF),
    gray: const Color(0xFFDEDEDE),
    text: const Color(0xFFFFFFFF),
    background: const Color(0xFF0C0C0C),
    lightGray: _rgba(50, 50, 50, 0.7),
    redToRosita: const Color(0xFFFF6262),
    placeholder: _rgba(255, 255, 255, 0.7),
    drawer: _rgba(140, 140, 140, 0.1),

    card1: _rgba(50, 50, 50, 0.5),
    card2: _rgba(50, 50, 50, 0.5),
    card3: _rgba(50, 50, 50, 0.9),
    card4: _rgba(255, 120, 120, 0.08),
    stroke: _rgba(255, 255, 255, 0.5),
    redToWhite: const Color(0xFFFFFFFF),
    blue: const Color(0xFF74A5FF),
    pending: const Color(0xFFFF8400),
    strokeToNoStroke: _rgba(50, 50, 50, 0.5),
  );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: _darkScheme,
        scaffoldBackgroundColor: _darkScheme.background,
        appBarTheme: AppBarTheme(
          backgroundColor: _darkScheme.surface,
          foregroundColor: _darkScheme.onSurface,
          elevation: 0,
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: _darkTokens.drawer,
        ),
    cardTheme: CardThemeData(
      color: _darkTokens.card1,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: _darkTokens.stroke),
      ),



    ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: _darkTokens.placeholder),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _darkTokens.stroke),
          ),
        ),
        extensions: [_darkTokens],
      );
}
