import 'package:flutter/material.dart';

/// Design tokens from design/DESIGN.md (palette P44, Outfit + Fraunces).
abstract final class C {
  static const bg = Color(0xFFFAF4FC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF3E8F6);
  static const accent = Color(0xFFC64BE0);
  static const accentFill = Color(0xFFA337BA);
  static const accentPressed = Color(0xFF9B3BAF);
  static const accentTint = Color(0xFFF6E4FA);
  static const support = Color(0xFFA8D672);
  static const supportStrong = Color(0xFF6EA22E);
  static const ink = Color(0xFF1C0C1F);
  static const text2 = Color(0xFF574A5A);
  static const text3 = Color(0xFF76687A);
  static const border = Color(0xFFEADCEE);
  static const borderStrong = Color(0xFFB085B4);
  static const successFg = Color(0xFF0E7C3A);
  static const successTint = Color(0xFFE3F4E9);
  static const warningFg = Color(0xFFA75906);
  static const warningTint = Color(0xFFFAEFE1);
  static const dangerFg = Color(0xFFCE2020);
  static const paper = Color(0xFFFFFDFB);
  static const sepia = Color(0xFFFBF0D9);
}

abstract final class T {
  static const display = TextStyle(fontFamily: 'Fraunces', fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.64, height: 1.2, color: C.ink);
  static const headline = TextStyle(fontFamily: 'Fraunces', fontSize: 24, fontWeight: FontWeight.w600, height: 1.25, color: C.ink);
  static const title = TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w600, height: 1.35, color: C.ink);
  static const body = TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: C.ink);
  static const label = TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w500, height: 1.4, color: C.ink);
  static const caption = TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w500, height: 1.4, color: C.text2);
}

const shadowCard = [BoxShadow(color: Color(0x0A1C0C1F), blurRadius: 2, offset: Offset(0, 1)), BoxShadow(color: Color(0x0F1C0C1F), blurRadius: 24, offset: Offset(0, 8))];

ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'Outfit',
  scaffoldBackgroundColor: C.bg,
  colorScheme: ColorScheme.fromSeed(seedColor: C.accent, primary: C.accentFill, surface: C.surface).copyWith(onSurface: C.ink),
  splashFactory: InkSparkle.splashFactory,
  sliderTheme: const SliderThemeData(activeTrackColor: C.accent, inactiveTrackColor: C.surfaceAlt, thumbColor: C.accentFill, trackHeight: 4),
  pageTransitionsTheme: const PageTransitionsTheme(builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder(), TargetPlatform.iOS: CupertinoPageTransitionsBuilder()}),
);
