import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

class YoloDetectionScreen extends StatefulWidget {
  const YoloDetectionScreen({super.key});
  @override
  State<YoloDetectionScreen> createState() => _YoloDetectionScreenState();
}

class _YoloDetectionScreenState extends State<YoloDetectionScreen> {
  List<YOLOResult> _detections = [];
  double _fps = 0;
  double _confidence = 0.5;
  bool _showOverlays = true;
  LensFacing _lens = LensFacing.back;

  Map<String, int> get _classCounts {
    final c = <String, int>{};
    for (final d in _detections) { c[d.className] = (c[d.className] ?? 0) + 1; }
    return c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black54, foregroundColor: Colors.white, elevation: 0,
        title: Row(children: [
          Container(padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.deepPurple.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.visibility_rounded, size: 20, color: Colors.purpleAccent)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('YOLO Detection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${_detections.length} objek terdeteksi', style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ]),
        ]),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _fps > 15 ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _fps > 15 ? Colors.greenAccent : Colors.orangeAccent, width: 1)),
            child: Text('${_fps.toStringAsFixed(1)} FPS',
              style: TextStyle(color: _fps > 15 ? Colors.greenAccent : Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          IconButton(icon: const Icon(Icons.flip_camera_android_rounded, color: Colors.white70),
            onPressed: () => setState(() => _lens = _lens == LensFacing.back ? LensFacing.front : LensFacing.back),
            tooltip: 'Ganti Kamera'),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(children: [
        YOLOView(
          key: ValueKey(_lens),
          modelPath: 'assets/models/yolo11n_int8.tflite',
          confidenceThreshold: _confidence,
          iouThreshold: 0.45,
          lensFacing: _lens,
          showOverlays: _showOverlays,
          onResult: (r) => setState(() => _detections = r),
          onPerformanceMetrics: (m) => setState(() => _fps = m.fps),
        ),
        Positioned(bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: BoxDecoration(gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)])),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                const Icon(Icons.tune_rounded, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text('Confidence: ${(_confidence * 100).toInt()}%', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Expanded(child: SliderTheme(
                  data: SliderThemeData(activeTrackColor: Colors.purpleAccent, inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.purpleAccent, overlayColor: Colors.purpleAccent.withValues(alpha: 0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7), trackHeight: 3),
                  child: Slider(value: _confidence, min: 0.1, max: 0.95, onChanged: (v) => setState(() => _confidence = v)))),
                IconButton(icon: Icon(_showOverlays ? Icons.layers_rounded : Icons.layers_clear_rounded,
                  color: _showOverlays ? Colors.purpleAccent : Colors.white38, size: 20),
                  onPressed: () => setState(() => _showOverlays = !_showOverlays), tooltip: 'Toggle Overlay'),
              ]),
              const SizedBox(height: 8),
              if (_classCounts.isNotEmpty) SizedBox(height: 36,
                child: ListView(scrollDirection: Axis.horizontal,
                  children: _classCounts.entries.map((e) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.deepPurple.withValues(alpha: 0.6), Colors.purpleAccent.withValues(alpha: 0.4)]),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.5))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(e.key, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 6),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                        child: Text('${e.value}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    ]),
                  )).toList())),
              if (_classCounts.isEmpty)
                Text('Arahkan kamera ke objek untuk mendeteksi...',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            ]),
          )),
      ]),
    );
  }
}
