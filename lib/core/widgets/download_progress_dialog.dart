import 'package:flutter/material.dart';

class DownloadProgressDialog extends StatefulWidget {
  final Future<void> downloadFuture;
  final String fileName;

  const DownloadProgressDialog({
    super.key,
    required this.downloadFuture,
    required this.fileName,
  });

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  double _progress = 0.0;
  bool _isDownloading = true;
  String _status = 'Starting download...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      await widget.downloadFuture;
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _status = 'Download completed!';
        });
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _hasError = true;
          _status = 'Download failed: ${e.toString().split('\n').first}';
        });
      }
    }
  }

  void _updateProgress(int count, int total) {
    if (mounted) {
      setState(() {
        _progress = count / total;
        _status = 'Downloading: ${(_progress * 100).toStringAsFixed(1)}%';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Downloading Meme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isDownloading)
            LinearProgressIndicator(value: _progress, minHeight: 10)
          else if (_hasError)
            const Icon(Icons.error_outline, color: Colors.red, size: 40)
          else
            const Icon(Icons.check_circle, color: Colors.green, size: 40),
          const SizedBox(height: 20),
          Text(_status),
          const SizedBox(height: 10),
          Text(
            widget.fileName,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        if (!_isDownloading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(!_hasError),
            child: Text(_hasError ? 'Close' : 'OK'),
          ),
      ],
    );
  }
}

Future<bool> showDownloadProgressDialog({
  required BuildContext context,
  required Future<void> downloadFuture,
  required String fileName,
}) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => DownloadProgressDialog(
          downloadFuture: downloadFuture,
          fileName: fileName,
        ),
      ) ??
      false;
}
