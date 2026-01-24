import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quran_tracker/core/models/attendance_model.dart';
import 'package:quran_tracker/features/learning/data/learning_service.dart';
import 'package:quran_tracker/features/learning/data/service_locator.dart';
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

  // ✨ SOLUSI 2: Refresh data setiap kali widget muncul di layar
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Refresh setiap kali widget rebuild (termasuk saat kembali ke halaman ini)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isLoading) {
        _refreshData();
      }
    });
  }

  // ✨ Method untuk initialize pertama kali
  Future<void> _initializePage() async {
    await _loadAttendanceStatus();

    // Auto-detect lokasi hanya jika belum absen
    if (!_hasAttended) {
      await _getCurrentLocation();
    }
  }

  // ✨ Method untuk refresh data (tanpa loading full screen)
  Future<void> _refreshData() async {
    // Jangan tampilkan loading screen, hanya refresh data
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

        // Re-check location jika belum absen dan belum ada posisi
        if (!_hasAttended && _currentPosition == null) {
          _getCurrentLocation();
        }
      }
    } catch (e) {
      // Silent error, data lama masih ditampilkan
      print('Refresh error: $e');
    }
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

      // Jika error authentication, redirect ke login
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
    setState(() => _isCheckingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isCheckingLocation = false);
        _showError('GPS tidak aktif. Silakan aktifkan GPS.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isCheckingLocation = false);
          _showError('Izin lokasi ditolak');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isCheckingLocation = false);
        _showError('Izin lokasi ditolak permanen. Aktifkan di pengaturan.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() => _currentPosition = position);

      // Check if in range
      await _checkIfInRange(position.latitude, position.longitude);
    } catch (e) {
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

    // Cek dulu apakah dalam jangkauan
    if (_inRange == false) {
      _showError(
          'Anda berada di luar jangkauan. Jarak: ${_distance?.toStringAsFixed(0)} meter dari lokasi kantor.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await _service.submitAttendance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (response['success'] == true) {
        _showSuccess(response['message'] ?? 'Absensi berhasil!');
        await _loadAttendanceStatus();
      } else {
        _showError(response['message'] ?? 'Gagal melakukan absensi');
      }
    } catch (e) {
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
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
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
          borderRadius: BorderRadius.circular(10),
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
        backgroundColor: const Color(0xffF4F6F8),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                top: false,
                child: CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildHeaderInfo(),
                          const SizedBox(height: 24),
                          _buildStatsGrid(),
                          const SizedBox(height: 24),
                          _buildAttendanceCard(),
                          const SizedBox(height: 24),
                          const Text(
                            'Kategori Pembelajaran',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildCategoriesGrid(),
                          const SizedBox(height: 24),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF5D4037),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Pembelajaran',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF5D4037),
                Color(0xFF6D4C41),
                Color(0xFF7B5E57),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: 50,
                child: Icon(
                  Icons.school_rounded,
                  size: 200,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF5D4037).withOpacity(0.1),
            const Color(0xFF6D4C41).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF5D4037).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF5D4037),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mari Belajar Bersama',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tingkatkan pemahaman Al-Quran Anda',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: '📅',
            label: 'Hari Ini',
            value: DateTime.now().day.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: _hasAttended ? '✅' : '❌',
            label: 'Status',
            value: _hasAttended ? 'Hadir' : 'Belum',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: '📍',
            label: 'Radius',
            value: '${_officeLocation?.radius ?? 100}m',
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _hasAttended
              ? [const Color(0xFFf0fdf4), const Color(0xFFdcfce7)]
              : [const Color(0xFFf0f9ff), const Color(0xFFe0f2fe)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              _hasAttended ? const Color(0xFF10b981) : const Color(0xFF0ea5e9),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: Colors.white.withOpacity(0.5),
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1f2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dateFormatted,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withOpacity(0.6),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: '⏰',
            label: 'Waktu Absen',
            value: _attendance!.time ?? '-',
          ),
          const Divider(height: 24),
          _InfoRow(
            icon: '📍',
            label: 'Latitude',
            value: _attendance!.latitude?.toStringAsFixed(6) ?? '-',
          ),
          const Divider(height: 24),
          _InfoRow(
            icon: '📍',
            label: 'Longitude',
            value: _attendance!.longitude?.toStringAsFixed(6) ?? '-',
          ),
          const Divider(height: 24),
          _InfoRow(
            icon: '🎯',
            label: 'Status',
            value: 'Hadir',
            valueColor: const Color(0xFF10b981),
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
        // Loading indicator saat checking location
        if (_isCheckingLocation) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Memeriksa lokasi Anda...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Status lokasi (jika sudah selesai check)
        if (!_isCheckingLocation &&
            _currentPosition != null &&
            _inRange != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _inRange! ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _inRange! ? Colors.green : Colors.red,
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

        // Button Absen
        ElevatedButton(
          onPressed: shouldDisable ? null : _submitAttendance,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5D4037),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade400,
            disabledForegroundColor: Colors.grey.shade600,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 56),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
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
      ],
    );
  }

  Widget _buildGpsHint() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _hasAttended ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _hasAttended ? Colors.green : Colors.orange,
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
                color: _hasAttended
                    ? Colors.green.shade900
                    : Colors.orange.shade900,
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
        _LearningCategoryCard(
          title: 'Tajwid',
          icon: Icons.book_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF6D4C41), Color(0xFF5D4037)],
          ),
          onTap: () => _showComingSoon(context, 'Tajwid'),
        ),
        _LearningCategoryCard(
          title: 'Tafsir',
          icon: Icons.import_contacts_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF7B5E57), Color(0xFF6D4C41)],
          ),
          onTap: () => _showComingSoon(context, 'Tafsir'),
        ),
        _LearningCategoryCard(
          title: 'Hadits',
          icon: Icons.menu_book_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF8D6E63), Color(0xFF7B5E57)],
          ),
          onTap: () => _showComingSoon(context, 'Hadits'),
        ),
        _LearningCategoryCard(
          title: 'Doa Harian',
          icon: Icons.favorite_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFFa1887f), Color(0xFF8D6E63)],
          ),
          onTap: () => _showComingSoon(context, 'Doa Harian'),
        ),
        _LearningCategoryCard(
          title: 'Bahasa Arab',
          icon: Icons.language_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF6D4C41), Color(0xFF8D6E63)],
          ),
          onTap: () => _showComingSoon(context, 'Bahasa Arab'),
        ),
        _LearningCategoryCard(
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

// ================= HELPER WIDGETS =================
class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _LearningCategoryCard({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5D4037).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF5D4037),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color(0xFF1f2937),
          ),
        ),
      ],
    );
  }
}
