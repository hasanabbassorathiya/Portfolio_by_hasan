import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';

class GrainOverlay extends StatefulWidget {
  final Widget child;
  final double opacity;

  const GrainOverlay({
    super.key,
    required this.child,
    this.opacity = 0.035,
  });

  @override
  State<GrainOverlay> createState() => _GrainOverlayState();
}

class _GrainOverlayState extends State<GrainOverlay> {
  ui.Image? _noiseImage;

  @override
  void initState() {
    super.initState();
    _createNoiseImage();
  }

  void _createNoiseImage() {
    const w = 128;
    const h = 128;
    final random = Random(42);
    final data = Uint8List(w * h * 4);
    for (var i = 0; i < data.length; i += 4) {
      final v = random.nextInt(256);
      data[i] = v;
      data[i + 1] = v;
      data[i + 2] = v;
      data[i + 3] = 255;
    }
    ui.decodeImageFromPixels(data, w, h, ui.PixelFormat.rgba8888, (img) {
      if (mounted) setState(() => _noiseImage = img);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_noiseImage != null)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GrainPainter(
                  noiseImage: _noiseImage!,
                  opacity: widget.opacity,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _GrainPainter extends CustomPainter {
  final ui.Image noiseImage;
  final double opacity;

  _GrainPainter({required this.noiseImage, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = ImageShader(
        noiseImage,
        TileMode.repeated,
        TileMode.repeated,
        Matrix4.identity()
            .scaled(size.width / noiseImage.width, size.height / noiseImage.height)
            .storage,
      )
      ..color = Colors.white.withValues(alpha: opacity);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) => false;
}
