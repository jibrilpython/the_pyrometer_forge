import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_pyrometer_forge/providers/image_provider.dart';
import 'package:the_pyrometer_forge/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

void photoBottomSheet(
  BuildContext context,
  ImageNotifier imageProv,
  int index,
  WidgetRef ref,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _PhotoBottomSheetContent(imageProv: imageProv),
  );
}

class _PhotoBottomSheetContent extends StatelessWidget {
  final ImageNotifier imageProv;
  const _PhotoBottomSheetContent({required this.imageProv});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusMedium)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(top: 14.h),
            child: Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: kOutline,
                  borderRadius: BorderRadius.circular(kRadiusPill),
                ),
              ),
            ),
          ),

          // ── Header card ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
            child: Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.circular(kRadiusMedium),
                border: Border.all(color: kAccent.withAlpha(60)),
              ),
              child: Row(
                children: [
                  // Glowing camera icon
                  Container(
                    width: 54.w,
                    height: 54.w,
                    decoration: BoxDecoration(
                      color: kAccentSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: kAccent.withAlpha(100)),
                      boxShadow: [
                        BoxShadow(
                          color: kAccent.withAlpha(45),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: kAccent,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VISUAL RECORD',
                          style: GoogleFonts.ibmPlexMono(
                            color: kAccent,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'Instrument Photograph',
                          style: GoogleFonts.bebasNeue(
                            color: kPrimaryText,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Document optical head, scale face & maker markings',
                          style: GoogleFonts.ibmPlexSans(
                            color: kSecondaryText,
                            fontSize: 11.sp,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Options ──────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
            child: Column(
              children: [
                _buildOption(
                  context,
                  icon: Icons.camera_alt_outlined,
                  badgeIcon: Icons.flash_on_rounded,
                  label: 'TAKE PHOTOGRAPH',
                  sublabel: 'Document the instrument live using your camera',
                  source: ImageSource.camera,
                  accentColor: kAccent,
                  surfaceColor: kAccentSurface,
                ),
                SizedBox(height: 10.h),
                _buildOption(
                  context,
                  icon: Icons.photo_library_outlined,
                  badgeIcon: Icons.collections_rounded,
                  label: 'SELECT FROM LIBRARY',
                  sublabel: 'Choose an existing archive photograph',
                  source: ImageSource.gallery,
                  accentColor: kGold,
                  surfaceColor: kGoldSurface,
                ),
              ],
            ),
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required IconData badgeIcon,
    required String label,
    required String sublabel,
    required ImageSource source,
    required Color accentColor,
    required Color surfaceColor,
  }) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        await imageProv.pickImage(source: source);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: kBackground,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline, width: 1),
        ),
        child: Row(
          children: [
            // Icon with badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(kRadiusSubtle),
                    border: Border.all(
                      color: accentColor.withAlpha(70),
                    ),
                  ),
                  child: Icon(icon, color: accentColor, size: 22.sp),
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    width: 18.w,
                    height: 18.w,
                    decoration: BoxDecoration(
                      color: kPanelBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor.withAlpha(80)),
                    ),
                    child: Icon(badgeIcon, color: accentColor, size: 9.sp),
                  ),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            // Label + sub-label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.ibmPlexMono(
                      color: kPrimaryText,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    sublabel,
                    style: GoogleFonts.ibmPlexSans(
                      color: kSecondaryText,
                      fontSize: 11.sp,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow button
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: kPanelBg,
                shape: BoxShape.circle,
                border: Border.all(color: kOutline),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: kSecondaryText,
                size: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
