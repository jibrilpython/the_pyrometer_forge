import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:the_pyrometer_forge/enum/my_enums.dart';
import 'package:the_pyrometer_forge/models/project_model.dart';
import 'package:the_pyrometer_forge/providers/image_provider.dart';
import 'package:the_pyrometer_forge/providers/project_provider.dart';
import 'package:the_pyrometer_forge/utils/const.dart';

class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});
  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  double _temperature = 0.0;
  bool _stoking = false;

  ThermalInstrumentModel? _focusItem;
  int? _focusIndex;
  double _rheostatValue = 0.0;
  bool _colorMatched = false;
  double _focusPanelSlide = 0.0;
  final Map<String, Offset> _customPositions = {};

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    setState(() {
      if (_stoking) {
        _temperature += (1.0 - _temperature) * 0.02;
      } else {
        _temperature += (0.0 - _temperature) * 0.008;
      }
      _temperature = _temperature.clamp(0.0, 1.0);
    });
  }

  Color _blackbodyColor(double t) {
    if (t < 0.05) return const Color(0xFF0D0A08);
    if (t < 0.2) {
      final f = (t - 0.05) / 0.15;
      return Color.lerp(const Color(0xFF0D0A08), const Color(0xFF5A1008), f)!;
    }
    if (t < 0.4) {
      final f = (t - 0.2) / 0.2;
      return Color.lerp(const Color(0xFF5A1008), const Color(0xFF8B1A0A), f)!;
    }
    if (t < 0.6) {
      final f = (t - 0.4) / 0.2;
      return Color.lerp(const Color(0xFF8B1A0A), const Color(0xFFD4520A), f)!;
    }
    if (t < 0.8) {
      final f = (t - 0.6) / 0.2;
      return Color.lerp(const Color(0xFFD4520A), const Color(0xFFE8A030), f)!;
    }
    final f = (t - 0.8) / 0.2;
    return Color.lerp(const Color(0xFFE8A030), const Color(0xFFF2E8D0), f)!;
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).padding.bottom + 84.h;

    if (entries.isEmpty) {
      return _buildEmpty(size);
    }

    if (_focusItem != null && _focusIndex != null) {
      return _buildFocusMode(size, bottomInset);
    }

    final nodePositions = <Map<String, dynamic>>[];
    final placed = <Offset>[];
    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      final band = bandForTemperature(e.maxTemperature);
      final bandIdx = TemperatureBand.values.indexOf(band);
      final rowY = size.height * 0.25 + bandIdx * (size.height * 0.16);
      final xOff = (i * 37 + bandIdx * 53) % 100;
      double calcX = size.width * 0.12 + (xOff / 100.0) * size.width * 0.76;
      double calcY = (rowY + (math.sin(i * 2.7) * 20)).clamp(size.height * 0.2, size.height * 0.78);
      final custom = _customPositions[e.id];
      if (custom != null) {
        calcX = custom.dx;
        calcY = custom.dy;
      } else {
        // Collision avoidance
        int attempts = 0;
        while (attempts < 20) {
          bool collision = false;
          for (final p in placed) {
            if ((p - Offset(calcX, calcY)).distance < 70) {
              collision = true;
              break;
            }
          }
          if (!collision) break;
          calcX += 40 + (attempts % 5) * 10;
          calcY += (attempts % 3 - 1) * 20;
          if (calcX > size.width * 0.85) calcX = size.width * 0.12;
          if (calcY < size.height * 0.2 || calcY > size.height * 0.78) calcY = rowY;
          attempts++;
        }
      }
      placed.add(Offset(calcX, calcY));
      nodePositions.add({
        'item': e,
        'x': calcX,
        'y': calcY,
        'band': band,
      });
    }

    final bgColor = _blackbodyColor(_temperature);
    final glowAlpha = (_temperature * 80).toInt().clamp(0, 80);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A08),
      body: Listener(
        onPointerDown: (_) => setState(() => _stoking = true),
        onPointerUp: (_) => setState(() => _stoking = false),
        onPointerCancel: (_) => setState(() => _stoking = false),
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                color: bgColor,
                child: CustomPaint(
                  size: size,
                  painter: _HeatRisePainter(
                    temperature: _temperature,
                    glowAlpha: glowAlpha,
                  ),
                ),
              ),
            ),
            // Ground line
            Positioned(
              left: 0,
              right: 0,
              bottom: size.height * 0.12,
              child: Container(
                height: 2.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      bgColor.withAlpha(0),
                      bgColor.withAlpha(200),
                      bgColor.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
            // Header
            Positioned(
              top: MediaQuery.of(context).padding.top + 8.h,
              left: 20.w,
              child: IgnorePointer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BLAST FURNACE',
                      style: GoogleFonts.ibmPlexMono(
                        color: kPrimaryText.withAlpha((_temperature * 150).toInt().clamp(60, 255)),
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'TAPHole VIEW',
                      style: GoogleFonts.bebasNeue(
                        color: kPrimaryText.withAlpha((_temperature * 120).toInt().clamp(40, 200)),
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w400,
                        height: 0.9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Temp indicator
            Positioned(
              top: MediaQuery.of(context).padding.top + 12.h,
              right: 20.w,
              child: IgnorePointer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(_temperature * 2000).round()}°C',
                      style: GoogleFonts.ibmPlexMono(
                        color: _blackbodyColor(_temperature),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _stoking ? 'STOKING' : 'COOLING',
                      style: GoogleFonts.ibmPlexMono(
                        color: kSecondaryText.withAlpha(150),
                        fontSize: 7.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Heat pulse glow at bottom
            Positioned(
              left: size.width * 0.3,
              right: size.width * 0.3,
              bottom: size.height * 0.08,
              child: IgnorePointer(
                child: Container(
                  height: size.height * 0.15,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.bottomCenter,
                      radius: 0.8,
                      colors: [
                        _blackbodyColor(_temperature).withAlpha(120),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // "Tap to stoke" hint
            if (_temperature < 0.05)
              Positioned(
                left: 0,
                right: 0,
                bottom: size.height * 0.2,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _temperature < 0.05 ? 0.6 : 0,
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      children: [
                        Icon(Icons.touch_app, color: kSecondaryText, size: 24.sp),
                        SizedBox(height: 8.h),
                        Text(
                          'PRESS & HOLD TO STOKE',
                          style: GoogleFonts.ibmPlexMono(
                            color: kSecondaryText,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Nodes (draggable)
            ...nodePositions.map((pos) {
              final item = pos['item'] as ThermalInstrumentModel;
              final band = pos['band'] as TemperatureBand;
              return _buildDraggableNode(item, band, entries);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableNode(ThermalInstrumentModel item, TemperatureBand band,
      List<ThermalInstrumentModel> entries) {
    final color = classificationColor(band);
    final isOptical = item.pyrometricClassification == PyrometricClassification.vanishingFilamentOptical;
    final isCone = item.pyrometricClassification == PyrometricClassification.biMetallicLinearExpansion;
    final isThermocouple = item.pyrometricClassification == PyrometricClassification.thermoElectricDissimilar;

    final ratedMax = item.maxTemperature;
    final maxGlobal = 2000;
    final tempRatio = (ratedMax / maxGlobal).clamp(0.0, 1.0);
    final coneDeformed = _temperature > tempRatio;
    final bendAngle = coneDeformed
        ? math.min((_temperature - tempRatio) * 6, 1.5)
        : 0.0;

    final nodeSize = 48.w;
    final glowRadius = 10 + _temperature * 20;
    final localGlowAlpha = (_temperature * 80).toInt().clamp(0, 80);

    Widget nodeWidget;

    if (isCone) {
      nodeWidget = Transform.rotate(
        angle: bendAngle,
        alignment: Alignment.bottomCenter,
        child: Container(
          width: nodeSize * 0.5,
          height: nodeSize * 1.1,
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xFF8A7A5A),
              const Color(0xFFD4A060),
              _temperature,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4.w),
              topRight: Radius.circular(4.w),
              bottomLeft: Radius.circular(2.w),
              bottomRight: Radius.circular(2.w),
            ),
            border: Border.all(
              color: color.withAlpha(100),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              '${item.maxTemperature}',
              style: GoogleFonts.ibmPlexMono(
                color: kPrimaryText.withAlpha((_temperature * 200).toInt().clamp(80, 255)),
                fontSize: 6.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    } else if (isOptical) {
      final filamentVisible = _temperature < tempRatio - 0.05;
      final filamentOpacity = filamentVisible ? 1.0 : (1.0 - ((tempRatio - _temperature) / 0.05)).clamp(0.0, 0.3);
      nodeWidget = Container(
        width: nodeSize,
        height: nodeSize * 0.7,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1816),
          borderRadius: BorderRadius.circular(8.w),
          border: Border.all(
            color: color.withAlpha((80 + _temperature * 120).toInt()),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: nodeSize * 0.45,
                height: nodeSize * 0.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0D0A08),
                  border: Border.all(color: kSecondaryText.withAlpha(80), width: 1),
                ),
                child: Center(
                  child: AnimatedOpacity(
                    opacity: filamentOpacity,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 4.w,
                      height: nodeSize * 0.25,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFCC44),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFCC44).withAlpha(100),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      nodeWidget = Container(
        width: nodeSize,
        height: nodeSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1A1816),
          border: Border.all(
            color: color.withAlpha((60 + _temperature * 140).toInt()),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha((localGlowAlpha * 0.5).toInt()),
              blurRadius: glowRadius,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            isThermocouple ? Icons.swap_horiz : Icons.radio_button_unchecked,
            color: color.withAlpha((100 + _temperature * 155).toInt()),
            size: 14.sp,
          ),
        ),
      );
    }

    final pos = _customPositions[item.id];
    final size = MediaQuery.of(context).size;
    final bandIdx = TemperatureBand.values.indexOf(band);
    final rowY = size.height * 0.25 + bandIdx * (size.height * 0.16);
    final itemIdx = entries.indexWhere((e) => e.id == item.id);
    final xOff = (itemIdx * 37 + bandIdx * 53) % 100;
    final calcX = size.width * 0.12 + (xOff / 100.0) * size.width * 0.76;
    final calcY = (rowY + (math.sin(itemIdx * 2.7) * 20)).clamp(size.height * 0.2, size.height * 0.78);
    final dx = pos?.dx ?? calcX;
    final dy = pos?.dy ?? calcY;

    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final phase = _hashId(item.id);
    final floatX = math.sin(time * 0.6 + phase) * 4;
    final floatY = math.sin(time * 0.5 + phase * 1.3) * 4;

    return Positioned(
      key: ValueKey(item.id),
      left: dx - nodeSize / 2 + floatX,
      top: dy - nodeSize / 2 + floatY,
      child: GestureDetector(
        onTap: () => _enterFocus(item, entries),
        onPanUpdate: (details) {
          setState(() {
            _customPositions[item.id] = Offset(
              dx + details.delta.dx,
              dy + details.delta.dy,
            );
          });
        },
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 200),
          child: nodeWidget,
        ),
      ),
    );
  }

  void _enterFocus(ThermalInstrumentModel item, List<ThermalInstrumentModel> entries) {
    final idx = entries.indexWhere((e) => e.id == item.id);
    if (idx == -1) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _focusItem = item;
      _focusIndex = idx;
      _rheostatValue = (item.maxTemperature / 2000.0).clamp(0.0, 1.0);
      _colorMatched = false;
      _focusPanelSlide = 0.0;
    });
    _startColorMatch();
  }

  void _exitFocus() {
    HapticFeedback.mediumImpact();
    setState(() {
      _focusItem = null;
      _focusIndex = null;
    });
  }

  void _startColorMatch() {
    _animatePanelIn();
  }

  double _hashId(String id) {
    return id.codeUnits.fold(0.0, (sum, c) => sum + c) % 100.0;
  }

  void _animatePanelIn() {
    _focusPanelSlide = 0.0;
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 16));
      if (!mounted) return false;
      setState(() {
        _focusPanelSlide += 0.06;
        if (_focusPanelSlide >= 1.0) _focusPanelSlide = 1.0;
      });
      return _focusPanelSlide < 1.0;
    });
  }

  // ── Focus Mode ──

  Widget _buildFocusMode(Size size, double bottomInset) {
    final item = _focusItem!;

    final targetTemp = (item.maxTemperature / 2000.0).clamp(0.0, 1.0);
    final matchThreshold = 0.06;
    final isMatched = (_rheostatValue - targetTemp).abs() < matchThreshold;

    if (isMatched && !_colorMatched) {
      Future.microtask(() {
        if (mounted) {
          setState(() => _colorMatched = true);
          HapticFeedback.heavyImpact();
        }
      });
    }

    final nodeColor = classificationColor(bandForTemperature(item.maxTemperature));
    final topPad = MediaQuery.of(context).padding.top + 8.h;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A08),
      body: Stack(
        children: [
          // Background tint
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: Color.lerp(
                const Color(0xFF0D0A08),
                _blackbodyColor(_rheostatValue),
                _rheostatValue * (_colorMatched ? 0.2 : 0.4),
              ),
            ),
          ),
          // Aperture + rheostat (moves up when panel shows)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            top: _colorMatched ? topPad + 20.h : size.height * 0.35 - 80.h,
            child: GestureDetector(
              onTap: _exitFocus,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Aperture circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: _colorMatched ? 56.w : 160.w,
                    height: _colorMatched ? 56.w : 160.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0D0A08),
                      border: Border.all(
                        color: _colorMatched ? nodeColor.withAlpha(120) : kSecondaryText.withAlpha(100),
                        width: _colorMatched ? 2 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _colorMatched ? nodeColor.withAlpha(80) : Colors.black.withAlpha(100),
                          blurRadius: _colorMatched ? 12 : 20,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _ApertureGlowPainter(
                                nodeColor: nodeColor,
                                brightness: _rheostatValue,
                                matched: _colorMatched,
                              ),
                            ),
                          ),
                          // Filament
                          Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: _colorMatched ? 3.w : 6.w,
                              height: _colorMatched ? 20.w : 40.w,
                              decoration: BoxDecoration(
                                color: _colorMatched
                                    ? nodeColor
                                    : Color.lerp(
                                        const Color(0xFF1A1008),
                                        nodeColor,
                                        _rheostatValue,
                                      ),
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: _rheostatValue > 0.1
                                    ? [
                                        BoxShadow(
                                          color: nodeColor.withAlpha((_rheostatValue * 100).toInt()),
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ),
                          if (_colorMatched)
                            Center(
                              child: Text(
                                '✓',
                                style: GoogleFonts.ibmPlexMono(
                                  color: nodeColor,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Rheostat slider
                  Container(
                    width: 200.w,
                    height: 48.h,
                    margin: EdgeInsets.only(top: 16.h),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1816),
                      borderRadius: BorderRadius.circular(kRadiusPill),
                      border: Border.all(color: kOutline, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wb_sunny_outlined, color: kSecondaryText, size: 14.sp),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 3.h,
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.w),
                              activeTrackColor: nodeColor,
                              inactiveTrackColor: kOutline,
                              thumbColor: nodeColor,
                              overlayColor: nodeColor.withAlpha(20),
                            ),
                            child: Slider(
                              value: _rheostatValue,
                              onChanged: (v) => setState(() {
                                _rheostatValue = v;
                                _colorMatched = false;
                              }),
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.wb_sunny,
                            color: nodeColor.withAlpha((_rheostatValue * 200 + 55).toInt()),
                            size: 14.sp),
                      ],
                    ),
                  ),
                  // Status text
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      _colorMatched
                          ? '✓ TEMPERATURE CONFIRMED'
                          : 'ADJUST FILAMENT TO MATCH',
                      style: GoogleFonts.ibmPlexMono(
                        color: _colorMatched ? nodeColor : kSecondaryText,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Focus panel (slides up from bottom)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: _colorMatched ? 0 : -(size.height * 0.55),
            child: _colorMatched ? _buildFocusPanel(item, size, bottomInset) : const SizedBox.shrink(),
          ),
          // Close button
          Positioned(
            top: topPad,
            left: 16.w,
            child: GestureDetector(
              onTap: _exitFocus,
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1816),
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                  border: Border.all(color: kError),
                ),
                child: Icon(Icons.close, color: kPrimaryText, size: 18.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusPanel(ThermalInstrumentModel item, Size size, double bottomInset) {
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(item.photoPath);
    final hasImage = imagePath != null && item.photoPath.isNotEmpty && File(imagePath).existsSync();
    final band = bandForTemperature(item.maxTemperature);
    final bandColor = classificationColor(band);

    return Transform.translate(
      offset: Offset(0, (1.0 - _focusPanelSlide) * 400),
      child: Container(
        constraints: BoxConstraints(maxHeight: size.height * 0.6),
        margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, bottomInset + 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1816),
          borderRadius: BorderRadius.circular(kRadiusMedium),
          border: Border.all(color: bandColor.withAlpha(80), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(150),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusMedium - 1),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header plaque
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0A08),
                    border: Border(
                      bottom: BorderSide(color: bandColor.withAlpha(50)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.makerDisplay.toUpperCase(),
                              style: GoogleFonts.bebasNeue(
                                color: bandColor,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              item.thermalRegistryHash,
                              style: GoogleFonts.ibmPlexMono(
                                color: kSecondaryText,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Photo
                if (hasImage)
                  ClipRRect(
                    child: Image.file(
                      File(imagePath),
                      width: double.infinity,
                      height: 160.h,
                      fit: BoxFit.cover,
                      color: _focusPanelSlide < 1.0
                          ? Colors.black.withAlpha((200 - (_focusPanelSlide * 200).toInt()).clamp(0, 200))
                          : null,
                      colorBlendMode: _focusPanelSlide < 1.0 ? BlendMode.darken : null,
                    ),
                  ),
                // Specs
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _plaqueRow('TEMPERATURE RANGE',
                          '${item.minTemperature}${item.temperatureUnit} – ${item.maxTemperature}${item.temperatureUnit}',
                          bandColor),
                      SizedBox(height: 10.h),
                      _plaqueRow('CLASSIFICATION', item.pyrometricClassification.label, kSecondaryText),
                      SizedBox(height: 10.h),
                      _plaqueRow('OPTICAL INTEGRITY', item.opticalIntegrity.label,
                          getOpticalIntegrityColor(item.opticalIntegrity)),
                      SizedBox(height: 10.h),
                      _plaqueRow('EMISSIVITY FACTOR',
                          '${item.emissivityFactor.label} (${item.emissivityFactor.value})', kGold),
                      if (item.thermocoupleAlloy != ThermocoupleAlloy.notApplicable) ...[
                        SizedBox(height: 10.h),
                        _plaqueRow('THERMOCOUPLE', item.thermocoupleAlloy.label, kSecondaryText),
                      ],
                      if (item.opticalWavebandFilter.isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        _plaqueRow('WAVEBAND', '${item.opticalWavebandFilter} μm', kSecondaryText),
                      ],
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bandColor,
                            foregroundColor: _contrastText(bandColor),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(kRadiusSubtle),
                            ),
                          ),
                          onPressed: () {
                            if (_focusIndex != null) {
                              Navigator.pushNamed(
                                context,
                                '/info_screen',
                                arguments: {'index': _focusIndex},
                              );
                            }
                          },
                          child: Text(
                            'FULL INSPECTION',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _plaqueRow(String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 120.w,
          child: Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 8.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.ibmPlexSans(
              color: valueColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _contrastText(Color bg) {
    final luminance = (0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b);
    return luminance > 0.5 ? kBackground : kPrimaryText;
  }

  Widget _buildEmpty(Size size) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A08),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department_outlined, size: 64.sp, color: kOutline),
            SizedBox(height: 16.h),
            Text(
              'NO INSTRUMENTS IN THE FORGE',
              style: GoogleFonts.ibmPlexMono(
                color: kSecondaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add instruments to see them in the blast furnace.',
              style: GoogleFonts.ibmPlexSans(
                color: kSecondaryText.withAlpha(160),
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Painters ──

class _HeatRisePainter extends CustomPainter {
  final double temperature;
  final int glowAlpha;

  _HeatRisePainter({required this.temperature, required this.glowAlpha});

  @override
  void paint(Canvas canvas, Size size) {
    final heatHeight = size.height * 0.7 * temperature;
    if (heatHeight < 1) return;

    final heatPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFFD4520A).withAlpha(glowAlpha),
          const Color(0xFF8B1A0A).withAlpha((glowAlpha * 0.5).toInt()),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, size.height - heatHeight, size.width, heatHeight));

    canvas.drawRect(
      Rect.fromLTWH(0, size.height - heatHeight, size.width, heatHeight),
      heatPaint,
    );

    // Heat shimmer lines
    if (temperature > 0.2) {
      final shimmerPaint = Paint()
        ..color = const Color(0xFFD4520A).withAlpha((glowAlpha * 0.3).toInt())
        ..strokeWidth = 0.5;
      for (int i = 0; i < 12; i++) {
        final x = (i * size.width / 12) + (DateTime.now().millisecondsSinceEpoch % 3000) / 3000 * 20;
        final shimmerHeight = heatHeight * (0.3 + 0.7 * (i % 3) / 3);
        canvas.drawLine(
          Offset(x, size.height - shimmerHeight),
          Offset(x, size.height - shimmerHeight + 10),
          shimmerPaint..color = const Color(0xFFD4520A).withAlpha((glowAlpha * 0.2 * (i % 3 + 1) / 3).toInt()),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeatRisePainter old) =>
      old.temperature != temperature || old.glowAlpha != glowAlpha;
}

class _ApertureGlowPainter extends CustomPainter {
  final Color nodeColor;
  final double brightness;
  final bool matched;

  _ApertureGlowPainter({
    required this.nodeColor,
    required this.brightness,
    required this.matched,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy);

    if (brightness > 0.01) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            nodeColor.withAlpha(matched ? 120 : (brightness * 100).toInt()),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
      canvas.drawCircle(Offset(cx, cy), r * 0.8, glowPaint);
    }

    if (matched) {
      final matchPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            nodeColor.withAlpha(60),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
      canvas.drawCircle(Offset(cx, cy), r, matchPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ApertureGlowPainter old) =>
      old.nodeColor != nodeColor || old.brightness != brightness || old.matched != matched;
}
