import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrScannerScreen extends StatefulWidget {
  /// If provided, the extracted text will be returned via Navigator.pop
  final bool returnText;

  const OcrScannerScreen({super.key, this.returnText = false});

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> {
  final _picker = ImagePicker();
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  String? _imageBase64;
  RecognizedText? _result;
  bool _processing = false;
  bool _hasResult = false;

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _pickAndScan(ImageSource source) async {
    try {
      final xfile = await _picker.pickImage(
        source: source,
      );
      if (xfile == null) return;

      setState(() {
        _processing = true;
        _hasResult = false;
        _result = null;
      });

      final bytes = await xfile.readAsBytes();
      _imageBase64 = base64Encode(bytes);

      // Run OCR (on-device ML Kit model)
      final inputImage = InputImage.fromFilePath(xfile.path);
      final result = await _textRecognizer.processImage(inputImage);

      if (mounted) {
        setState(() {
          _result = result;
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

  void _copyText() {
    if (_result == null || _result!.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _result!.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Teks berhasil disalin!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _useText() {
    if (_result == null) return;
    Navigator.pop(context, _result!.text);
  }

  @override
  Widget build(BuildContext context) {
    final fullText = _result?.text ?? '';
    final blockCount = _result?.blocks.length ?? 0;
    final wordCount = fullText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140, pinned: true,
            backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF42A5F5)],
                  ),
                ),
                child: Stack(children: [
                  Positioned(top: -20, right: -30,
                    child: Container(width: 100, height: 100,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)))),
                  Positioned(bottom: 40, left: 20, right: 20,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.document_scanner_rounded, color: Colors.amberAccent, size: 22)),
                        const SizedBox(width: 10),
                        const Text('Smart OCR Scanner', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      ]),
                      const SizedBox(height: 4),
                      Text('Foto dokumen/whiteboard \u2192 AI ekstrak teks',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                    ])),
                ]),
              ),
            ),
          ),

          // Buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(children: [
                Expanded(child: _ActionBtn(icon: Icons.camera_alt_rounded, label: 'Scan Kamera',
                  color: const Color(0xFF1565C0), onTap: () => _pickAndScan(ImageSource.camera))),
                const SizedBox(width: 12),
                Expanded(child: _ActionBtn(icon: Icons.photo_library_rounded, label: 'Dari Galeri',
                  color: const Color(0xFF7B1FA2), onTap: () => _pickAndScan(ImageSource.gallery))),
              ]),
            ),
          ),

          // Processing
          if (_processing)
            const SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.all(40),
                child: Column(children: [
                  CircularProgressIndicator(color: Color(0xFF1565C0)),
                  SizedBox(height: 16),
                  Text('AI sedang membaca teks...', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('Model OCR berjalan di perangkat (offline)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ])),
            ),

          // Stats
          if (_hasResult && !_processing)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: fullText.isNotEmpty
                        ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                        : [const Color(0xFFFF9800), const Color(0xFFFFA726)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(
                      color: (fullText.isNotEmpty ? const Color(0xFF4CAF50) : const Color(0xFFFF9800)).withValues(alpha: 0.3),
                      blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Row(children: [
                    Container(padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: Icon(fullText.isNotEmpty ? Icons.text_fields_rounded : Icons.text_snippet_outlined, color: Colors.white, size: 28)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(fullText.isNotEmpty ? 'Teks Berhasil Dikenali!' : 'Tidak Ada Teks',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(fullText.isNotEmpty
                        ? '$wordCount kata \u2022 $blockCount blok teks'
                        : 'Pastikan foto jelas dan terang',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                    ])),
                  ]),
                ),
              ),
            ),

          // Image
          if (_imageBase64 != null && !_processing)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: ClipRRect(borderRadius: BorderRadius.circular(16),
                  child: Image.memory(base64Decode(_imageBase64!), fit: BoxFit.cover, width: double.infinity, height: 200)),
              ),
            ),

          // Extracted text
          if (_hasResult && fullText.isNotEmpty && !_processing)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(children: [
                  Text('Hasil Ekstraksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _copyText,
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Salin', style: TextStyle(fontSize: 12)),
                  ),
                  if (widget.returnText)
                    TextButton.icon(
                      onPressed: _useText,
                      icon: const Icon(Icons.check_circle_rounded, size: 16),
                      label: const Text('Gunakan', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF4CAF50)),
                    ),
                ]),
              ),
            ),

          if (_hasResult && fullText.isNotEmpty && !_processing)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: SelectableText(
                    fullText,
                    style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF1A1A2E)),
                  ),
                ),
              ),
            ),

          // Empty state
          if (!_hasResult && !_processing)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
                  child: Column(children: [
                    Container(padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: const Color(0xFF1565C0).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.document_scanner_rounded, size: 48, color: Color(0xFF1565C0))),
                    const SizedBox(height: 20),
                    const Text('Scanner Dokumen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 8),
                    Text('Foto notulen rapat, whiteboard,\natau dokumen cetak.\nAI akan mengekstrak teks secara otomatis.',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.6)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: const Color(0xFF4CAF50).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.wifi_off_rounded, size: 14, color: Color(0xFF4CAF50)),
                        SizedBox(width: 6),
                        Text('100% Offline \u2022 Model lokal di perangkat',
                          style: TextStyle(color: Color(0xFF4CAF50), fontSize: 12, fontWeight: FontWeight.w500)),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
