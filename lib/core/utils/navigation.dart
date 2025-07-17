import 'package:absensi_mobile/core/router.dart';
import 'package:absensi_mobile/feature/home/presentation/screen/home.screen.dart';
import 'package:absensi_mobile/feature/profile/presentation/screen/profile.screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationPage extends StatefulWidget {
  final dynamic data;
  const NavigationPage({super.key, this.data});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _loadSelectedIndex();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _loadSelectedIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('last_selected_index') ?? 0;
    });
  }

  _saveSelectedIndex(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('last_selected_index', index);
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      router.push("/absenmapzone");
    } else {
      setState(() => _selectedIndex = index);
      _saveSelectedIndex(index);
    }
  }

  void _onCenterButtonTapped() {
    router.push("/absenmapzone");
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SlideTransition(
        position: _slideAnimation,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          extendBody: true,
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              IndexedStack(
                index: _selectedIndex,
                children: const [
                  HomeScreen(),

                  Text("Jadwal Pelajaran"),
                  Text("mapzoneabsesni"),
                  Text("Riwayat Absensi"),

                  ProfileScreen(),
                ],
              ),

              Positioned(
                bottom: 0,
                left: 0,
                child: SizedBox(
                  width: size.width,
                  height: 65,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomPaint(
                        size: Size(size.width, 65),
                        painter: CustomBottomNavPainter(
                          backgroundColor: const Color(0xFF0D47A1),
                        ),
                      ),

                      Center(
                        heightFactor: 0.5,
                        child: GestureDetector(
                          onTap: _onCenterButtonTapped,
                          child: Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.scan,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Absen",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        width: size.width,
                        height: 65,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNavItem(
                              icon: Iconsax.home_2,
                              label: 'Beranda',
                              index: 0,
                            ),
                            _buildNavItem(
                              icon: Iconsax.calendar,
                              label: 'Jadwal',
                              index: 1,
                            ),

                            SizedBox(width: size.width * 0.20),
                            _buildNavItem(
                              icon: Iconsax.clock,
                              label: 'Riwayat',
                              index: 3,
                            ),
                            _buildNavItem(
                              icon: Iconsax.user,
                              label: 'Profil',
                              index: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: isSelected ? 26 : 24,
                color:
                    isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.6),
                  fontSize: isSelected ? 14 : 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomBottomNavPainter extends CustomPainter {
  final Color backgroundColor;

  CustomBottomNavPainter({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

    Path path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width * 0.35, 0);

    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 15);

    path.arcToPoint(
      Offset(size.width * 0.60, 15),
      radius: const Radius.circular(17.0),
      clockwise: false,
    );

    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class SimpleNavigationPage extends StatefulWidget {
  final dynamic data;
  const SimpleNavigationPage({super.key, this.data});

  @override
  State<SimpleNavigationPage> createState() => _SimpleNavigationPageState();
}

class _SimpleNavigationPageState extends State<SimpleNavigationPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: const [
              HomeScreen(),

              Text("Jadwal Pelajaran"),

              Text("Riwayat Absensi"),

              Text("Profil Siswa"),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            child: SizedBox(
              width: size.width,
              height: 60,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: Size(size.width, 60),
                    painter: PreciseBottomNavPainter(
                      backgroundColor: const Color(0xFF0D47A1),
                    ),
                  ),

                  Center(
                    heightFactor: 0.7,
                    child: GestureDetector(
                      onTap: () => router.push("/absensi"),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.scan, color: Colors.white, size: 22),
                            Text(
                              "Absen",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: size.width,
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _simpleNavItem(Iconsax.home_2, 'Beranda', 0),
                        _simpleNavItem(Iconsax.calendar, 'Jadwal', 1),
                        SizedBox(width: size.width * 0.15),
                        _simpleNavItem(Iconsax.clock, 'Riwayat', 2),
                        _simpleNavItem(Iconsax.user, 'Profil', 3),
                      ],
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

  Widget _simpleNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSelected ? 22 : 18,
              color:
                  isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PreciseBottomNavPainter extends CustomPainter {
  final Color backgroundColor;

  PreciseBottomNavPainter({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

    Path path = Path();

    final double centerX = size.width * 0.5;
    final double notchRadius = 30.0;
    final double notchMargin = 4.0;

    path.moveTo(0, 15);

    path.quadraticBezierTo(size.width * 0.15, 0, size.width * 0.35, 0);

    path.quadraticBezierTo(
      centerX - notchRadius - notchMargin,
      0,
      centerX - notchRadius - notchMargin,
      12,
    );

    path.arcToPoint(
      Offset(centerX + notchRadius + notchMargin, 12),
      radius: Radius.circular(notchRadius + notchMargin),
      clockwise: false,
    );

    path.quadraticBezierTo(
      centerX + notchRadius + notchMargin,
      0,
      size.width * 0.65,
      0,
    );

    path.quadraticBezierTo(size.width * 0.85, 0, size.width, 15);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 15);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
