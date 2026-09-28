import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/routes.dart';
import '../../services/auth_service.dart';
import '../../services/solar_session_service.dart';
import '../../services/storage_service.dart';

/// Rooftop Photo Screen — real image capture + Firebase Storage upload.
///
/// Users can take a photo or pick from gallery.
/// The image is uploaded to Firebase Storage and the URL saved to Firestore
/// via SolarSessionState before proceeding to AI analysis.
class RooftopPhotoScreen extends StatefulWidget {
  const RooftopPhotoScreen({super.key});

  @override
  State<RooftopPhotoScreen> createState() => _RooftopPhotoScreenState();
}

class _RooftopPhotoScreenState extends State<RooftopPhotoScreen> {
  final _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() {
        _selectedImage = File(picked.path);
        _errorMessage = null;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Could not access camera/gallery.');
    }
  }

  Future<void> _proceedWithUpload() async {
    if (_selectedImage == null) {
      // No image selected — skip upload and go straight to analysis
      Navigator.pushNamed(context, AppRoutes.aiRoofAnalysis);
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _errorMessage = null;
    });

    try {
      final uid = AuthService().uid;
      final session = SolarSessionState();

      // Ensure property + rooftop IDs exist (may be null for first run)
      // StorageService needs them — use defaults if absent
      final propId = session.propertyId ?? 'default';
      final roofId = session.rooftopId ?? 'default';

      StorageUploadResult? result;

      if (uid != null) {
        result = await StorageService().uploadRooftopImage(
          uid: uid,
          propertyId: propId,
          rooftopId: roofId,
          imageFile: _selectedImage!,
          onProgress: (p) {
            if (mounted) setState(() => _uploadProgress = p);
          },
        );
      }

      // Update session with image URL
      await session.updateRooftopAnalysis(
        grossAreaSqFt: session.rooftopAnalysis.totalGrossAreaSqFt,
        usableAreaSqFt: session.rooftopAnalysis.netUsableAreaSqFt,
        imageUrl: result?.downloadUrl,
        imageStoragePath: result?.storagePath,
      );

      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.aiRoofAnalysis);
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = 'Upload failed. Check your connection and try again.';
      });
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9EF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF003323)),
        title: Text(
          'Rooftop Photos',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF003323),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Instructions ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF003323).withAlpha(13),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF0B6D33),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'For best results',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF003323),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _bullet('Take 2–4 photos of your terrace'),
                    _bullet(
                      'Show parapet walls, water tank, and staircase cover',
                    ),
                    _bullet('Shoot from corners to capture the full area'),
                    _bullet('Ensure good daylight — avoid shadows'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Preview or placeholder ─────────────────────────────────
              Expanded(
                child: _selectedImage != null
                    ? _buildImagePreview()
                    : _buildPickerPlaceholder(),
              ),

              // ── Upload progress ────────────────────────────────────────
              if (_isUploading) ...[
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uploading… ${(_uploadProgress * 100).toInt()}%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF003323).withAlpha(153),
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: const Color(0xFFDDD8C4),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF0B6D33),
                      ),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                  ],
                ),
              ],

              // ── Error ──────────────────────────────────────────────────
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.red.shade600,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ── Action buttons ─────────────────────────────────────────
              if (!_isUploading) ...[
                if (_selectedImage == null) ...[
                  _buildPickButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Take Photo',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  const SizedBox(height: 12),
                  _buildPickButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Choose from Gallery',
                    onTap: () => _pickImage(ImageSource.gallery),
                    outlined: true,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.aiRoofAnalysis),
                    child: Text(
                      'Skip — Use AI satellite analysis instead',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF003323).withAlpha(153),
                      ),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              setState(() => _selectedImage = null),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: Text(
                            'Retake',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0B6D33)),
                            foregroundColor: const Color(0xFF0B6D33),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _proceedWithUpload,
                          icon: const Icon(Icons.upload_rounded, size: 18),
                          label: Text(
                            'Upload & Analyse',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF003323),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: double.infinity,
      ),
    );
  }

  Widget _buildPickerPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF003323).withAlpha(8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF003323).withAlpha(25),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 56,
            color: const Color(0xFF003323).withAlpha(77),
          ),
          const SizedBox(height: 16),
          Text(
            'No photo selected',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF003323).withAlpha(128),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap a button below to add your rooftop photo',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF003323).withAlpha(77),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPickButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    if (outlined) {
      return SizedBox(
        height: 52,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 20),
          label: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF0B6D33)),
            foregroundColor: const Color(0xFF0B6D33),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF003323),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF0B6D33))),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF003323).withAlpha(178),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
