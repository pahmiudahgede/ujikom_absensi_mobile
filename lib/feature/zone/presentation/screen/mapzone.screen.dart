// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapZoneScreen extends StatefulWidget {
  const MapZoneScreen({super.key});

  @override
  State<MapZoneScreen> createState() => MapZoneScreenState();
}

class MapZoneScreenState extends State<MapZoneScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> markers = {};
  Set<Circle> circles = {};

  late AnimationController _pulseController;
  late AnimationController _statusCardController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _statusCardAnimation;

  static const LatLng _schoolLocation = LatLng(
    -8.154751153192787,
    113.72263877743775,
  );

  static const double _safeZoneRadius = 90.0;

  bool _isInSafeZone = false;
  bool _isLoading = true;
  bool _showInfo = true;
  String _statusMessage = "Memuat lokasi...";
  double _distanceFromSchool = 0.0;

  static const Color _primaryGreen = Color(0xFF2E7D32);
  static const Color _lightGreen = Color(0xFF4CAF50);
  static const Color _accentGreen = Color(0xFF66BB6A);
  static const Color _errorRed = Color(0xFFD32F2F);
  static const Color _neutralGray = Color(0xFF757575);
  static const Color _backgroundGray = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeMap();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _statusCardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _statusCardAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _statusCardController, curve: Curves.elasticOut),
    );

    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    await _setupMapElements();
    _checkIfInSafeZone();
    _statusCardController.forward();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _statusMessage = "Izin lokasi ditolak";
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _statusMessage = "Izin lokasi ditolak permanen";
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen((Position position) {
        setState(() {
          _currentPosition = position;
        });
        _updateUserMarker();
        _checkIfInSafeZone();
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Gagal mendapatkan lokasi: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _setupMapElements() async {
    final schoolIcon = await _createCustomMarkerIcon(
      Icons.school,
      _primaryGreen,
      35.0,
    );

    markers.add(
      Marker(
        markerId: const MarkerId('school'),
        position: _schoolLocation,
        icon: schoolIcon,
        infoWindow: const InfoWindow(
          title: '🏫 Sekolah',
          snippet: 'Lokasi absensi',
        ),
      ),
    );

    circles.add(
      Circle(
        circleId: const CircleId('safe_zone'),
        center: _schoolLocation,
        radius: _safeZoneRadius,
        fillColor: _lightGreen.withValues(alpha:0.2),
        strokeColor: _primaryGreen,
        strokeWidth: 3,
      ),
    );

    await _updateUserMarker();
  }

  Future<void> _updateUserMarker() async {
    if (_currentPosition == null) return;

    final studentIcon = await _createCustomMarkerIcon(
      Icons.person,
      _isInSafeZone ? _lightGreen : _errorRed,
      35.0,
    );

    markers.removeWhere((marker) => marker.markerId.value == 'user');
    markers.add(
      Marker(
        markerId: const MarkerId('user'),
        position: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        icon: studentIcon,
        infoWindow: InfoWindow(
          title: '👨‍🎓 Lokasi Anda',
          snippet:
              _isInSafeZone
                  ? 'Dalam zona aman (${_distanceFromSchool.toInt()}m)'
                  : 'Di luar zona aman (${_distanceFromSchool.toInt()}m)',
        ),
      ),
    );

    setState(() {});
  }

  void _checkIfInSafeZone() {
    if (_currentPosition == null) return;

    double distance = Geolocator.distanceBetween(
      _schoolLocation.latitude,
      _schoolLocation.longitude,
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    bool wasInSafeZone = _isInSafeZone;
    _isInSafeZone = distance <= _safeZoneRadius;
    _distanceFromSchool = distance;

    if (wasInSafeZone != _isInSafeZone) {
      _updateUserMarker();
      if (_isInSafeZone) {
        _showSuccessSnackBar();
      }
      setState(() {
        _statusMessage =
            _isInSafeZone
                ? "Anda berada dalam zona aman"
                : "Anda berada di luar zona aman";
      });
    }
  }

  Future<BitmapDescriptor> _createCustomMarkerIcon(
    IconData iconData,
    Color color,
    double size,
  ) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = color;
    final radius = size / 2;

    canvas.drawCircle(Offset(radius, radius), radius, paint);

    final borderPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
    canvas.drawCircle(Offset(radius, radius), radius - 1.5, borderPaint);

    TextPainter textPainter = TextPainter(textDirection: TextDirection.rtl);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size * 0.5,
        fontFamily: iconData.fontFamily,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Selamat! Anda sudah masuk zona aman'),
          ],
        ),
        backgroundColor: _primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_schoolLocation, 16.0),
    );
  }

  void _centerOnSchool() {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_schoolLocation, 17.0),
    );
  }

  void _centerOnUser() {
    if (_currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          18.0,
        ),
      );
    }
  }

  Widget _buildStatusCard() {
    return SlideTransition(
      position: _statusCardAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          elevation: 8,
          shadowColor:
              _isInSafeZone
                  ? _lightGreen.withValues(alpha:0.3)
                  : _errorRed.withValues(alpha:0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              border: Border.all(
                color: _isInSafeZone ? _lightGreen : _errorRed,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isInSafeZone ? _pulseAnimation.value : 1.0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isInSafeZone ? _lightGreen : _errorRed,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isInSafeZone ? _lightGreen : _errorRed)
                                  .withValues(alpha:0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isInSafeZone
                              ? Icons.check_circle_outline
                              : Icons.warning_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isInSafeZone ? 'Dalam Zona Aman' : 'Di Luar Zona Aman',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isInSafeZone ? _primaryGreen : _errorRed,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Jarak: ${_distanceFromSchool.toInt()}m dari sekolah',
                        style: const TextStyle(
                          color: Color(0xFF424242),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _statusMessage,
                        style: TextStyle(color: _neutralGray, fontSize: 13),
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

  Widget _buildInfoCard() {
    return AnimatedSlide(
      offset: _showInfo ? Offset.zero : const Offset(-1.5, 0),
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(left: 16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Informasi Zona',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF212121),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _showInfo = !_showInfo),
                      child: Icon(
                        _showInfo ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                        color: _neutralGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _lightGreen.withValues(alpha:0.3),
                        border: Border.all(color: _primaryGreen, width: 2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Zona Aman (0-200m)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF424242),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Anda dapat melakukan absensi hanya di dalam zona hijau',
                  style: TextStyle(fontSize: 11, color: _neutralGray),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "toggle_info",
          onPressed: () => setState(() => _showInfo = !_showInfo),
          backgroundColor: _accentGreen,
          elevation: 6,
          child: Icon(
            _showInfo ? Icons.info : Icons.info_outline,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: "center_school",
          onPressed: _centerOnSchool,
          backgroundColor: _primaryGreen,
          elevation: 6,
          child: const Icon(Icons.school, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: "center_user",
          onPressed: _centerOnUser,
          backgroundColor: _lightGreen,
          elevation: 6,
          child: const Icon(Icons.my_location, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildAbsenButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: ElevatedButton(
          onPressed:
              _isInSafeZone
                  ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Text('Absensi berhasil dicatat!'),
                          ],
                        ),
                        backgroundColor: _primaryGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isInSafeZone ? _lightGreen : _neutralGray,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: _isInSafeZone ? 8 : 2,
            shadowColor: _isInSafeZone ? _lightGreen.withValues(alpha:0.3) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_isInSafeZone ? Icons.fingerprint : Icons.block, size: 24),
              const SizedBox(width: 12),
              Text(
                _isInSafeZone ? 'ABSEN SEKARANG' : 'TIDAK DAPAT ABSEN',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Zona Absensi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _initializeMap,
            tooltip: 'Refresh lokasi',
          ),
        ],
      ),
      body:
          _isLoading
              ? Container(
                decoration: const BoxDecoration(color: _backgroundGray),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _primaryGreen,
                        ),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Memuat peta dan lokasi...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF424242),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Mohon tunggu sebentar',
                        style: TextStyle(color: _neutralGray, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
              : Stack(
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: const CameraPosition(
                      target: _schoolLocation,
                      zoom: 16.0,
                    ),
                    markers: markers,
                    circles: circles,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                    compassEnabled: true,
                    zoomControlsEnabled: false,
                  ),

                  Positioned(
                    top: 100,
                    left: 0,
                    right: 0,
                    child: _buildStatusCard(),
                  ),

                  Positioned(bottom: 120, left: 0, child: _buildInfoCard()),

                  Positioned(
                    bottom: 120,
                    right: 16,
                    child: _buildFloatingButtons(),
                  ),
                ],
              ),
      bottomNavigationBar: _buildAbsenButton(),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _statusCardController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
