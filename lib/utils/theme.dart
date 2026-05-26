import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_pyrometer_forge/utils/const.dart';

final appTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kAccent,
  scaffoldBackgroundColor: kBackground,
  colorScheme: const ColorScheme.dark(
    primary: kAccent,
    secondary: kGold,
    surface: kPanelBg,
    onSurface: kPrimaryText,
    onPrimary: kPrimaryText,
    error: kError,
    outline: kOutline,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
    titleTextStyle: GoogleFonts.bebasNeue(
      fontSize: 22.sp,
      fontWeight: FontWeight.w400,
      color: kPrimaryText,
      letterSpacing: 0.5,
    ),
    iconTheme: const IconThemeData(color: kPrimaryText),
  ),
  textTheme: TextTheme(
    // ── Display — Bebas Neue (industrial signage) ──────────────────────────
    displayLarge: GoogleFonts.bebasNeue(
      fontSize: 52.sp,
      fontWeight: FontWeight.w400,
      color: kPrimaryText,
      height: 0.95,
      letterSpacing: 1.0,
    ),
    displayMedium: GoogleFonts.bebasNeue(
      fontSize: 40.sp,
      fontWeight: FontWeight.w400,
      color: kPrimaryText,
      height: 1.0,
      letterSpacing: 0.5,
    ),
    displaySmall: GoogleFonts.bebasNeue(
      fontSize: 32.sp,
      fontWeight: FontWeight.w400,
      color: kPrimaryText,
      height: 1.05,
    ),
    headlineLarge: GoogleFonts.bebasNeue(
      fontSize: 28.sp,
      fontWeight: FontWeight.w400,
      color: kPrimaryText,
      letterSpacing: 0.5,
    ),
    headlineMedium: GoogleFonts.bebasNeue(
      fontSize: 24.sp,
      fontWeight: FontWeight.w400,
      color: kPrimaryText,
      letterSpacing: 0.3,
    ),
    headlineSmall: GoogleFonts.bebasNeue(
      fontSize: 20.sp,
      fontWeight: FontWeight.w400,
      color: kPrimaryText,
    ),
    // ── Title — IBM Plex Sans ───────────────────────────────────────────────
    titleLarge: GoogleFonts.ibmPlexSans(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    titleMedium: GoogleFonts.ibmPlexSans(
      fontSize: 15.sp,
      fontWeight: FontWeight.w500,
      color: kPrimaryText,
    ),
    titleSmall: GoogleFonts.ibmPlexSans(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: kSecondaryText,
    ),
    // ── Body — IBM Plex Sans (light 300 on dark) ────────────────────────────
    bodyLarge: GoogleFonts.ibmPlexSans(
      fontSize: 15.sp,
      fontWeight: FontWeight.w300,
      color: kPrimaryText,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.ibmPlexSans(
      fontSize: 14.sp,
      fontWeight: FontWeight.w300,
      color: kPrimaryText,
      height: 1.6,
    ),
    bodySmall: GoogleFonts.ibmPlexSans(
      fontSize: 12.sp,
      fontWeight: FontWeight.w300,
      color: kSecondaryText,
    ),
    // ── Labels — IBM Plex Mono for identifiers ──────────────────────────────
    labelLarge: GoogleFonts.ibmPlexMono(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    labelMedium: GoogleFonts.ibmPlexMono(
      fontSize: 11.sp,
      fontWeight: FontWeight.w500,
      color: kSecondaryText,
    ),
    labelSmall: GoogleFonts.ibmPlexMono(
      fontSize: 10.sp,
      fontWeight: FontWeight.w400,
      color: kSecondaryText,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kBackground,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      borderSide: const BorderSide(color: kOutline, width: kStrokeWeight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      borderSide: const BorderSide(color: kOutline, width: kStrokeWeight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      borderSide:
          const BorderSide(color: kAccent, width: kStrokeWeightMedium),
    ),
    hintStyle: GoogleFonts.ibmPlexSans(
      color: kSecondaryText,
      fontSize: 14.sp,
      fontWeight: FontWeight.w300,
    ),
    labelStyle: GoogleFonts.ibmPlexSans(
      color: kSecondaryText,
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
    ),
    floatingLabelStyle: GoogleFonts.ibmPlexSans(
      color: kAccent,
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kAccent,
      foregroundColor: kPrimaryText,
      elevation: 0,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(kRadiusPill)),
      ),
      textStyle: GoogleFonts.ibmPlexSans(
        fontWeight: FontWeight.w600,
        fontSize: 15.sp,
        letterSpacing: 0.3,
      ),
    ),
  ),
  cardTheme: const CardThemeData(
    color: kPanelBg,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(kRadiusSubtle)),
      side: BorderSide(color: kOutline, width: kStrokeWeight),
    ),
    margin: EdgeInsets.zero,
  ),
  dividerTheme: const DividerThemeData(
    color: kOutline,
    thickness: 1.0,
    space: 0,
  ),
  useMaterial3: true,
);
