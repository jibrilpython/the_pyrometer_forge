import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_pyrometer_forge/screens/home_screen.dart';
import 'package:the_pyrometer_forge/screens/stats_screen.dart';
import 'package:the_pyrometer_forge/screens/showcase_screen.dart';
import 'package:the_pyrometer_forge/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animController;

  final List<Widget> _screens = const [
    HomeScreen(),
    StatsScreen(),
    ShowcaseScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _setIndex(int i) {
    if (i == _currentIndex) return;
    setState(() => _currentIndex = i);
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildNav() {
    return Container(
      height: 68.h,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16.h,
        left: 20.w,
        right: 20.w,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: kOutline, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildNavItem(0, Icons.local_fire_department_outlined,
              Icons.local_fire_department, 'Forge'),
          _buildNavItem(1, Icons.insights_outlined, Icons.insights, 'Logbook'),
          _buildNavItem(2, Icons.explore_outlined, Icons.explore, 'Foundry'),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    final activeColor = index == 2
        ? const Color(0xFF8B1A0A) // cherry red for Foundry
        : kAccent;
    return GestureDetector(
      onTap: () => _setIndex(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 50.h,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 20.w : 16.w),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(kRadiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? kPrimaryText : kSecondaryText,
              size: 22.sp,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: Container(
                constraints: isSelected
                    ? null
                    : const BoxConstraints(maxWidth: 0),
                child: ClipRect(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 8.w),
                      Text(
                        label,
                        style: GoogleFonts.ibmPlexSans(
                          color: kPrimaryText,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
