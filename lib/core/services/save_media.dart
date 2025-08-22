import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

/// Ensure we have permission to add to the device Photos/Gallery.
/// Returns true if authorized (including limited), false otherwise.
/// If [openSettingsIfDenied] is true and access is denied permanently,
/// this will open the app settings page.
Future<bool> ensureGalleryPermission({
  bool openSettingsIfDenied = false,
}) async {
  final result = await PhotoManager.requestPermissionExtend();
  if (result.isAuth) return true; // authorized or limited
  if (openSettingsIfDenied) {
    await PhotoManager.openSetting();
  }
  return false;
}

Future<bool> saveEditedMeme(GlobalKey globalKey) async {
  try {
    // Request gallery permission
    final ok = await ensureGalleryPermission();
    if (!ok) {
      // Optionally open settings: PhotoManager.openSetting();
      debugPrint('[SaveEditedMeme] Permission denied.');
      return false;
    }

    final boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return false;
    final Uint8List pngBytes = byteData.buffer.asUint8List();

    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        '${dir.path}/edited_meme_${DateTime.now().millisecondsSinceEpoch}.png';

    final file = File(filePath);
    await file.writeAsBytes(pngBytes);

    final title = 'edited_meme_${DateTime.now().millisecondsSinceEpoch}.png';
    final entity = await PhotoManager.editor.saveImageWithPath(
      filePath,
      title: title,
    );
    final success = entity != null;
    final idLog = entity != null ? entity.id : 'null';
    debugPrint(
      '[SaveEditedMeme] Saved via PhotoManager: success=$success, id=$idLog | path=$filePath',
    );
    return success;
  } catch (e) {
    debugPrint('[SaveEditedMeme] Error: $e');
    return false;
  }
}

/// Directory inside app documents where we keep app-local memes
Future<Directory> _appMemesDir() async {
  final root = await getApplicationDocumentsDirectory();
  final dir = Directory('${root.path}/memes');
  if (!(await dir.exists())) {
    await dir.create(recursive: true);
  }
  return dir;
}

/// Save PNG bytes into the app's local gallery folder and return the file path.
Future<String?> saveImageBytesToAppGallery(
  Uint8List pngBytes, {
  String? fileName,
}) async {
  try {
    final dir = await _appMemesDir();
    final name =
        fileName ?? 'meme_${DateTime.now().millisecondsSinceEpoch}.png';
    final path = '${dir.path}/$name';
    final file = File(path);
    await file.writeAsBytes(pngBytes);
    return path;
  } catch (e) {
    debugPrint('[AppGallery] Save error: $e');
    return null;
  }
}

/// List paths of saved memes in the app's local gallery folder.
Future<List<String>> listAppGalleryMemes() async {
  try {
    final dir = await _appMemesDir();
    final entries = await dir.list().toList();
    final files = entries.whereType<File>().toList()
      ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files.map((f) => f.path).toList();
  } catch (e) {
    debugPrint('[AppGallery] List error: $e');
    return <String>[];
  }
}

/// Saves raw PNG bytes to the device gallery using `photo_manager`.
/// Returns true on success.
Future<bool> saveImageBytesToGallery(
  Uint8List pngBytes, {
  String? fileName,
}) async {
  try {
    // Request gallery permission
    final ok = await ensureGalleryPermission();
    if (!ok) {
      debugPrint('[SaveImageBytes] Permission denied.');
      return false;
    }

    final dir = await getTemporaryDirectory();
    final name =
        fileName ?? 'edited_meme_${DateTime.now().millisecondsSinceEpoch}.png';
    final filePath = '${dir.path}/$name';

    final file = File(filePath);
    await file.writeAsBytes(pngBytes);

    final entity = await PhotoManager.editor.saveImageWithPath(
      filePath,
      title: name,
    );
    final success = entity != null;
    final idLog = entity != null ? entity.id : 'null';
    debugPrint(
      '[SaveImageBytes] Saved via PhotoManager: success=$success, id=$idLog | path=$filePath',
    );
    return success;
  } catch (e) {
    debugPrint('[SaveImageBytes] Error: $e');
    return false;
  }
}
