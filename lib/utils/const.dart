import 'package:flutter/material.dart';
import 'package:the_pyrometer_forge/enum/my_enums.dart';

// ─── COLOR PALETTE — "Furnace Control Room" ───────────────────────────────
const Color kBackground     = Color(0xFF111010); // Furnace black
const Color kPrimaryText    = Color(0xFFF0EDE8); // Refractory white
const Color kPanelBg        = Color(0xFF1A1918); // Secondary panels
const Color kSecondaryText  = Color(0xFF6A6560); // Slag grey
const Color kAccent         = Color(0xFFE8622A); // Forge orange (900°C)
const Color kOutline        = Color(0xFF2A2826); // Dark furnace rule lines
const Color kGold           = Color(0xFFC4920A); // Crucible gold
const Color kError          = Color(0xFFDC2626); // Critical errors only

// ─── DERIVED COLORS ─────────────────────────────────────────────────────────
const Color kAccentDim      = Color(0x3DE8622A); // forge orange at ~24%
const Color kAccentSurface  = Color(0x1AE8622A); // ~10% forge orange
const Color kGoldSurface    = Color(0x1AC4920A); // ~10% crucible gold
const Color kCardBorder     = Color(0xFF2A2826); // outline same as border
const Color kOrangeGlow     = Color(0x40E8622A); // glow for selected

// ─── SPACING ────────────────────────────────────────────────────────────────
const double kSpacingXXS  = 4.0;
const double kSpacingXS   = 8.0;
const double kSpacingS    = 12.0;
const double kSpacingM    = 16.0;
const double kSpacingL    = 20.0;
const double kSpacingXL   = 24.0;
const double kSpacingXXL  = 32.0;
const double kSpacingXXXL = 48.0;

// ─── BORDER RADIUS ──────────────────────────────────────────────────────────
const double kRadiusZero     = 0.0;
const double kRadiusSubtle   = 10.0;
const double kRadiusStandard = 16.0;
const double kRadiusMedium   = 20.0;
const double kRadiusLarge    = 28.0;
const double kRadiusPill     = 999.0;

// ─── SHADOWS ────────────────────────────────────────────────────────────────
const BoxShadow kShadowSubtle = BoxShadow(
  offset: Offset(0, 2),
  blurRadius: 12,
  spreadRadius: -2,
  color: Color(0x3D000000),
);

const BoxShadow kShadowFloat = BoxShadow(
  offset: Offset(0, 8),
  blurRadius: 28,
  spreadRadius: -6,
  color: Color(0x66000000),
);

const BoxShadow kShadowOrange = BoxShadow(
  offset: Offset(0, 6),
  blurRadius: 20,
  spreadRadius: -4,
  color: Color(0x40E8622A),
);

const double kStrokeWeight       = 1.0;
const double kStrokeWeightMedium = 1.5;

// ─── GRADIENT TEMPERATURE ARC ──────────────────────────────────────────────
Color temperatureToColor(double fraction) {
  if (fraction <= 0.33) {
    return Color.lerp(
      const Color(0xFF8B1A1A), // deep red
      kAccent,                  // forge orange
      fraction / 0.33,
    )!;
  } else if (fraction <= 0.66) {
    return Color.lerp(
      kAccent,                   // forge orange
      kGold,                     // crucible gold
      (fraction - 0.33) / 0.33,
    )!;
  } else {
    return Color.lerp(
      kGold,
      const Color(0xFFFFF3CC), // white-gold peak
      (fraction - 0.66) / 0.34,
    )!;
  }
}

Color classificationColor(TemperatureBand band) {
  switch (band) {
    case TemperatureBand.low:
      return const Color(0xFF8B1A1A);
    case TemperatureBand.medium:
      return kAccent;
    case TemperatureBand.high:
      return kGold;
    case TemperatureBand.extreme:
      return const Color(0xFFFFF3CC);
  }
}

// ─── PYROMETRIC CLASSIFICATION COLORS ─────────────────────────────────────
Color getClassificationColor(PyrometricClassification cls) {
  switch (cls) {
    case PyrometricClassification.vanishingFilamentOptical:
      return kGold;
    case PyrometricClassification.totalRadiationDisplaced:
      return kAccent;
    case PyrometricClassification.biMetallicLinearExpansion:
      return const Color(0xFF6A6560);
    case PyrometricClassification.thermoElectricDissimilar:
      return const Color(0xFF4A7A6A);
    case PyrometricClassification.liquidExpansionCapillary:
      return const Color(0xFF5A7A9A);
  }
}

// ─── MAKER COLORS ─────────────────────────────────────────────────────────
Color getMakerColor(MakerSign maker) {
  switch (maker) {
    case MakerSign.leedsNorthrup:
      return kAccent;
    case MakerSign.brownInstrument:
      return const Color(0xFF8B5A2A);
    case MakerSign.cambridgeScientific:
      return kGold;
    case MakerSign.thwingAlbert:
      return const Color(0xFF4A7A6A);
    case MakerSign.honeywell:
      return const Color(0xFFDC2626);
    case MakerSign.taylorInstrument:
      return const Color(0xFF2A6A8A);
    case MakerSign.bristol:
      return const Color(0xFF6A4A7A);
    case MakerSign.foxboro:
      return const Color(0xFF2A5A4A);
    case MakerSign.weston:
      return const Color(0xFF8A6A2A);
    case MakerSign.landPyrometers:
      return const Color(0xFF5A3A2A);
    case MakerSign.siemens:
      return const Color(0xFF2A6A3A);
    case MakerSign.pyroOptical:
      return kGold;
    case MakerSign.other:
      return kSecondaryText;
  }
}

// ─── OPTICAL INTEGRITY COLORS ─────────────────────────────────────────────
Color getOpticalIntegrityColor(OpticalIntegrity integrity) {
  switch (integrity) {
    case OpticalIntegrity.pristine:
      return kAccent;
    case OpticalIntegrity.pitted:
      return kGold;
    case OpticalIntegrity.calciteFogged:
      return const Color(0xFF8A8A7A);
    case OpticalIntegrity.scratched:
      return const Color(0xFF6A5A3A);
    case OpticalIntegrity.hazy:
      return const Color(0xFF7A7A6A);
    case OpticalIntegrity.cracked:
      return kError;
    case OpticalIntegrity.missing:
      return kError;
  }
}

// ─── TEMPERATURE BAND HELPER ──────────────────────────────────────────────
TemperatureBand bandForTemperature(int maxTemp) {
  if (maxTemp < 500) return TemperatureBand.low;
  if (maxTemp < 1000) return TemperatureBand.medium;
  if (maxTemp < 1400) return TemperatureBand.high;
  return TemperatureBand.extreme;
}
