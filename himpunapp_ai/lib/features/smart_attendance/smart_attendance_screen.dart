import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class SmartAttendanceScreen extends StatefulWidget {
  const SmartAttendanceScreen({super.key});
  @override
  State<SmartAttendanceScreen> createState() => _SmartAttendanceScreenState();
}

class _SmartAttendanceScreenState extends State<SmartAttendanceScreen> {
  final _picker = ImagePicker();
  final _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  String? _imageBase64;
  ui.Image? _uiImage;
  List<Face> _faces = [];
  bool _processing = false;
  bool _hasResult = false;

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _pickAndDetect(ImageSource source) async {
    try {
      final xfile = await _picker.pickImage(
        source: source,
      );
      if (xfile == null) return;

      setState(() {
        _processing = true;
        _hasResult = false;
        _faces = [];
      });

      // Read base64 and ui.Image for display
      final bytes = await xfile.readAsBytes();
      final base64Str = base64Encode(bytes);
      final uiImage = await decodeImageFromList(bytes);

      // Run face detection (on-device ML Kit model)
      final inputImage = InputImage.fromFilePath(xfile.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (mounted) {
        setState(() {
          _imageBase64 = base64Str;
          _uiImage = uiImage;
          _faces = faces;
          _processing = false;
          _hasResult = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _getSmilingStatus() {
    int smiling = 0;
    for (final face in _faces) {
      if (face.smilingProbability != null && face.smilingProbability! > 0.5) {
        smiling++;
      }
    }
    if (_faces.isEmpty) return '';
    final pct = (smiling / _faces.length * 100).toInt();
    return '$smiling/$pct% tersenyum';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF42A5F5)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -20, right: -30,
                      child: Container(width: 100, height: 100,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08))),
                    ),
                    Positioned(
                      bottom: 40, left: 20, right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.face_retouching_natural, color: Colors.amberAccent, size: 22),
                            ),
                            const SizedBox(width: 10),
                            const Text('Smart Attendance', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 4),
                          Text(
                            'Foto rombongan \u2192 AI hitung wajah otomatis',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Ambil Foto',
                      color: const Color(0xFF1565C0),
                      onTap: () => _pickAndDetect(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Dari Galeri',
                      color: const Color(0xFF7B1FA2),
                      onTap: () => _pickAndDetect(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Processing indicator
          if (_processing)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF1565C0)),
                    SizedBox(height: 16),
                    Text('AI sedang mendeteksi wajah...', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    SizedBox(height: 4),
                    Text('Model berjalan di perangkat (offline)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),

          // Result card
          if (_hasResult && !_processing)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _faces.isNotEmpty
                          ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                          : [const Color(0xFFFF9800), const Color(0xFFFFA726)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (_faces.isNotEmpty ? const Color(0xFF4CAF50) : const Color(0xFFFF9800)).withValues(alpha: 0.3),
                        blurRadius: 12, offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _faces.isNotEmpty ? Icons.groups_rounded : Icons.person_off_rounded,
                          color: Colors.white, size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _faces.isNotEmpty ? '${_faces.length} Wajah Terdeteksi' : 'Tidak Ada Wajah',
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _faces.isNotEmpty
                                  ? 'Kehadiran: ${_faces.length} orang \u2022 ${_getSmilingStatus()}'
                                  : 'Coba foto dengan wajah yang lebih jelas',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Image preview with face bounding boxes
          if (_uiImage != null && !_processing)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: _uiImage!.width / _uiImage!.height,
                    child: CustomPaint(
                      painter: _FacePainter(_uiImage!, _faces),
                    ),
                  ),
                ),
              ),
            ),

          // Face details
          if (_hasResult && _faces.isNotEmpty && !_processing)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text('Detail Wajah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              ),
            ),

          if (_hasResult && _faces.isNotEmpty && !_processing)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final face = _faces[i];
                  final smile = face.smilingProbability;
                  final leftEye = face.leftEyeOpenProbability;
                  final rightEye = face.rightEyeOpenProbability;
                  final angle = face.headEulerAngleY;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFFE3F2FD),
                            child: Text('${i + 1}', style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Wajah #${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    if (smile != null) _tag(smile > 0.5 ? '\u{1F604} Tersenyum' : '\u{1F610} Netral', smile > 0.5 ? Colors.green : Colors.grey),
                                    if (leftEye != null && rightEye != null) _tag(
                                      leftEye > 0.5 && rightEye > 0.5 ? '\u{1F440} Mata terbuka' : '\u{1F611} Mata tertutup',
                                      leftEye > 0.5 && rightEye > 0.5 ? Colors.blue : Colors.orange,
                                    ),
                                    if (angle != null) _tag(
                                      angle.abs() < 10 ? '\u{2B50} Lurus' : '\u{1F504} Miring ${angle.toStringAsFixed(0)}\u00B0',
                                      angle.abs() < 10 ? Colors.purple : Colors.teal,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _faces.length,
              ),
            ),

          // Empty state
          if (!_hasResult && !_processing)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.face_retouching_natural, size: 48, color: Color(0xFF1565C0)),
                      ),
                      const SizedBox(height: 20),
                      const Text('Absensi Cerdas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 8),
                      Text(
                        'Ambil foto rombongan saat rapat/acara.\nAI akan mendeteksi dan menghitung\njumlah wajah secara otomatis.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.6),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wifi_off_rounded, size: 14, color: Color(0xFF4CAF50)),
                            SizedBox(width: 6),
                            Text('100% Offline \u2022 Model lokal di perangkat',
                              style: TextStyle(color: Color(0xFF4CAF50), fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;

  _FacePainter(this.image, this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / image.width;
    final scaleY = size.height / image.height;

    // Draw the original image
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );

    // Draw bounding boxes
    final boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.redAccent;

    for (int i = 0; i < faces.length; i++) {
      final rect = faces[i].boundingBox;
      final scaledRect = Rect.fromLTRB(
        rect.left * scaleX,
        rect.top * scaleY,
        rect.right * scaleX,
        rect.bottom * scaleY,
      );
      canvas.drawRect(scaledRect, boxPaint);

      // Draw face number
      final textSpan = TextSpan(
        text: ' ${i + 1} ',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.redAccent,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(scaledRect.left, scaledRect.top - 20));
    }
  }

  @override
  bool shouldRepaint(covariant _FacePainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.faces != faces;
  }
}
