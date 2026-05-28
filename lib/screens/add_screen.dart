import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_pyrometer_forge/common/photo_bottom_sheet.dart';
import 'package:the_pyrometer_forge/enum/my_enums.dart';
import 'package:the_pyrometer_forge/providers/image_provider.dart';
import 'package:the_pyrometer_forge/providers/input_provider.dart';
import 'package:the_pyrometer_forge/providers/project_provider.dart';
import 'package:the_pyrometer_forge/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class AddScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int currentIndex;
  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  late PageController _pageCtrl;
  int _currentPage = 0;

  late TextEditingController _hashCtrl;
  late TextEditingController _makerCustomCtrl;
  late TextEditingController _wavebandCtrl;
  late TextEditingController _expansionCtrl;
  late TextEditingController _deformationCtrl;
  late TextEditingController _impedanceCtrl;
  late TextEditingController _enclosureCtrl;
  late TextEditingController _massCtrl;
  late TextEditingController _provenanceCustomCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _tagsCtrl;

  static const _pageTitles = [
    'Identity',
    'Thermal Specs',
    'Physical',
    'Provenance',
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    final p = ref.read(inputProvider);
    _hashCtrl = TextEditingController(text: p.thermalRegistryHash);
    _makerCustomCtrl = TextEditingController(text: p.makerCustom);
    _wavebandCtrl = TextEditingController(text: p.opticalWavebandFilter);
    _expansionCtrl =
        TextEditingController(text: p.expansionCoefficientVariables);
    _deformationCtrl = TextEditingController(text: p.deformationEndpointScale);
    _impedanceCtrl = TextEditingController(text: p.auxiliaryPowerImpedance);
    _enclosureCtrl = TextEditingController(text: p.enclosureVolumetrics);
    _massCtrl = TextEditingController(text: p.mass);
    _provenanceCustomCtrl =
        TextEditingController(text: p.foundryProvenanceCustom);
    _notesCtrl = TextEditingController(text: p.notes);
    _tagsCtrl = TextEditingController(text: p.tags.join(', '));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final c in [
      _hashCtrl,
      _makerCustomCtrl,
      _wavebandCtrl,
      _expansionCtrl,
      _deformationCtrl,
      _impedanceCtrl,
      _enclosureCtrl,
      _massCtrl,
      _provenanceCustomCtrl,
      _notesCtrl,
      _tagsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() async {
    final p = ref.read(inputProvider);
    if (p.thermalRegistryHash.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Thermal Registry Hash is required to archive.',
            style: GoogleFonts.ibmPlexSans(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: kError,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusSubtle),
          ),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ForgingDialog(),
    );
    await Future.delayed(const Duration(milliseconds: 900));
    if (widget.isEdit) {
      ref.read(projectProvider).editEntry(ref, widget.currentIndex);
    } else {
      ref.read(projectProvider).addEntry(ref);
    }
    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
      ref.read(inputProvider).clearAll();
      ref.read(imageProvider).clearImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        leadingWidth: 68.w,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: kPanelBg,
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                  border: Border.all(color: kOutline, width: 1),
                ),
                child:
                    Icon(Icons.close, color: kPrimaryText, size: 20.sp),
              ),
            ),
          ),
        ),
        title: Text(
          widget.isEdit ? 'Edit Instrument' : 'Record Instrument',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: kPrimaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _buildStepperBar(),
                SizedBox(height: 8.h),
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildPage1Identity(),
                      _buildPage2ThermalSpecs(),
                      _buildPage3Physical(),
                      _buildPage4Provenance(),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
                left: 0, right: 0, bottom: 0, child: _buildBottomNav()),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
      child: Row(
        children: List.generate(_pageTitles.length, (i) {
          final isActive = i == _currentPage;
          final isDone = i < _currentPage;
          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(right: i < _pageTitles.length - 1 ? 6.w : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: isActive
                          ? kAccent
                          : isDone
                              ? kAccent.withAlpha(60)
                              : kOutline,
                      borderRadius: BorderRadius.circular(kRadiusPill),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _pageTitles[i],
                    style: GoogleFonts.ibmPlexSans(
                      color: isActive
                          ? kAccent
                          : isDone
                              ? kSecondaryText
                              : kOutline,
                      fontSize: 10.sp,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPage1Identity() {
    final p = ref.watch(inputProvider);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPhotoSection(),
          SizedBox(height: 20.h),
          _sectionHeader('01 — IDENTIFICATION', Icons.fingerprint),
          SizedBox(height: 16.h),
          _field(
            label: 'THERMAL REGISTRY HASH',
            ctrl: _hashCtrl,
            hint:
                'e.g. TPF-LN-DISAPPEAR-1934-PA-4492',
            onChanged: (v) => p.thermalRegistryHash = v,
          ),
          SizedBox(height: 14.h),
          _subLabel('PYROMETRIC CLASSIFICATION'),
          SizedBox(height: 8.h),
          _enumChips<PyrometricClassification>(
            values: PyrometricClassification.values,
            current: p.pyrometricClassification,
            onSelected: (v) => ref.read(inputProvider).pyrometricClassification = v,
            label: (v) => v.label,
            color: (v) => getClassificationColor(v),
          ),
          SizedBox(height: 20.h),
          _field(
            label: 'CUSTOM MAKER NAME',
            ctrl: _makerCustomCtrl,
            hint: 'e.g. Custom Instrument Works',
            onChanged: (v) => p.makerCustom = v,
          ),
        ],
      ),
    );
  }

  Widget _buildPage2ThermalSpecs() {
    final p = ref.watch(inputProvider);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('02 — THERMAL SPECIFICATIONS',
              Icons.thermostat_outlined),
          SizedBox(height: 16.h),
          _subLabel('CALIBRATED TEMPERATURE BOUNDS'),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(child: _subLabel('MIN')),
              SizedBox(width: 32.w),
              Expanded(child: _subLabel('MAX')),
              SizedBox(width: 8.w),
              SizedBox(width: 48.w),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: _tempInput(
                  value: p.minTemperature,
                  onChanged: (v) => p.minTemperature = v,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child:
                    Icon(Icons.arrow_forward, color: kSecondaryText, size: 16.sp),
              ),
              Expanded(
                child: _tempInput(
                  value: p.maxTemperature,
                  onChanged: (v) => p.maxTemperature = v,
                ),
              ),
              SizedBox(width: 8.w),
              _unitToggle(p),
            ],
          ),
          SizedBox(height: 20.h),
          _subLabel('TARGET MATERIAL EMISSIVITY FACTOR (E)'),
          SizedBox(height: 8.h),
          _enumChips<EmissivityFactor>(
            values: EmissivityFactor.values,
            current: p.emissivityFactor,
            onSelected: (v) => ref.read(inputProvider).emissivityFactor = v,
            label: (v) => '${v.label} (${v.value})',
            color: (_) => kGold,
          ),
          SizedBox(height: 20.h),
          _subLabel('THERMOCOUPLE JUNCTION ALLOY'),
          SizedBox(height: 8.h),
          _enumChips<ThermocoupleAlloy>(
            values: ThermocoupleAlloy.values,
            current: p.thermocoupleAlloy,
            onSelected: (v) => ref.read(inputProvider).thermocoupleAlloy = v,
            label: (v) => v.label,
            color: (_) => kAccent,
          ),
          SizedBox(height: 20.h),
          _field(
            label: 'OPTICAL WAVEBAND FILTER (μm)',
            ctrl: _wavebandCtrl,
            hint: 'e.g. 0.65',
            onChanged: (v) => p.opticalWavebandFilter = v,
          ),
        ],
      ),
    );
  }

  Widget _buildPage3Physical() {
    final p = ref.watch(inputProvider);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('03 — PHYSICAL RECORD', Icons.build_outlined),
          SizedBox(height: 16.h),
          _field(
            label: 'EXPANSION COEFFICIENT VARIABLES',
            ctrl: _expansionCtrl,
            hint: 'e.g. Steel-to-Porcelain ratio, Graphite-rod metrics',
            maxLines: 2,
            onChanged: (v) => p.expansionCoefficientVariables = v,
          ),
          SizedBox(height: 14.h),
          _field(
            label: 'DEFORMATION ENDPOINT SCALE',
            ctrl: _deformationCtrl,
            hint: 'e.g. Orton Cone 06, ASTM bending angle',
            onChanged: (v) => p.deformationEndpointScale = v,
          ),
          SizedBox(height: 14.h),
          _field(
            label: 'AUXILIARY POWER & GALVANOMETER IMPEDANCE (Ω)',
            ctrl: _impedanceCtrl,
            hint: 'e.g. 1.5V Edison-Lalande cell, 50Ω',
            onChanged: (v) => p.auxiliaryPowerImpedance = v,
          ),
          SizedBox(height: 14.h),
          _field(
            label: 'ENCLOSURE VOLUMETRICS',
            ctrl: _enclosureCtrl,
            hint: 'e.g. 24 × 18 × 12 cm',
            onChanged: (v) => p.enclosureVolumetrics = v,
          ),
          SizedBox(height: 14.h),
          _field(
            label: 'PROBE ASSEMBLY MASS',
            ctrl: _massCtrl,
            hint: 'e.g. 2.4 kg',
            onChanged: (v) => p.mass = v,
          ),
          SizedBox(height: 20.h),
          _subLabel('OPTICAL INTEGRITY'),
          SizedBox(height: 8.h),
          _enumChips<OpticalIntegrity>(
            values: OpticalIntegrity.values,
            current: p.opticalIntegrity,
            onSelected: (v) => ref.read(inputProvider).opticalIntegrity = v,
            label: (v) => v.label,
            color: (v) => getOpticalIntegrityColor(v),
          ),
          SizedBox(height: 20.h),
          _subLabel('ELECTRICAL CONTINUITY'),
          SizedBox(height: 8.h),
          ...MechanicalContinuity.values.map((mc) {
            final isSel = p.electricalContinuity == mc;
            return GestureDetector(
              onTap: () =>
                  ref.read(inputProvider).electricalContinuity = mc,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 8.h),
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: isSel ? kAccentSurface : kPanelBg,
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                  border: Border.all(
                    color: isSel ? kAccent : kOutline,
                    width: isSel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSel
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_off,
                      color: isSel
                          ? kAccent
                          : kSecondaryText.withAlpha(100),
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      mc.label,
                      style: GoogleFonts.ibmPlexSans(
                        color: isSel ? kPrimaryText : kSecondaryText,
                        fontSize: 14.sp,
                        fontWeight:
                            isSel ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPage4Provenance() {
    final p = ref.watch(inputProvider);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('04 — ARCHIVAL RECORD', Icons.history_edu),
          SizedBox(height: 16.h),
          _field(
            label: 'CUSTOM FOUNDRY PROVENANCE',
            ctrl: _provenanceCustomCtrl,
            hint: 'e.g. Abandoned steel mill, Ohio',
            onChanged: (v) => p.foundryProvenanceCustom = v,
          ),
          SizedBox(height: 20.h),
          _field(
            label: 'ARCHIVAL NOTES',
            ctrl: _notesCtrl,
            hint:
                'e.g. Lenses pitted, original case intact. Calibrated at Homestead Steel Works in 1934.',
            maxLines: 4,
            onChanged: (v) => p.notes = v,
          ),
          SizedBox(height: 14.h),
          _field(
            label: 'TAGS (comma separated)',
            ctrl: _tagsCtrl,
            hint: 'optical, leeds-northrup, vanishing-filament, rare…',
            onChanged: (v) => p.tags = v
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    final imgPath = ref
        .watch(imageProvider)
        .getImagePath(ref.watch(imageProvider).resultImage);
    return GestureDetector(
      onTap: () => photoBottomSheet(context, ref.read(imageProvider), 0, ref),
      child: SizedBox(
        width: double.infinity,
        height: 220.h,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 220.h,
              decoration: BoxDecoration(
                color: kPanelBg,
                borderRadius: BorderRadius.circular(kRadiusMedium),
              ),
              clipBehavior: Clip.antiAlias,
              child: imgPath != null && File(imgPath).existsSync()
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(imgPath), fit: BoxFit.cover),
                        Positioned(
                          top: 12.h,
                          right: 12.w,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: const BoxDecoration(
                              color: Color(0xCC1A1918),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.edit,
                                size: 14.sp, color: kPrimaryText),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined,
                            color: kSecondaryText, size: 28.sp),
                        SizedBox(height: 10.h),
                        Text(
                          'Upload instrument photograph',
                          style: GoogleFonts.ibmPlexSans(
                            color: kSecondaryText,
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Optical head, scale face, and maker markings',
                          style: GoogleFonts.ibmPlexSans(
                            color: kSecondaryText.withAlpha(120),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(kRadiusMedium),
                    border: Border.all(color: kAccent, width: 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final p = ref.watch(inputProvider);
    final isLastPage = _currentPage == _pageTitles.length - 1;

    final isIdentityValid = p.thermalRegistryHash.trim().isNotEmpty;
    final canProceed = isLastPage || _currentPage != 0 || isIdentityValid;
    final useAccent = _currentPage == 0 ? isIdentityValid : true;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: kBackground.withAlpha(230),
        border: Border(top: BorderSide(color: kOutline.withAlpha(80))),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            GestureDetector(
              onTap: () => _pageCtrl.previousPage(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
              ),
              child: Container(
                height: 52.h,
                width: 52.h,
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  color: kPanelBg,
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                  border: Border.all(color: kOutline, width: 1),
                ),
                child: Icon(Icons.arrow_back_rounded,
                    color: kPrimaryText, size: 22.sp),
              ),
            ),
          Expanded(
            child: GestureDetector(
              onTap: canProceed
                  ? (isLastPage
                      ? _save
                      : () => _pageCtrl.nextPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                        ))
                  : null,
              child: Container(
                height: 52.h,
                decoration: BoxDecoration(
                  color: useAccent ? kAccent : kPanelBg,
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                  border: Border.all(color: useAccent ? kAccent : kOutline),
                  boxShadow: useAccent ? const [kShadowOrange] : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  isLastPage
                      ? (widget.isEdit
                            ? 'Update Archive Record'
                            : 'Commit to Archive')
                      : 'Continue',
                  style: GoogleFonts.ibmPlexSans(
                    color: useAccent ? kPrimaryText : kSecondaryText,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: kAccent),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.ibmPlexMono(
            color: kPrimaryText,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _subLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.ibmPlexMono(
        color: kSecondaryText,
        fontSize: 9.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController ctrl,
    required Function(String) onChanged,
    String? hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subLabel(label),
        SizedBox(height: 6.h),
        TextField(
          controller: ctrl,
          onChanged: onChanged,
          maxLines: maxLines,
          style: GoogleFonts.ibmPlexSans(
            color: kPrimaryText,
            fontSize: 14.sp,
            fontWeight: FontWeight.w300,
          ),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _tempInput({
    required int value,
    required Function(int) onChanged,
  }) {
    return TextField(
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(hintText: value.toString()),
      style: GoogleFonts.ibmPlexMono(
        color: kPrimaryText,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
      onChanged: (v) {
        final parsed = int.tryParse(v);
        if (parsed != null) onChanged(parsed);
      },
    );
  }

  Widget _unitToggle(InputNotifier p) {
    final isCelsius = p.temperatureUnit == '°C';
    return GestureDetector(
      onTap: () =>
          ref.read(inputProvider).temperatureUnit = isCelsius ? '°F' : '°C',
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isCelsius ? '°C' : '°F',
              style: GoogleFonts.ibmPlexMono(
                color: kAccent,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'tap',
              style: GoogleFonts.ibmPlexMono(
                color: kSecondaryText,
                fontSize: 7.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _enumChips<T>({
    required List<T> values,
    required T current,
    required void Function(T) onSelected,
    required String Function(T) label,
    required Color Function(T) color,
  }) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: values.map((v) {
        final isSel = v == current;
        final c = color(v);
        return GestureDetector(
          onTap: () => onSelected(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSel ? c : kPanelBg,
              borderRadius: BorderRadius.circular(kRadiusPill),
              border: Border.all(color: isSel ? c : kOutline, width: 1),
              boxShadow: isSel
                  ? [
                      BoxShadow(
                        color: c.withAlpha(60),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label(v),
              style: GoogleFonts.ibmPlexSans(
                color: isSel ? kPrimaryText : kSecondaryText,
                fontSize: 12.sp,
                fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ForgingDialog extends StatefulWidget {
  const _ForgingDialog();
  @override
  State<_ForgingDialog> createState() => _ForgingDialogState();
}

class _ForgingDialogState extends State<_ForgingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(36.w),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusMedium),
          border: Border.all(color: kOutline, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 100.w,
              height: 100.w,
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) => CustomPaint(
                  painter: _ForgeHeartPainter(progress: _ctrl.value),
                  child: Center(
                    child: Text(
                      '${(_ctrl.value * 1600).round()}°',
                      style: GoogleFonts.ibmPlexMono(
                        color: kPrimaryText,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'FORGING RECORD…',
              style: GoogleFonts.ibmPlexMono(
                color: kAccent,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Tempering thermal data',
              style: GoogleFonts.ibmPlexSans(
                color: kSecondaryText,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForgeHeartPainter extends CustomPainter {
  final double progress;
  _ForgeHeartPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.shortestSide / 2;

    // Outer heat rings
    for (int i = 0; i < 6; i++) {
      final phase = (progress + i / 6) % 1.0;
      final ringR = r * (0.3 + phase * 0.7);
      final alpha = ((1.0 - phase) * 60).round().clamp(0, 60);
      final paint = Paint()
        ..color = kAccent.withAlpha(alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 + (1.0 - phase) * 3;
      canvas.drawCircle(Offset(cx, cy), ringR, paint);
    }

    // Core glow
    final corePaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(cx, cy),
        r * 0.5,
        [
          kAccent.withAlpha((80 + (progress * 60).round()).clamp(0, 140)),
          kAccent.withAlpha(0),
        ],
        [0.0, 1.0],
      );
    canvas.drawCircle(Offset(cx, cy), r * 0.5, corePaint);

    // Center mark
    final centerPaint = Paint()
      ..color = kAccent.withAlpha((120 + (progress * 60).round()).clamp(0, 180))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 3, centerPaint);
  }

  @override
  bool shouldRepaint(_ForgeHeartPainter old) => old.progress != progress;
}
