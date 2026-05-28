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
      body: Stack(
        children: [
          // Background ambient glow
          Positioned(
            top: -100.h,
            right: -50.w,
            child: Container(
              width: 250.w,
              height: 250.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kAccent.withAlpha(25),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              _buildHeaderSliver(allEntries.length),

              // Search and filters sticky header
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  minHeight: 110.h,
                  maxHeight: 110.h,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: kBackground.withAlpha(210),
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSearchBar(),
                            SizedBox(height: 16.h),
                            _buildBandFilterChips(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              entries.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmptyState())
                  : SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 140.h),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16.w,
                        crossAxisSpacing: 16.w,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          final mainIndex = ref
                              .read(projectProvider)
                              .entries
                              .indexWhere((e) => e.id == entry.id);
                          return _buildInstrumentCard(
                            context,
                            entry,
                            mainIndex,
                          );
                        },
                        childCount: entries.length,
                      ),
                    ),
            ],
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 100.h),
        child: GestureDetector(
          onTap: () {
            ref.read(inputProvider).clearAll();
            ref.read(imageProvider).clearImage();
            Navigator.pushNamed(context, '/add_screen');
          },
          child: Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: kAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kAccent.withAlpha(100),
                  blurRadius: 24,
                  spreadRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.add, color: kPrimaryText, size: 30.sp),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildHeaderSliver(int count) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, topPadding + 20.h, 20.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'THERMAL ARCHIVE',
                  style: GoogleFonts.ibmPlexMono(
                    color: kSecondaryText,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: kAccent.withAlpha(20),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: kAccent.withAlpha(50)),
                  ),
                  child: Text(
                    '$count ${count == 1 ? "INSTRUMENT" : "INSTRUMENTS"}',
                    style: GoogleFonts.ibmPlexMono(
                      color: kAccent,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'THE PYROMETER FORGE',
              style: GoogleFonts.bebasNeue(
                color: kPrimaryText,
                fontSize: 42.sp,
                fontWeight: FontWeight.w400,
                height: 1.0,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              height: 2.h,
              width: 60.w,
              decoration: BoxDecoration(
                color: kAccent,
                boxShadow: [
                  BoxShadow(
                    color: kAccent.withAlpha(150),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final isFocused = _searchFocusNode.hasFocus;
    final hasText = _searchController.text.isNotEmpty;

    return Container(
      height: 54.h,
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: kOutline.withAlpha(80), width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // ── Left accent strip (animated temperature-gradient bar) ──
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            width: 3.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isFocused
                    ? [const Color(0xFF8B1A1A), kAccent, kGold]
                    : [kOutline, kOutline, kOutline],
              ),
            ),
          ),

          // ── SEARCH label tab (collapses on focus / has text) ──────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: isFocused || hasText ? 0 : 72.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: isFocused || hasText
                      ? Colors.transparent
                      : kOutline.withAlpha(80),
                  width: 1.0,
                ),
              ),
            ),
            child: AnimatedOpacity(
              opacity: isFocused || hasText ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Text(
                'SEARCH',
                style: GoogleFonts.ibmPlexMono(
                  color: kSecondaryText,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),

          // ── Text input ──────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (v) =>
                    ref.read(searchProvider.notifier).setSearchQuery(v),
                style: GoogleFonts.ibmPlexMono(
                  color: kPrimaryText,
                  fontSize: 13.sp,
                  letterSpacing: 0.8,
                ),
                decoration: InputDecoration(
                  hintText: isFocused
                      ? 'maker · hash · provenance...'
                      : 'Search archive...',
                  hintStyle: GoogleFonts.ibmPlexMono(
                    color: kSecondaryText.withAlpha(100),
                    fontSize: 13.sp,
                    letterSpacing: 0.8,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),

          // ── CLEAR action zone (shown when typing) ────────────────────
          if (hasText)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                ref.read(searchProvider.notifier).clearSearchQuery();
                setState(() {});
              },
              child: Container(
                height: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: kOutline.withAlpha(80), width: 1.0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close, color: kSecondaryText, size: 14.sp),
                    SizedBox(width: 5.w),
                    Text(
                      'CLEAR',
                      style: GoogleFonts.ibmPlexMono(
                        color: kSecondaryText,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // ── Search icon zone (idle) ─────────────────────────────
            Container(
              height: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: kOutline.withAlpha(80), width: 1.0),
                ),
              ),
              child: Icon(
                Icons.search,
                color: isFocused ? kAccent : kSecondaryText.withAlpha(120),
                size: 18.sp,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBandFilterChips() {
    return SizedBox(
      height: 32.h,
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
        margin: EdgeInsets.only(right: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? kAccent : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            color: isSelected ? kPrimaryText : kSecondaryText,
            fontSize: 11.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            letterSpacing: 0.5,
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

    final hasImage =
        entry.photoPath.isNotEmpty &&
        imagePath != null &&
        File(imagePath).existsSync();

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/info_screen',
        arguments: {'index': index},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image / Arc section
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (hasImage)
                        Image.file(File(imagePath), fit: BoxFit.cover)
                      else
                        Container(
                          color: kBackground.withAlpha(100),
                          child: Center(
                            child: CustomPaint(
                              size: Size(80.w, 80.w),
                              painter: _TempArcPainter(
                                minTemp: entry.minTemperature,
                                maxTemp: entry.maxTemperature,
                              ),
                            ),
                          ),
                        ),
                      // Gradient overlay for better blend with card details
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 40.h,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [kPanelBg, kPanelBg.withAlpha(0)],
                            ),
                          ),
                        ),
                      ),
                      // Top Right Band Color Dot
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
                                color: bandColor.withAlpha(150),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Card Details
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.makerDisplay,
                        style: GoogleFonts.bebasNeue(
                          color: kPrimaryText,
                          fontSize: 18.sp,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        entry.pyrometricClassification.label,
                        style: GoogleFonts.ibmPlexSans(
                          color: kSecondaryText,
                          fontSize: 10.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(Icons.thermostat, size: 12.sp, color: kGold),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              '${entry.minTemperature} – ${entry.maxTemperature}${entry.temperatureUnit}',
                              style: GoogleFonts.ibmPlexMono(
                                color: kGold,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Border overlay on top of children
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: kOutline.withAlpha(150), width: 1),
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
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPanelBg,
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 20),
                ],
              ),
              child: Icon(
                Icons.local_fire_department_outlined,
                size: 48.sp,
                color: kSecondaryText.withAlpha(150),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'NO INSTRUMENTS FOUND',
              style: GoogleFonts.ibmPlexMono(
                color: kSecondaryText,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Begin cataloging your vintage pyrometers.',
              textAlign: TextAlign.center,
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
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
