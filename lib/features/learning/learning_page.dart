import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:quran_tracker/core/models/attendance_model.dart';
import 'package:quran_tracker/features/learning/data/learning_service.dart';
import 'package:quran_tracker/features/learning/data/service_locator.dart';
import 'package:quran_tracker/features/learning/widget/widget_helper.dart';
import 'package:quran_tracker/features/shimmer_loading_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  final LearningService _service = sl.learningService;

  bool _isLoading = true;
  bool _hasAttended = false;
  AttendanceModel? _attendance;
  OfficeLocation? _officeLocation;
  String _dateFormatted = '';

  bool _isSubmitting = false;
  bool _isCheckingLocation = false;
  Position? _currentPosition;
  double? _distance;
  bool? _inRange;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isLoading) {
        _refreshData();
      }
    });
  }

  Future<void> _initializePage() async {
    await _loadAttendanceStatus();
    if (!_hasAttended) {
      await _getCurrentLocation();
    }
  }

  Future<void> _refreshData() async {
    try {
      final response = await _service.getAttendanceStatus();

      if (response['success'] == true && mounted) {
        final data = response['data'];

        setState(() {
          _hasAttended = data['has_attended'] ?? false;
          _dateFormatted = data['date_formatted'] ?? '';

          if (data['attendance'] != null) {
            _attendance = AttendanceModel.fromJson(data['attendance']);
          }

          if (data['office_location'] != null) {
            _officeLocation = OfficeLocation.fromJson(data['office_location']);
          }
        });

        if (!_hasAttended && _currentPosition == null) {
          _getCurrentLocation();
        }
      }
    } catch (e) {}
  }

  Future<void> _loadAttendanceStatus() async {
    setState(() => _isLoading = true);

    try {
      final response = await _service.getAttendanceStatus();

      if (response['success'] == true) {
        final data = response['data'];

        setState(() {
          _hasAttended = data['has_attended'] ?? false;
          _dateFormatted = data['date_formatted'] ?? '';

          if (data['attendance'] != null) {
            _attendance = AttendanceModel.fromJson(data['attendance']);
          }

          if (data['office_location'] != null) {
            _officeLocation = OfficeLocation.fromJson(data['office_location']);
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);

      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      if (errorMessage.contains('Sesi habis') ||
          errorMessage.contains('Token tidak ditemukan') ||
          errorMessage.contains('Unauthenticated')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Sesi Berakhir'),
              content: const Text(
                  'Sesi Anda telah berakhir. Silakan login kembali.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          );
        }
      } else {
        _showError('Gagal memuat data: $errorMessage');
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    ShimmerLoadingDialog.show(context, message: 'Mendapatkan lokasi...');

    setState(() => _isCheckingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) ShimmerLoadingDialog.hide(context);
        setState(() => _isCheckingLocation = false);
        _showError('GPS tidak aktif. Silakan aktifkan GPS.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) ShimmerLoadingDialog.hide(context);
          setState(() => _isCheckingLocation = false);
          _showError('Izin lokasi ditolak');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) ShimmerLoadingDialog.hide(context);
        setState(() => _isCheckingLocation = false);
        _showError('Izin lokasi ditolak permanen. Aktifkan di pengaturan.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() => _currentPosition = position);
      await _checkIfInRange(position.latitude, position.longitude);

      if (mounted) ShimmerLoadingDialog.hide(context);
    } catch (e) {
      if (mounted) ShimmerLoadingDialog.hide(context);
      setState(() => _isCheckingLocation = false);
      _showError('Gagal mendapatkan lokasi: $e');
    } finally {
      setState(() => _isCheckingLocation = false);
    }
  }

  Future<void> _submitAttendance() async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
      if (_currentPosition == null) return;
    }

    if (_inRange == false) {
      _showError(
          'Anda berada di luar jangkauan. Jarak: ${_distance?.toStringAsFixed(0)} meter dari lokasi kantor.');
      return;
    }

    if (!mounted) return;

    ShimmerLoadingDialog.show(context, message: 'Mengirim absensi...');

    setState(() => _isSubmitting = true);

    try {
      final response = await _service.submitAttendance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (mounted) ShimmerLoadingDialog.hide(context);

      if (response['success'] == true) {
        _showSuccess(response['message'] ?? 'Absensi berhasil!');
        await _loadAttendanceStatus();
      } else {
        _showError(response['message'] ?? 'Gagal melakukan absensi');
      }
    } catch (e) {
      if (mounted) ShimmerLoadingDialog.hide(context);

      String errorMessage = e.toString();

      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      _showError(errorMessage);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _checkIfInRange(double lat, double lng) async {
    try {
      final response = await _service.checkLocation(lat, lng);

      if (response['success'] == true) {
        final data = response['data'];

        setState(() {
          _inRange = data['in_range'] ?? false;
          _distance = data['distance']?.toDouble() ?? 0;
        });
      } else {
        setState(() {
          _inRange = false;
          _distance = null;
        });
        _showError(response['message'] ?? 'Gagal mengecek lokasi');
      }
    } catch (e) {
      setState(() {
        _inRange = null;
        _distance = null;
      });

      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      _showError(errorMessage);
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature akan segera hadir!'),
        backgroundColor: const Color(0xFF5D4037),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: _isLoading
            ? Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF3E2723),
                      Color(0xFF4A3428),
                      Color(0xFF5D4037),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: ShimmerLoadingDialog(
                    message: 'Memuat pembelajaran...',
                  ),
                ),
              )
            : Stack(
                children: [
                  /// BACKGROUND
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF3E2723),
                            Color(0xFF4A3428),
                            Color(0xFF5D4037),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          CustomPaint(
                            painter: LearningBackgroundPainter(),
                            size: Size(
                              double.infinity,
                              MediaQuery.of(context).size.height * 0.35,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// CONTENT
                  SafeArea(
                    child: Column(
                      children: [
                        /// Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pembelajaran',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tingkatkan pemahaman Al-Quran',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Stats Cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  icon: '📅',
                                  label: 'Hari Ini',
                                  value: DateTime.now().day.toString(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  icon: _hasAttended ? '✅' : '❌',
                                  label: 'Status',
                                  value: _hasAttended ? 'Hadir' : 'Belum',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  icon: '📍',
                                  label: 'Radius',
                                  value: '${_officeLocation?.radius ?? 100}m',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// Content Area
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                            ),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Attendance Card
                                  _buildAttendanceCard(),
                                  const SizedBox(height: 28),

                                  /// Categories Title
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF6D4C41),
                                              Color(0xFF5D4037)
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF5D4037)
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.school_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Kategori Pembelajaran',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF3E2723),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  /// Categories Grid
                                  _buildCategoriesGrid(),
                                ],
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
    );
  }

  Widget _buildAttendanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _hasAttended
              ? [Colors.white.withOpacity(0.25), Colors.white.withOpacity(0.15)]
              : [const Color(0xFF6D4C41), const Color(0xFF5D4037)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _hasAttended
              ? const Color(0xFF10b981).withOpacity(0.3)
              : Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _hasAttended
                ? const Color(0xFF10b981).withOpacity(0.2)
                : Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _hasAttended
                      ? const Color(0xFF10b981).withOpacity(0.2)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _hasAttended ? '✅' : '🕘',
                  style: const TextStyle(fontSize: 40),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasAttended ? 'Absensi Berhasil!' : 'Absensi Hari Ini',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _hasAttended
                            ? const Color(0xFF10b981)
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dateFormatted,
                      style: TextStyle(
                        fontSize: 13,
                        color: _hasAttended
                            ? Colors.black54
                            : Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_hasAttended && _attendance != null) ...[
            const SizedBox(height: 20),
            _buildAttendanceInfo(),
          ] else ...[
            const SizedBox(height: 20),
            _buildAttendanceButton(),
          ],
          const SizedBox(height: 16),
          _buildGpsHint(),
        ],
      ),
    );
  }

  Widget _buildAttendanceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          InfoRow(
            icon: '⏰',
            label: 'Waktu Absen',
            value: _attendance!.time ?? '-',
          ),
          const Divider(height: 24),
          InfoRow(
            icon: '📍',
            label: 'Latitude',
            value: _attendance!.latitude?.toStringAsFixed(6) ?? '-',
          ),
          const Divider(height: 24),
          InfoRow(
            icon: '📍',
            label: 'Longitude',
            value: _attendance!.longitude?.toStringAsFixed(6) ?? '-',
          ),
          const Divider(height: 24),
          const InfoRow(
            icon: '🎯',
            label: 'Status',
            value: 'Hadir',
            valueColor: Color(0xFF10b981),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceButton() {
    final isOutOfRange = _inRange == false;
    final isCheckingOrSubmitting = _isCheckingLocation || _isSubmitting;
    final shouldDisable = isCheckingOrSubmitting || isOutOfRange;

    return Column(
      children: [
        if (!_isCheckingLocation &&
            _currentPosition != null &&
            _inRange != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _inRange!
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _inRange!
                    ? Colors.green.withOpacity(0.5)
                    : Colors.red.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _inRange! ? Icons.check_circle : Icons.error,
                  color: _inRange! ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _inRange!
                            ? 'Anda dalam jangkauan'
                            : 'Anda di luar jangkauan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _inRange! ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        'Jarak: ${_distance?.toStringAsFixed(0) ?? 0} meter',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Container(
          decoration: BoxDecoration(
            gradient: shouldDisable
                ? null
                : LinearGradient(
                    colors: [
                      Colors.amber.shade300,
                      Colors.amber.shade400,
                    ],
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: shouldDisable
                ? []
                : [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: shouldDisable ? null : _submitAttendance,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  shouldDisable ? Colors.grey.shade400 : Colors.transparent,
              foregroundColor: shouldDisable
                  ? Colors.grey.shade600
                  : const Color(0xFF5D4037),
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(double.infinity, 56),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isOutOfRange
                      ? Icons.location_off_rounded
                      : Icons.location_on_rounded,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isOutOfRange ? 'Diluar Jangkauan' : 'Absen Sekarang',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGpsHint() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _hasAttended
            ? Colors.green.withOpacity(0.2)
            : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _hasAttended
              ? Colors.green.withOpacity(0.3)
              : Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            _hasAttended ? '💡' : '⚠️',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _hasAttended
                  ? 'Lokasi absensi telah tersimpan dengan aman'
                  : 'Pastikan GPS aktif dan izinkan akses lokasi',
              style: TextStyle(
                fontSize: 12,
                color: _hasAttended ? Colors.green.shade900 : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.0,
      padding: EdgeInsets.zero,
      children: [
        LearningCategoryCard(
          title: 'Tajwid',
          icon: Icons.book_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF6D4C41), Color(0xFF5D4037)],
          ),
          onTap: () => _showComingSoon(context, 'Tajwid'),
        ),
        LearningCategoryCard(
          title: 'Tafsir',
          icon: Icons.import_contacts_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF7B5E57), Color(0xFF6D4C41)],
          ),
          onTap: () => _showComingSoon(context, 'Tafsir'),
        ),
        LearningCategoryCard(
          title: 'Hadits',
          icon: Icons.menu_book_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF8D6E63), Color(0xFF7B5E57)],
          ),
          onTap: () => _showComingSoon(context, 'Hadits'),
        ),
        LearningCategoryCard(
          title: 'Doa Harian',
          icon: Icons.favorite_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFFa1887f), Color(0xFF8D6E63)],
          ),
          onTap: () => _showComingSoon(context, 'Doa Harian'),
        ),
        LearningCategoryCard(
          title: 'Bahasa Arab',
          icon: Icons.language_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF6D4C41), Color(0xFF8D6E63)],
          ),
          onTap: () => _showComingSoon(context, 'Bahasa Arab'),
        ),
        LearningCategoryCard(
          title: 'Video Tutorial',
          icon: Icons.play_circle_filled_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF7B5E57), Color(0xFFa1887f)],
          ),
          onTap: () => _showComingSoon(context, 'Video Tutorial'),
        ),
      ],
    );
  }
}

/// LEARNING BACKGROUND PAINTER
class LearningBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Decorative circles
    final paint1 = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.8, -50), 150, paint1);
    canvas.drawCircle(Offset(-100, size.height * 0.5), 120, paint1);

    // Grid pattern
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    const spacing = 60.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        gridPaint,
      );
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        gridPaint,
      );
    }

    // Accent dots
    final dotPaint = Paint()
      ..color = Colors.amber.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final random = Random(42);
    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
