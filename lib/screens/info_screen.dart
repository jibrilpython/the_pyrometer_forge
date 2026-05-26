import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_pyrometer_forge/enum/my_enums.dart';
import 'package:the_pyrometer_forge/models/project_model.dart';
import 'package:the_pyrometer_forge/providers/image_provider.dart';
import 'package:the_pyrometer_forge/providers/project_provider.dart';
import 'package:the_pyrometer_forge/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoScreen extends ConsumerWidget {
  final int index;
  const InfoScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectProv = ref.watch(projectProvider);
    if (index < 0 || index >= projectProv.entries.length) {
      return const Scaffold(
          body: Center(child: Text('INSTRUMENT NOT FOUND')));
    }
    final entry = projectProv.entries[index];
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);
    final band = bandForTemperature(entry.maxTemperature);

    return Scaffold(
      backgroundColor: kBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 80.w,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: _glassAction(
              context,
              icon: Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Align(
            alignment: Alignment.center,
            child: _glassAction(
              context,
              icon: Icons.edit_outlined,
              onTap: () {
                projectProv.fillInput(ref, index);
                Navigator.pushNamed(
                  context,
                  '/add_screen',
                  arguments: {'isEdit': true, 'currentIndex': index},
                );
              },
            ),
          ),
          SizedBox(width: 8.w),
          Align(
            alignment: Alignment.center,
            child: _glassAction(
              context,
              icon: Icons.delete_outline,
              iconColor: kError,
              onTap: () =>
                  _showDeleteDialog(context, projectProv, index),
            ),
          ),
          SizedBox(width: 20.w),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(child: _buildHero(imagePath, entry)),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 120.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeader(entry, band),
                SizedBox(height: 28.h),
                _buildTempArc(entry),
                SizedBox(height: 28.h),
                _buildSpecGrid(entry),
                SizedBox(height: 28.h),
                _buildIntegrity(entry),
                SizedBox(height: 28.h),
                _buildObservations(entry),
                if (entry.tags.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  _buildTags(entry),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(String? imagePath, ThermalInstrumentModel entry) {
    return Container(
      width: double.infinity,
      height: 400.h,
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(kRadiusMedium),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          (entry.photoPath.isNotEmpty &&
                  imagePath != null &&
                  File(imagePath).existsSync())
              ? Image.file(File(imagePath), fit: BoxFit.cover)
              : Container(
                  color: kBackground,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.thermostat_outlined,
                            size: 56.sp, color: kOutline),
                        SizedBox(height: 12.h),
                        Text(
                          'PHOTOGRAPH UNASSIGNED',
                          style: GoogleFonts.ibmPlexMono(
                            color: kSecondaryText,
                            fontSize: 10.sp,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(60),
                  Colors.transparent,
                  Colors.black.withAlpha(80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      ThermalInstrumentModel entry, TemperatureBand band) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                entry.thermalRegistryHash.isNotEmpty
                    ? entry.thermalRegistryHash
                    : 'NO-HASH',
                style: GoogleFonts.ibmPlexMono(
                  color: kAccent,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            _bandPill(band),
          ],
        ),
        SizedBox(height: 10.h),
        Text(
          entry.makerDisplay.toUpperCase(),
          style: GoogleFonts.bebasNeue(
            color: kPrimaryText,
            fontSize: 28.sp,
            fontWeight: FontWeight.w400,
            height: 1.0,
            letterSpacing: 0.5,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Text(
              entry.pyrometricClassification.label,
              style: GoogleFonts.ibmPlexSans(
                color: kSecondaryText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w300,
              ),
            ),
            if (entry.thermocoupleAlloy !=
                ThermocoupleAlloy.notApplicable) ...[
              Text('  ·  ',
                  style: GoogleFonts.ibmPlexSans(
                      color: kOutline, fontSize: 13.sp)),
              Text(
                entry.thermocoupleAlloy.label,
                style: GoogleFonts.ibmPlexSans(
                  color: kSecondaryText,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _bandPill(TemperatureBand band) {
    final color = classificationColor(band);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            band.label,
            style: GoogleFonts.ibmPlexMono(
              color: color,
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempArc(ThermalInstrumentModel entry) {
    final maxFrac = (entry.maxTemperature / 3200.0).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Arc lives in a fixed-height box so it can breathe
          SizedBox(
            height: 130.h,
            width: double.infinity,
            child: CustomPaint(
              painter: _InfoTempArcPainter(
                minTemp: entry.minTemperature,
                maxTemp: entry.maxTemperature,
                unit: entry.temperatureUnit,
              ),
            ),
          ),
          // Clear visual separator
          Divider(height: 1, color: kOutline),
          // MIN / MAX labels — clearly below the arc
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: _tempLabel(
                    'MIN',
                    '${entry.minTemperature}${entry.temperatureUnit}',
                    const Color(0xFF8B1A1A),
                  ),
                ),
                // Tick marks decoration
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Container(
                      height: 1.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF8B1A1A),
                            kAccent,
                            kGold,
                            temperatureToColor(maxFrac),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(kRadiusPill),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: _tempLabel(
                    'MAX',
                    '${entry.maxTemperature}${entry.temperatureUnit}',
                    temperatureToColor(maxFrac),
                    alignRight: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tempLabel(String label, String value, Color color,
      {bool alignRight = false}) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 7.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: GoogleFonts.ibmPlexMono(
            color: color,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSpecGrid(ThermalInstrumentModel entry) {
    final cells = <Widget>[
      _specCell(
        'CLASSIFICATION',
        entry.pyrometricClassification.label,
        Icons.category_outlined,
        getClassificationColor(entry.pyrometricClassification),
      ),
      _specCell(
        'MAKER',
        entry.makerDisplay,
        Icons.handyman_outlined,
        getMakerColor(entry.makerSign),
      ),
      _specCell(
        'EMISSIVITY FACTOR',
        '${entry.emissivityFactor.label} (E=${entry.emissivityFactor.value})',
        Icons.opacity,
        kGold,
      ),
      if (entry.thermocoupleAlloy != ThermocoupleAlloy.notApplicable)
        _specCell(
          'THERMOCOUPLE ALLOY',
          entry.thermocoupleAlloy.fullName,
          Icons.electric_bolt,
          kAccent,
        ),
      if (entry.opticalWavebandFilter.isNotEmpty)
        _specCell(
          'OPTICAL WAVEBAND',
          '${entry.opticalWavebandFilter} μm',
          Icons.visibility,
          kGold,
        ),
      if (entry.auxiliaryPowerImpedance.isNotEmpty)
        _specCell(
          'POWER & IMPEDANCE',
          entry.auxiliaryPowerImpedance,
          Icons.battery_unknown,
          kAccent,
        ),
      if (entry.enclosureVolumetrics.isNotEmpty)
        _specCell(
          'ENCLOSURE',
          entry.enclosureVolumetrics,
          Icons.square_foot,
          kSecondaryText,
        ),
      if (entry.mass.isNotEmpty)
        _specCell('MASS', entry.mass, Icons.scale, kSecondaryText),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'THERMAL SPECIFICATIONS',
          style: GoogleFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 16.h),
        ..._spacedSpecCells(cells),
      ],
    );
  }

  List<Widget> _spacedSpecCells(List<Widget> cells) {
    final spaced = <Widget>[];
    for (var i = 0; i < cells.length; i++) {
      if (i > 0) spaced.add(SizedBox(height: 8.h));
      spaced.add(cells[i]);
    }
    return spaced;
  }

  Widget _specCell(
      String label, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline.withAlpha(80)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14.sp, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.ibmPlexMono(
                    color: kSecondaryText,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: GoogleFonts.ibmPlexSans(
                    color: kPrimaryText,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrity(ThermalInstrumentModel entry) {
    final cells = <Widget>[
      _specCell(
        'OPTICAL LENSES',
        entry.opticalIntegrity.label,
        Icons.visibility,
        getOpticalIntegrityColor(entry.opticalIntegrity),
      ),
      if (entry.electricalContinuity != MechanicalContinuity.notApplicable)
        _specCell(
          'ELECTRICAL CONTINUITY',
          entry.electricalContinuity.label,
          Icons.electrical_services,
          entry.electricalContinuity == MechanicalContinuity.verified
              ? kAccent
              : kError,
        ),
      if (entry.expansionCoefficientVariables.isNotEmpty)
        _specCell(
          'EXPANSION COEFFICIENTS',
          entry.expansionCoefficientVariables,
          Icons.height,
          kGold,
        ),
      if (entry.deformationEndpointScale.isNotEmpty)
        _specCell(
          'DEFORMATION ENDPOINT',
          entry.deformationEndpointScale,
          Icons.track_changes_outlined,
          kSecondaryText,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'MECHANICAL & OPTICAL INTEGRITY',
          style: GoogleFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 16.h),
        ..._spacedSpecCells(cells),
      ],
    );
  }

  Widget _buildObservations(ThermalInstrumentModel entry) {
    final panels = <Widget>[];
    void add(String lbl, String val, IconData ico) {
      if (val.isNotEmpty) panels.add(_obsCard(lbl, val, ico));
    }

    add('FOUNDRY PROVENANCE', entry.provenanceDisplay, Icons.factory_outlined);
    add('ARCHIVAL NOTES', entry.notes, Icons.notes);
    return SizedBox(width: double.infinity, child: Column(children: panels));
  }

  Widget _obsCard(String label, String text, IconData icon) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 13.sp, color: kAccent),
              SizedBox(width: 8.w),
              Text(
                label,
                style: GoogleFonts.ibmPlexMono(
                  color: kAccent,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            text,
            style: GoogleFonts.ibmPlexSans(
              color: kPrimaryText,
              fontSize: 14.sp,
              height: 1.6,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(ThermalInstrumentModel entry) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: entry.tags
          .map(
            (tag) => Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.circular(kRadiusSubtle),
                border: Border.all(color: kOutline),
              ),
              child: Text(
                '#${tag.toUpperCase()}',
                style: GoogleFonts.ibmPlexMono(
                  color: kSecondaryText,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _glassAction(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = kPrimaryText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40.r,
            height: 40.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(160),
              borderRadius: BorderRadius.circular(kRadiusSubtle),
              border: Border.all(color: kAccent.withAlpha(180), width: 1.5),
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ProjectNotifier projectProv,
    int idx,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusMedium),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: EdgeInsets.all(28.w),
              color: kPanelBg.withAlpha(240),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: kError, size: 44.sp),
                  SizedBox(height: 16.h),
                  Text(
                    'REMOVE RECORD?',
                    style: GoogleFonts.bebasNeue(
                      color: kPrimaryText,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'This will permanently remove this thermal instrument from the archive.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSans(
                      color: kSecondaryText,
                      fontSize: 13.sp,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            height: 50.h,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: kBackground,
                              borderRadius: BorderRadius.circular(
                                  kRadiusSubtle),
                              border: Border.all(color: kOutline),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.ibmPlexSans(
                                color: kPrimaryText,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            projectProv.deleteEntry(idx);
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 50.h,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: kError,
                              borderRadius: BorderRadius.circular(
                                  kRadiusSubtle),
                            ),
                            child: Text(
                              'Remove',
                              style: GoogleFonts.ibmPlexSans(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTempArcPainter extends CustomPainter {
  final int minTemp;
  final int maxTemp;
  final String unit;

  const _InfoTempArcPainter({
    required this.minTemp,
    required this.maxTemp,
    required this.unit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 8;
    final radius = math.min(size.width, size.height) / 2 * 0.72;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;

    // Gradient arc (downward U: π → 2π)
    final segments = 30;
    for (int i = 0; i < segments; i++) {
      final frac = i / segments;
      paint.color = temperatureToColor(frac).withAlpha(210);
      final startAngle = math.pi + frac * math.pi;
      final sweepAngle = math.pi / segments + 0.01;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    // Marker dot at max temperature
    final maxFrac = (maxTemp / 3200.0).clamp(0.0, 1.0);
    final markerAngle = math.pi + maxFrac * math.pi;
    final markerX = cx + math.cos(markerAngle) * radius;
    final markerY = cy + math.sin(markerAngle) * radius;

    canvas.drawCircle(
      Offset(markerX, markerY),
      8,
      Paint()
        ..color = temperatureToColor(maxFrac)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(markerX, markerY),
      13,
      Paint()
        ..color = temperatureToColor(maxFrac).withAlpha(55)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _InfoTempArcPainter old) =>
      old.minTemp != minTemp || old.maxTemp != maxTemp || old.unit != unit;
}
