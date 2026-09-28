import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Wraps Firebase Storage for rooftop image uploads.
///
/// Storage path: `users/{uid}/properties/{propId}/rooftops/{roofId}/images/{filename}`
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ─── Upload ───────────────────────────────────────────────────────────────

  /// Uploads a rooftop image file and returns [StorageUploadResult].
  ///
  /// Progress updates are emitted through the returned [UploadTask] — you can
  /// listen to it for a progress bar.
  Future<StorageUploadResult> uploadRooftopImage({
    required String uid,
    required String propertyId,
    required String rooftopId,
    required File imageFile,
    void Function(double progress)? onProgress,
  }) async {
    final ext = imageFile.path.split('.').last.toLowerCase();
    final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final storagePath =
        'users/$uid/properties/$propertyId/rooftops/$rooftopId/images/$filename';

    final ref = _storage.ref(storagePath);
    final metadata = SettableMetadata(
      contentType: 'image/$ext',
      customMetadata: {
        'uid': uid,
        'propertyId': propertyId,
        'rooftopId': rooftopId,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );

    final task = ref.putFile(imageFile, metadata);

    if (onProgress != null) {
      task.snapshotEvents.listen((event) {
        if (event.totalBytes > 0) {
          final progress = event.bytesTransferred / event.totalBytes;
          onProgress(progress);
        }
      });
    }

    final snapshot = await task;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return StorageUploadResult(
      downloadUrl: downloadUrl,
      storagePath: storagePath,
      filename: filename,
    );
  }

  /// Deletes a file at [storagePath].
  Future<void> deleteFile(String storagePath) async {
    try {
      await _storage.ref(storagePath).delete();
    } catch (e) {
      debugPrint('StorageService.deleteFile failed: $e');
    }
  }

  /// Returns the download URL for an existing [storagePath].
  Future<String?> getDownloadUrl(String storagePath) async {
    try {
      return await _storage.ref(storagePath).getDownloadURL();
    } catch (e) {
      debugPrint('StorageService.getDownloadUrl failed: $e');
      return null;
    }
  }
}

/// Result of a successful Firebase Storage upload.
class StorageUploadResult {
  final String downloadUrl;
  final String storagePath;
  final String filename;

  const StorageUploadResult({
    required this.downloadUrl,
    required this.storagePath,
    required this.filename,
  });
}
