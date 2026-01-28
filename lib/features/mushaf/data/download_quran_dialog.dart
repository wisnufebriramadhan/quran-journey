import 'package:flutter/material.dart';
import 'quran_download_service.dart';

/// Dialog konfirmasi sebelum download (ringan & quick)
class DownloadQuranDialog extends StatelessWidget {
  const DownloadQuranDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final downloadService = QuranDownloadService();

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.cloud_download, color: Color(0xFF8B5E3C)),
          SizedBox(width: 12),
          Text('Download Mushaf?', style: TextStyle(fontSize: 18)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Download data Mushaf untuk akses offline dan performa lebih cepat.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.storage, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Ukuran: ~${downloadService.getEstimatedSizeMB().toStringAsFixed(1)} MB',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.offline_bolt, size: 20, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'Download berjalan di background',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Anda bisa tetap menggunakan app sambil download berlangsung',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Nanti'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5E3C),
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Download'),
        ),
      ],
    );
  }
}

/// Bottom sheet untuk show progress (dismissible)
class DownloadProgressSheet extends StatefulWidget {
  final QuranDownloadService downloadService;
  final VoidCallback onComplete;
  final VoidCallback onError;

  const DownloadProgressSheet({
    super.key,
    required this.downloadService,
    required this.onComplete,
    required this.onError,
  });

  @override
  State<DownloadProgressSheet> createState() => _DownloadProgressSheetState();
}

class _DownloadProgressSheetState extends State<DownloadProgressSheet> {
  double _progress = 0.0;
  String _status = 'Memulai download...';
  bool _isComplete = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      await widget.downloadService.downloadQuran(
        onProgress: (progress, status) {
          if (mounted) {
            setState(() {
              _progress = progress;
              _status = status;
            });
          }
        },
      );

      if (mounted) {
        setState(() => _isComplete = true);
        widget.onComplete();

        // Auto close setelah 2 detik jika complete
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _status = 'Gagal: ${e.toString()}';
        });
        widget.onError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Icon & Title
          Row(
            children: [
              if (!_isComplete && !_hasError)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF8B5E3C),
                  ),
                ),
              if (_isComplete)
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
              if (_hasError)
                const Icon(Icons.error_outline, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isComplete
                      ? 'Download Selesai!'
                      : _hasError
                          ? 'Download Gagal'
                          : 'Mengunduh Mushaf...',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!_isComplete)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Tutup (download tetap berjalan)',
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          if (!_isComplete)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF8B5E3C),
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _status,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(_progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),

          // Success message
          if (_isComplete)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Data Mushaf berhasil di-download!\nAnda sekarang dapat membaca offline.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          // Error message
          if (_hasError)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _status,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5E3C),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        // User bisa coba lagi
                      },
                      child: const Text('Tutup'),
                    ),
                  ),
                ],
              ),
            ),

          // Info untuk user
          if (!_isComplete && !_hasError) ...[
            const SizedBox(height: 12),
            Text(
              'Anda bisa menutup ini dan tetap menggunakan app',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Helper function untuk show confirmation dialog
Future<bool> showDownloadQuranDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => const DownloadQuranDialog(),
  );
  return result ?? false;
}

/// Helper function untuk start download dengan progress sheet
void startBackgroundDownload(
  BuildContext context, {
  required VoidCallback onComplete,
  required VoidCallback onError,
}) {
  final downloadService = QuranDownloadService();

  showModalBottomSheet(
    context: context,
    isDismissible: true,
    enableDrag: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DownloadProgressSheet(
      downloadService: downloadService,
      onComplete: onComplete,
      onError: onError,
    ),
  );
}
