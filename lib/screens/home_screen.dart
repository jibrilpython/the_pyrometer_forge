import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_pyrometer_forge/enum/my_enums.dart';
import 'package:the_pyrometer_forge/models/project_model.dart';
import 'package:the_pyrometer_forge/providers/image_provider.dart';
import 'package:the_pyrometer_forge/providers/project_provider.dart';
import 'package:the_pyrometer_forge/providers/search_provider.dart';
import 'package:the_pyrometer_forge/providers/input_provider.dart';
import 'package:the_pyrometer_forge/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  TemperatureBand? _selectedBandFilter;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProv = ref.watch(searchProvider);
    final projectProv = ref.watch(projectProvider);
    final allEntries = projectProv.entries;

    final filteredByBand = _selectedBandFilter == null
        ? allEntries
        : allEntries
              .where((e) => _selectedBandFilter!.contains(e.maxTemperature))
              .toList();
    final entries = searchProv.filteredList(filteredByBand);

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          _buildHeaderSliver(allEntries.length),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  _buildSearchBar(),
                  SizedBox(height: kSpacingM.h),
                  _buildBandFilterChips(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          entries.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 140.h),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12.w,
                    crossAxisSpacing: 12.w,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final mainIndex = ref
                          .read(projectProvider)
                          .entries
                          .indexWhere((e) => e.id == entry.id);
                      return _buildInstrumentCard(context, entry, mainIndex);
                    },
                    childCount: entries.length,
                  ),
                ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 90.h),
        child: GestureDetector(
          onTap: () {
            ref.read(inputProvider).clearAll();
            ref.read(imageProvider).clearImage();
            Navigator.pushNamed(context, '/add_screen');
          },
          child: Container(
            height: 52.h,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: kAccent,
              borderRadius: BorderRadius.circular(kRadiusPill),
              boxShadow: const [kShadowOrange],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: kPrimaryText, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Log Instrument',
                  style: GoogleFonts.ibmPlexSans(
                    color: kPrimaryText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSliver(int count) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, topPadding, 20.w, kSpacingM.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _PulsingDot(),
                SizedBox(width: 8.w),
                Text(
                  'THERMAL ARCHIVE',
                  style: GoogleFonts.ibmPlexMono(
                    color: kAccent,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'THE',
                      style: GoogleFonts.bebasNeue(
                        color: kAccent,
                        fontSize: 20.sp,
                        letterSpacing: 4.0,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'PYROMETER\nFORGE',
                      style: GoogleFonts.bebasNeue(
                        color: kPrimaryText,
                        fontSize: 44.sp,
                        fontWeight: FontWeight.w400,
                        height: 0.88,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutExpo,
                      tween: Tween(begin: 0, end: count.toDouble()),
                      builder: (_, val, _) => Text(
                        val.toInt().toString().padLeft(2, '0'),
                        style: GoogleFonts.ibmPlexMono(
                          color: kAccent,
                          fontSize: 42.sp,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                    ),
                    Text(
                      'INSTRUMENTS',
                      style: GoogleFonts.ibmPlexMono(
                        color: kSecondaryText,
                        fontSize: 7.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: kSpacingM.h),
            Container(
              height: 3.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8B1A1A),
                    Color(0xFFE8622A),
                    Color(0xFFC4920A),
                    Color(0xFFFFF3CC),
                  ],
                  stops: [0.0, 0.35, 0.70, 1.0],
                ),
                borderRadius: BorderRadius.circular(kRadiusPill),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final isFocused = _searchFocusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 50.h,
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(
          color: isFocused ? kAccent : kOutline,
          width: isFocused ? 1.5 : 1.0,
        ),
        boxShadow: const [kShadowSubtle],
      ),
      child: Row(
        children: [
          SizedBox(width: 14.w),
          Icon(
            Icons.search,
            color: isFocused ? kAccent : kSecondaryText,
            size: 18.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (v) =>
                  ref.read(searchProvider.notifier).setSearchQuery(v),
              style: GoogleFonts.ibmPlexSans(
                color: kPrimaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w300,
              ),
              decoration: InputDecoration(
                hintText: 'Search makers, hashes, provenance…',
                hintStyle: GoogleFonts.ibmPlexSans(
                  color: kSecondaryText.withAlpha(120),
                  fontSize: 14.sp,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                ref.read(searchProvider.notifier).clearSearchQuery();
                setState(() {});
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Icon(Icons.close, color: kSecondaryText, size: 16.sp),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBandFilterChips() {
    return SizedBox(
      height: 36.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        children: [
          _buildChip('All', null),
          ...TemperatureBand.values.map((b) => _buildChip(b.label, b)),
        ],
      ),
    );
  }

  Widget _buildChip(String label, TemperatureBand? band) {
    final isSelected = _selectedBandFilter == band;
    return GestureDetector(
      onTap: () => setState(() => _selectedBandFilter = band),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: isSelected ? kAccent : kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: Border.all(color: isSelected ? kAccent : kOutline, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            color: isSelected ? kPrimaryText : kSecondaryText,
            fontSize: 10.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInstrumentCard(
    BuildContext context,
    ThermalInstrumentModel entry,
    int index,
  ) {
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);
    final band = bandForTemperature(entry.maxTemperature);
    final bandColor = classificationColor(band);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/info_screen',
        arguments: {'index': index},
      ),
      child: SizedBox(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: kPanelBg,
                borderRadius: BorderRadius.circular(kRadiusSubtle),
                boxShadow: const [kShadowSubtle],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Image or temperature arc
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.1,
                  child:
                      (entry.photoPath.isNotEmpty &&
                          imagePath != null &&
                          File(imagePath).existsSync())
                      ? Image.file(File(imagePath), fit: BoxFit.cover)
                      : Container(
                          color: kBackground,
                          child: Center(
                            child: CustomPaint(
                              size: Size(64.w, 64.w),
                              painter: _TempArcPainter(
                                minTemp: entry.minTemperature,
                                maxTemp: entry.maxTemperature,
                              ),
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 10.w,
                  right: 10.w,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: bandColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: bandColor.withAlpha(80),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.thermalRegistryHash.isNotEmpty
                        ? entry.thermalRegistryHash
                        : 'NO-HASH',
                    style: GoogleFonts.ibmPlexMono(
                      color: kAccent,
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    entry.makerDisplay,
                    style: GoogleFonts.bebasNeue(
                      color: kPrimaryText,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.1,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    entry.pyrometricClassification.label,
                    style: GoogleFonts.ibmPlexSans(
                      color: kSecondaryText,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w300,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  // Temperature range pill
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: kGoldSurface,
                      borderRadius: BorderRadius.circular(kRadiusPill),
                      border: Border.all(color: kGold.withAlpha(40), width: 1),
                    ),
                    child: Text(
                      '${entry.minTemperature}${entry.temperatureUnit} – ${entry.maxTemperature}${entry.temperatureUnit}',
                      style: GoogleFonts.ibmPlexMono(
                        color: kGold,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  if (entry.provenanceDisplay.isNotEmpty &&
                      entry.foundryProvenance != FoundryProvenance.other)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: kAccent.withAlpha(25),
                        borderRadius: BorderRadius.circular(kRadiusPill),
                      ),
                      child: Text(
                        entry.provenanceDisplay,
                        style: GoogleFonts.ibmPlexMono(
                          color: kAccent.withAlpha(200),
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      Positioned.fill(
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kRadiusSubtle),
              border: Border.all(color: kOutline, width: 1),
            ),
          ),
        ),
      ),
    ],
  ),
),
);
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 52.h, horizontal: 24.w),
            decoration: BoxDecoration(
              color: kPanelBg,
              borderRadius: BorderRadius.circular(kRadiusSubtle),
              border: Border.all(color: kOutline, width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  size: 56.sp,
                  color: kOutline,
                ),
                SizedBox(height: 20.h),
                Text(
                  'NO INSTRUMENTS IN THIS FORGE.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexMono(
                    color: kSecondaryText,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tap "Log Instrument" to begin cataloging your collection of vintage pyrometers and thermal measurement devices.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexSans(
                    color: kSecondaryText.withAlpha(160),
                    fontSize: 13.sp,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Temperature gradient arc painter — the most expressive motif
class _TempArcPainter extends CustomPainter {
  final int minTemp;
  final int maxTemp;

  const _TempArcPainter({required this.minTemp, required this.maxTemp});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 * 0.85;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Draw arc segments from low (deep red) to high (gold)
    final segments = 20;
    for (int i = 0; i < segments; i++) {
      final frac = i / segments;
      final color = temperatureToColor(frac);
      paint.color = color.withAlpha(180);

      final startAngle = -math.pi + frac * math.pi;
      final sweepAngle = math.pi / segments;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    // Marker dot at max temp position
    final maxFrac = (maxTemp / 3200.0).clamp(0.0, 1.0);
    final markerAngle = -math.pi + maxFrac * math.pi;
    final markerX = cx + math.cos(markerAngle) * radius;
    final markerY = cy + math.sin(markerAngle) * radius;

    final markerPaint = Paint()
      ..color = temperatureToColor(maxFrac)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(markerX, markerY), 4, markerPaint);

    // Center label area
    final labelPaint = Paint()
      ..color = kSecondaryText.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(cx, cy), radius * 0.4, labelPaint);
  }

  @override
  bool shouldRepaint(covariant _TempArcPainter old) =>
      old.minTemp != minTemp || old.maxTemp != maxTemp;
}

// ─── Pulsing status dot ──────────────────────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.25,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Container(
        width: 6.w,
        height: 6.w,
        decoration: BoxDecoration(
          color: kAccent.withAlpha((_anim.value * 255).toInt()),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kAccent.withAlpha((_anim.value * 120).toInt()),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
