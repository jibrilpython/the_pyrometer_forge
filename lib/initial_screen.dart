import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_pyrometer_forge/enum/my_enums.dart';
import 'package:the_pyrometer_forge/providers/user_provider.dart';
import 'package:the_pyrometer_forge/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class InitialScreen extends ConsumerWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProv = ref.watch(userProvider);
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // ── Furnace cross-section backdrop ───────────────────────────────
          Positioned.fill(
            child: CustomPaint(painter: _FurnaceBackdropPainter()),
          ),
          // Gradient overlay for readability
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(180),
                      Colors.transparent,
                      Colors.black.withAlpha(200),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(32.w, 24.h, 32.w, 40.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Technical Header ──────────────────────────────────────
                  Row(
                    children: [
                      Icon(
                        Icons.thermostat_outlined,
                        color: kAccent,
                        size: 18.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'THERMAL ARCHIVE',
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 11.sp,
                          color: kAccent,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: kAccent.withAlpha(20),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'TPF',
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 8.sp,
                            color: kAccent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40.h),
                  // ── Hero typography ─────────────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "THE\nPYROMETER\nFORGE.",
                        style: GoogleFonts.bebasNeue(
                          color: kPrimaryText,
                          fontSize: 56.sp,
                          fontWeight: FontWeight.w400,
                          height: 0.92,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'MASTERS OF THE FLAME',
                        style: GoogleFonts.ibmPlexMono(
                          color: kGold,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'A digital archive of vintage high-temperature measurement instruments — from mechanical expansion pyrometers with long copper rods to vanishing-filament optical pyrometers.',
                        style: GoogleFonts.ibmPlexSans(
                          color: kSecondaryText,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w300,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // Temperature band pill row
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 6.h,
                        children: TemperatureBand.values
                            .map(
                              (b) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: kOutline,
                                    width: 1,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(kRadiusPill),
                                ),
                                child: Text(
                                  b.label,
                                  style: GoogleFonts.ibmPlexMono(
                                    color: kSecondaryText,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                  // ── CTA button ──────────────────────────────────────────
                  GestureDetector(
                    onTap: () {
                      userProv.setFirstTimeUser(false);
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: Container(
                      width: double.infinity,
                      height: 58.h,
                      decoration: BoxDecoration(
                        color: kAccent,
                        borderRadius: BorderRadius.circular(kRadiusPill),
                        boxShadow: const [kShadowOrange],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Enter the Forge',
                            style: GoogleFonts.ibmPlexSans(
                              color: kPrimaryText,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: kPrimaryText,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws a furnace cross-section with heat gradient rings in the background.
class _FurnaceBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.85;
    final cy = size.height * 0.28;

    // Heat rings radiating outward
    for (int i = 0; i < 10; i++) {
      final r = 30.0 + i * 42.0;
      final fraction = i / 10.0;
      final paint = Paint()
        ..color = temperatureToColor(fraction).withAlpha((20 + i * 8).clamp(0, 60))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 + i * 0.3;
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    // Core glow
    final corePaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(cx, cy),
        80,
        [kAccent.withAlpha(60), Colors.transparent],
        [0.0, 1.0],
      );
    canvas.drawCircle(Offset(cx, cy), 80, corePaint);

    // Temperature rays
    final rayPaint = Paint()
      ..color = kAccent.withAlpha(15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (int i = 0; i < 16; i++) {
      final angle = i * math.pi / 8;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + 450 * math.cos(angle), cy + 450 * math.sin(angle)),
        rayPaint,
      );
    }

    // Center mark
    final centerPaint = Paint()
      ..color = kAccent.withAlpha(120)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
