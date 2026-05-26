import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_pyrometer_forge/enum/my_enums.dart';
import 'package:the_pyrometer_forge/models/project_model.dart';
import 'package:the_pyrometer_forge/providers/project_provider.dart';
import 'package:the_pyrometer_forge/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});
  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  TemperatureBand? _selectedBand;
  String? _expandedLabel;

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    final total = entries.length;

    if (total == 0) {
      return Scaffold(backgroundColor: kBackground, body: _buildEmpty());
    }

    final classCounts = <PyrometricClassification, int>{};
    final bandCounts = <TemperatureBand, int>{};
    final makerCounts = <MakerSign, int>{};
    final makerSet = <MakerSign>{};
    int minTempGlobal = entries.first.minTemperature;
    int maxTempGlobal = entries.first.maxTemperature;
    DateTime earliest = entries.first.dateAdded;
    DateTime latest = entries.first.dateAdded;
    double totalSpan = 0;

    for (final e in entries) {
      classCounts[e.pyrometricClassification] =
          (classCounts[e.pyrometricClassification] ?? 0) + 1;
      final band = bandForTemperature(e.maxTemperature);
      bandCounts[band] = (bandCounts[band] ?? 0) + 1;
      makerCounts[e.makerSign] = (makerCounts[e.makerSign] ?? 0) + 1;
      makerSet.add(e.makerSign);
      if (e.minTemperature < minTempGlobal) minTempGlobal = e.minTemperature;
      if (e.maxTemperature > maxTempGlobal) maxTempGlobal = e.maxTemperature;
      if (e.dateAdded.isBefore(earliest)) earliest = e.dateAdded;
      if (e.dateAdded.isAfter(latest)) latest = e.dateAdded;
      totalSpan += e.temperatureSpan;
    }

    final avgSpan = (totalSpan / total).round();
    final uniqueMakers = makerSet.length;
    final daysSpan = latest.difference(earliest).inDays;
    final sortedByDate = List<ThermalInstrumentModel>.from(entries)
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    final recent = sortedByDate.take(4).toList();

    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, topPadding + 12.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  SizedBox(height: 20.h),
                  _metricsStrip(total, uniqueMakers, avgSpan, daysSpan),
                  SizedBox(height: 24.h),
                  _sectionLabel('TEMPERATURE SPECTRUM'),
                  SizedBox(height: 14.h),
                  _bandSpectrum(bandCounts, total),
                  if (_selectedBand != null) ...[
                    SizedBox(height: 10.h),
                    _bandReadout(_selectedBand!, bandCounts, total),
                  ],
                  SizedBox(height: 24.h),
                  _sectionLabel('CLASSIFICATION BREAKDOWN'),
                  SizedBox(height: 14.h),
                  _verticalBarList(classCounts, total, isClass: true),
                  SizedBox(height: 24.h),
                  _sectionLabel('MAKER FOOTPRINT'),
                  SizedBox(height: 14.h),
                  _verticalBarList(makerCounts, total, isClass: false),
                  SizedBox(height: 24.h),
                  _sectionLabel('RECENTLY FORGED'),
                  SizedBox(height: 14.h),
                  _recentList(recent, entries),
                  SizedBox(height: 140.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: kAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kAccent.withAlpha(80),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'FORGE ANALYTICS',
              style: GoogleFonts.ibmPlexMono(
                color: kAccent,
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Text(
          'THERMAL\nLOGBOOK',
          style: GoogleFonts.bebasNeue(
            color: kPrimaryText,
            fontSize: 48.sp,
            fontWeight: FontWeight.w400,
            height: 0.88,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _metricsStrip(int total, int makers, int avgSpan, int daysSpan) {
    return Row(
      children: [
        _animatedMetricTile('UNITS', total.toDouble(), kAccent),
        SizedBox(width: 8.w),
        _animatedMetricTile('MAKERS', makers.toDouble(), kGold),
        SizedBox(width: 8.w),
        _animatedMetricTile('AVG SPAN', avgSpan.toDouble(), kSecondaryText),
        SizedBox(width: 8.w),
        _animatedMetricTile('DAYS', daysSpan.toDouble(), kSecondaryText),
      ],
    );
  }

  Widget _animatedMetricTile(String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: color.withAlpha(40), width: 1),
        ),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutExpo,
              tween: Tween(begin: 0, end: value),
              builder: (context, val, child) {
                return Text(
                  label == 'AVG SPAN'
                      ? '${val.round()}°'
                      : val.round().toString().padLeft(2, '0'),
                  style: GoogleFonts.ibmPlexMono(
                    color: color,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
            SizedBox(height: 4.h),
            Container(
              width: 16.w,
              height: 2.h,
              decoration: BoxDecoration(
                color: color.withAlpha(60),
                borderRadius: BorderRadius.circular(kRadiusPill),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                color: kSecondaryText,
                fontSize: 7.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(kRadiusPill),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _bandSpectrum(Map<TemperatureBand, int> data, int total) {
    final bands = TemperatureBand.values;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline, width: 1),
      ),
      child: Column(
        children: bands.map((band) {
          final count = data[band] ?? 0;
          final frac = total > 0 ? count / total : 0.0;
          final color = classificationColor(band);
          final isSelected = _selectedBand == band;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedBand = isSelected ? null : band;
              });
              if (!isSelected) HapticFeedback.selectionClick();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(isSelected ? 10.w : 0),
              decoration: BoxDecoration(
                color: isSelected ? kBackground : Colors.transparent,
                borderRadius: BorderRadius.circular(kRadiusSubtle),
                border: isSelected
                    ? Border.all(color: color.withAlpha(60))
                    : Border.all(color: Colors.transparent),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 60.w,
                    child: Text(
                      band.label.toUpperCase(),
                      style: GoogleFonts.ibmPlexSans(
                        color: isSelected ? color : kSecondaryText,
                        fontSize: 10.sp,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 18.h,
                          decoration: BoxDecoration(
                            color: kOutline.withAlpha(120),
                            borderRadius: BorderRadius.circular(kRadiusPill),
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          tween: Tween(begin: 0, end: frac),
                          builder: (context, anim, child) {
                            return FractionallySizedBox(
                              widthFactor: anim,
                              child: Container(
                                height: 18.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      color.withAlpha(150),
                                      color,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(kRadiusPill),
                                  boxShadow: isSelected
                                      ? [BoxShadow(color: color.withAlpha(60), blurRadius: 6)]
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  SizedBox(
                    width: 32.w,
                    child: Text(
                      '$count',
                      style: GoogleFonts.ibmPlexMono(
                        color: isSelected ? color : kPrimaryText,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _bandReadout(TemperatureBand band, Map<TemperatureBand, int> data, int total) {
    final count = data[band] ?? 0;
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
    final color = classificationColor(band);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(kRadiusPill),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  band.label.toUpperCase(),
                  style: GoogleFonts.ibmPlexSans(
                    color: kPrimaryText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '$count INSTRUMENT${count == 1 ? '' : 'S'} — $pct% OF COLLECTION',
                  style: GoogleFonts.ibmPlexMono(
                    color: kSecondaryText,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _selectedBand = null),
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: kPanelBg,
                borderRadius: BorderRadius.circular(kRadiusSubtle),
                border: Border.all(color: kOutline),
              ),
              child: Icon(Icons.close, size: 12.sp, color: kSecondaryText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalBarList(Map<dynamic, int> data, int total, {required bool isClass}) {
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline, width: 1),
      ),
      child: Column(
        children: sorted.map((e) {
          final frac = total > 0 ? e.value / total : 0.0;
          final color = isClass
              ? getClassificationColor(e.key)
              : getMakerColor(e.key);
          final label = isClass
              ? (e.key as PyrometricClassification).label
              : (e.key as MakerSign).label;
          final isExpanded = _expandedLabel == label;
          return GestureDetector(
            onTap: () {
              setState(() {
                _expandedLabel = isExpanded ? null : label;
              });
              HapticFeedback.selectionClick();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(isExpanded ? 12.w : 0),
              decoration: BoxDecoration(
                color: isExpanded ? kBackground : Colors.transparent,
                borderRadius: BorderRadius.circular(kRadiusSubtle),
                border: isExpanded
                    ? Border.all(color: kOutline)
                    : Border.all(color: Colors.transparent),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        flex: 3,
                        child: Text(
                          label,
                          style: GoogleFonts.ibmPlexSans(
                            color: isExpanded ? color : kPrimaryText,
                            fontSize: 12.sp,
                            fontWeight: isExpanded ? FontWeight.w600 : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            Container(
                              height: 14.h,
                              decoration: BoxDecoration(
                                color: kOutline.withAlpha(100),
                                borderRadius: BorderRadius.circular(kRadiusPill),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: frac,
                              child: Container(
                                height: 14.h,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(kRadiusPill),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      SizedBox(
                        width: 36.w,
                        child: Text(
                          '${(frac * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.ibmPlexMono(
                            color: isExpanded ? color : kSecondaryText,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  if (isExpanded) ...[
                    SizedBox(height: 10.h),
                    Divider(color: kOutline, height: 1),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          'COUNT',
                          style: GoogleFonts.ibmPlexMono(
                            color: kSecondaryText,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${e.value}',
                          style: GoogleFonts.ibmPlexMono(
                            color: kPrimaryText,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'PORTION',
                          style: GoogleFonts.ibmPlexMono(
                            color: kSecondaryText,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${(frac * 100).toStringAsFixed(1)}%',
                          style: GoogleFonts.ibmPlexMono(
                            color: color,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _recentList(List<ThermalInstrumentModel> items, List<ThermalInstrumentModel> all) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline, width: 1),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          final band = bandForTemperature(e.maxTemperature);
          final bandColor = classificationColor(band);
          final isLast = i == items.length - 1;
          final dateStr = _formatDate(e.dateAdded);
          final globalIdx = all.indexWhere((x) => x.id == e.id);
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
            child: GestureDetector(
              onTap: globalIdx >= 0
                  ? () => Navigator.pushNamed(
                        context,
                        '/info_screen',
                        arguments: {'index': globalIdx},
                      )
                  : null,
              child: Row(
                children: [
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: bandColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(kRadiusSubtle),
                      border: Border.all(color: bandColor.withAlpha(60), width: 1),
                    ),
                    child: Center(
                      child: Text(
                        e.temperatureUnit,
                        style: GoogleFonts.ibmPlexMono(
                          color: bandColor,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.makerDisplay,
                          style: GoogleFonts.ibmPlexSans(
                            color: kPrimaryText,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${e.minTemperature}${e.temperatureUnit} – ${e.maxTemperature}${e.temperatureUnit}',
                          style: GoogleFonts.ibmPlexMono(
                            color: kSecondaryText,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: kSecondaryText.withAlpha(100),
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    dateStr,
                    style: GoogleFonts.ibmPlexMono(
                      color: kSecondaryText.withAlpha(150),
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_outlined, size: 48.sp, color: kOutline),
          SizedBox(height: 16.h),
          Text(
            'NO DATA YET.',
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Log instruments to see metrics here.',
            style: GoogleFonts.ibmPlexSans(
              color: kSecondaryText.withAlpha(140),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
