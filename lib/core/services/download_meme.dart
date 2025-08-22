import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:developer' as dev;
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

typedef DownloadProgressCallback = void Function(int received, int total);

enum DownloadStatus {
  success,
  permissionDenied,
  permissionPermanentlyDenied,
  downloadFailed,
  saveFailed,
  unknownError,
}

class DownloadResult {
  final DownloadStatus status;
  final String? errorMessage;
  final String? savedPath;

  const DownloadResult({
    required this.status,
    this.errorMessage,
    this.savedPath,
  });

  bool get isSuccess => status == DownloadStatus.success;
}

/// Checks and requests necessary permissions for saving to gallery.
/// Returns true if permission is granted, false otherwise.
Future<bool> _checkAndRequestPermissions() async {
  try {
    // Check if we have permission
    var status = await Permission.photos.status;

    // If permission is denied, request it
    if (status.isDenied) {
      status = await Permission.photos.request();
    }

    // If permission is permanently denied, return false
    if (status.isPermanentlyDenied) {
      dev.log('[DownloadMeme] Permission permanently denied');
      return false;
    }

    // Return true only if permission is granted
    return status.isGranted;
  } catch (e) {
    dev.log('[DownloadMeme] Error checking permissions: $e');
    return false;
  }
}

/// Downloads a meme from the given URL or saves a local file to the gallery.
/// [onProgress] is an optional callback that provides download progress updates.
/// [isLocalFile] should be true if memeUrl is a local file path.
/// Returns a [DownloadResult] with the status and any error details.
Future<DownloadResult> downloadMeme(
  String memeUrl, {
  DownloadProgressCallback? onProgress,
  bool isLocalFile = false,
}) async {
  CancelToken? cancelToken;
  String? tempFilePath;

  try {
    dev.log(
      '[DownloadMeme] Starting download. url=$memeUrl, isLocalFile=$isLocalFile',
    );
    cancelToken = CancelToken();

    // Check and request permissions
    final hasPermission = await _checkAndRequestPermissions();
    if (!hasPermission) {
      return const DownloadResult(
        status: DownloadStatus.permissionDenied,
        errorMessage:
            'Storage permission is required to save memes. Please enable it in app settings.',
      );
    }

    if (isLocalFile) {
      // Handle local file
      final file = File(memeUrl);
      if (!await file.exists()) {
        return const DownloadResult(
          status: DownloadStatus.downloadFailed,
          errorMessage: 'File not found',
        );
      }

      // Simulate progress for local files
      onProgress?.call(50, 100);
      await Future.delayed(const Duration(milliseconds: 200));
      onProgress?.call(100, 100);

      tempFilePath = memeUrl;
    } else {
      // Handle remote URL
      final dir = await getTemporaryDirectory();
      final fileName = 'meme_${DateTime.now().millisecondsSinceEpoch}.jpg';
      tempFilePath = '${dir.path}/$fileName';

      dev.log('[DownloadMeme] Downloading to temp file: $tempFilePath');
      final dio = Dio()..options.receiveTimeout = const Duration(seconds: 30);

      try {
        await dio.download(
          memeUrl,
          tempFilePath,
          cancelToken: cancelToken,
          onReceiveProgress: (count, total) {
            onProgress?.call(count, total);
            if (total > 0) {
              final pct = (count / total * 100).toStringAsFixed(1);
              dev.log('[DownloadMeme] Progress: $count/$total ($pct%)');
            }
          },
        );
      } on DioException catch (e) {
        dev.log('[DownloadMeme] Download error: $e');
        return DownloadResult(
          status: DownloadStatus.downloadFailed,
          errorMessage: 'Failed to download file: ${e.message}',
        );
      }
    }

    // Verify temp file exists and is not empty
    final tempFile = File(tempFilePath!);
    if (!await tempFile.exists()) {
      return const DownloadResult(
        status: DownloadStatus.downloadFailed,
        errorMessage: 'Temporary file not found',
      );
    }

    final fileSize = await tempFile.length();
    if (fileSize == 0) {
      dev.log('[DownloadMeme] Downloaded file is empty');
      return const DownloadResult(
        status: DownloadStatus.downloadFailed,
        errorMessage: 'Downloaded file is empty. Please try again.',
      );
    }

    // Save to gallery
    dev.log('[DownloadMeme] Saving to gallery...');
    try {
      final fileName = 'meme_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final entity = await PhotoManager.editor.saveImageWithPath(
        tempFilePath,
        title: fileName,
      );

      // Clean up temp file if it wasn't a local file
      if (!isLocalFile) {
        try {
          await tempFile.delete();
        } catch (e) {
          dev.log('[DownloadMeme] Error deleting temp file: $e');
        }
      }

      if (entity == null) {
        dev.log('[DownloadMeme] Failed to save to gallery');
        return const DownloadResult(
          status: DownloadStatus.saveFailed,
          errorMessage: 'Failed to save meme to gallery.',
        );
      }

      dev.log('[DownloadMeme] Successfully saved with id: ${entity.id}');
      return DownloadResult(
        status: DownloadStatus.success,
        savedPath: entity.id,
      );
    } catch (e) {
      dev.log('[DownloadMeme] Error saving to gallery: $e');
      return DownloadResult(
        status: DownloadStatus.saveFailed,
        errorMessage:
            'Failed to save to gallery: ${e.toString().split('\n').first}',
      );
    }
  } catch (e) {
    dev.log('[DownloadMeme] Unexpected error: $e');
    return DownloadResult(
      status: DownloadStatus.unknownError,
      errorMessage: 'An error occurred: ${e.toString().split('\n').first}',
    );
  } finally {
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel();
    }
  }
}
