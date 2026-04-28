// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert' as convert;
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:image_picker/image_picker.dart';

Future<XFile?> pickImagePlatform(ImageSource source,
    {int? maxWidth, int? maxHeight, int? imageQuality}) async {
  if (source == ImageSource.camera) {
    return _captureFromWebCamera(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }
  return _pickFromFileSystem();
}

Future<XFile?> _pickFromFileSystem() async {
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = false;

  final completer = Completer<XFile?>();

  input.onChange.listen((_) {
    final files = input.files;
    if (files == null || files.isEmpty) {
      completer.complete(null);
      return;
    }
    final file = files[0];
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((_) {
      final bytes = (reader.result as ByteBuffer).asUint8List();
      completer.complete(XFile.fromData(bytes, name: file.name));
    });
    reader.onError.listen((_) {
      completer.completeError('File read error');
    });
  });

  input.click();
  return completer.future;
}

Future<XFile?> _captureFromWebCamera({
  int? maxWidth,
  int? maxHeight,
  int? imageQuality,
}) async {
  final completer = Completer<XFile?>();

  // ── Build overlay UI ──
  final overlay = html.DivElement()
    ..style.position = 'fixed'
    ..style.top = '0'
    ..style.left = '0'
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.background = 'rgba(0,0,0,0.95)'
    ..style.zIndex = '99999'
    ..style.display = 'flex'
    ..style.flexDirection = 'column'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'center';

  final title = html.DivElement()
    ..text = '📷 Kamera'
    ..style.color = 'white'
    ..style.fontSize = '20px'
    ..style.fontWeight = 'bold'
    ..style.marginBottom = '16px'
    ..style.fontFamily = '-apple-system, BlinkMacSystemFont, sans-serif';

  // Loading indicator
  final loadingText = html.DivElement()
    ..text = 'Memuat kamera...'
    ..style.color = 'rgba(255,255,255,0.7)'
    ..style.fontSize = '14px'
    ..style.marginBottom = '16px';

  final video = html.VideoElement()
    ..autoplay = true
    ..setAttribute('playsinline', 'true')
    ..style.maxWidth = '90%'
    ..style.maxHeight = '60vh'
    ..style.borderRadius = '16px'
    ..style.boxShadow = '0 8px 32px rgba(0,0,0,0.3)'
    ..style.display = 'none'; // Hidden until camera loads

  final buttonRow = html.DivElement()
    ..style.display = 'flex'
    ..style.gap = '20px'
    ..style.marginTop = '24px'
    ..style.alignItems = 'center';

  final cancelBtn = html.ButtonElement()
    ..text = '✕ Batal'
    ..style.padding = '12px 28px'
    ..style.fontSize = '15px'
    ..style.border = '2px solid rgba(255,255,255,0.5)'
    ..style.borderRadius = '30px'
    ..style.background = 'transparent'
    ..style.color = 'white'
    ..style.cursor = 'pointer'
    ..style.fontWeight = '600';

  // Shutter button (big circle)
  final captureBtn = html.DivElement()
    ..style.width = '72px'
    ..style.height = '72px'
    ..style.borderRadius = '50%'
    ..style.cursor = 'pointer'
    ..style.background = 'white'
    ..style.border = '4px solid rgba(255,255,255,0.5)'
    ..style.boxShadow = '0 4px 16px rgba(21,101,192,0.4)'
    ..style.display = 'flex'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'center';

  final innerCircle = html.DivElement()
    ..style.width = '56px'
    ..style.height = '56px'
    ..style.borderRadius = '50%'
    ..style.background = '#1565C0';
  captureBtn.append(innerCircle);

  final switchBtn = html.ButtonElement()
    ..text = '🔄 Balik'
    ..style.padding = '12px 28px'
    ..style.fontSize = '15px'
    ..style.border = '2px solid rgba(255,255,255,0.5)'
    ..style.borderRadius = '30px'
    ..style.background = 'transparent'
    ..style.color = 'white'
    ..style.cursor = 'pointer'
    ..style.fontWeight = '600';

  buttonRow.children.addAll([cancelBtn, captureBtn, switchBtn]);
  overlay.children.addAll([title, loadingText, video, buttonRow]);
  html.document.body!.append(overlay);

  // ── Camera logic ──
  html.MediaStream? stream;
  bool useFrontCamera = true;

  void cleanup() {
    stream?.getTracks().forEach((track) => track.stop());
    overlay.remove();
  }

  Future<void> startCamera(bool front) async {
    stream?.getTracks().forEach((track) => track.stop());
    try {
      stream = await html.window.navigator.mediaDevices!.getUserMedia({
        'video': {
          'facingMode': front ? 'user' : 'environment',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        },
        'audio': false,
      });
      video.srcObject = stream;
      video.style.transform = front ? 'scaleX(-1)' : 'none';
      loadingText.style.display = 'none';
      video.style.display = 'block';
    } catch (_) {
      // Fallback: try without facingMode constraint
      try {
        stream = await html.window.navigator.mediaDevices!.getUserMedia({
          'video': true,
          'audio': false,
        });
        video.srcObject = stream;
        loadingText.style.display = 'none';
        video.style.display = 'block';
      } catch (e2) {
        cleanup();
        if (!completer.isCompleted) {
          completer.completeError(
              'Tidak dapat mengakses kamera. Pastikan izin kamera diberikan.');
        }
        return;
      }
    }
  }

  await startCamera(useFrontCamera);

  // Capture photo
  captureBtn.onClick.listen((_) {
    try {
      final vw = video.videoWidth;
      final vh = video.videoHeight;
      if (vw == 0 || vh == 0) return;

      int targetW = vw;
      int targetH = vh;
      if (maxWidth != null && targetW > maxWidth) {
        final scale = maxWidth / targetW;
        targetW = maxWidth;
        targetH = (targetH * scale).round();
      }
      if (maxHeight != null && targetH > maxHeight) {
        final scale = maxHeight / targetH;
        targetH = maxHeight;
        targetW = (targetW * scale).round();
      }

      final canvas = html.CanvasElement(width: targetW, height: targetH);
      final ctx = canvas.context2D;

      if (useFrontCamera) {
        ctx.translate(targetW.toDouble(), 0);
        ctx.scale(-1, 1);
      }
      ctx.drawImageScaled(video, 0, 0, targetW, targetH);

      final quality = (imageQuality ?? 80) / 100.0;
      final dataUrl = canvas.toDataUrl('image/jpeg', quality);
      final base64Data = dataUrl.split(',').last;
      final bytes = Uint8List.fromList(convert.base64Decode(base64Data));

      cleanup();
      if (!completer.isCompleted) {
        completer.complete(XFile.fromData(
          bytes,
          name: 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg',
          mimeType: 'image/jpeg',
        ));
      }
    } catch (e) {
      cleanup();
      if (!completer.isCompleted) {
        completer.completeError('Gagal mengambil foto: $e');
      }
    }
  });

  cancelBtn.onClick.listen((_) {
    cleanup();
    if (!completer.isCompleted) completer.complete(null);
  });

  switchBtn.onClick.listen((_) async {
    useFrontCamera = !useFrontCamera;
    await startCamera(useFrontCamera);
  });

  return completer.future;
}
