import 'package:flutter/material.dart';

class HandSkeletonPainter extends CustomPainter {
  final List<dynamic> keypoints;
  final Color jointColor;
  final Color boneColor;
  final double jointRadius;
  final double boneWidth;

  HandSkeletonPainter({
    required this.keypoints,
    this.jointColor = Colors.deepPurple,
    this.boneColor = Colors.blue,
    this.jointRadius = 4.0,
    this.boneWidth = 2.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (keypoints.length < 21) return;

    final jointPaint = Paint()
      ..color = jointColor
      ..style = PaintingStyle.fill;

    final bonePaint = Paint()
      ..color = boneColor
      ..strokeWidth = boneWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Convert coordinates to Offsets scaled by size
    final List<Offset> points = [];
    for (var kp in keypoints) {
      double x = (kp['x'] ?? 0.0).toDouble();
      double y = (kp['y'] ?? 0.0).toDouble();
      points.add(Offset(x * size.width, y * size.height));
    }

    // Helper to draw a bone (line between two joints)
    void drawBone(int start, int end) {
      if (start < points.length && end < points.length) {
        canvas.drawLine(points[start], points[end], bonePaint);
      }
    }

    // Draw fingers
    // Thumb: 0-1-2-3-4
    drawBone(0, 1);
    drawBone(1, 2);
    drawBone(2, 3);
    drawBone(3, 4);

    // Index: 0-5-6-7-8
    drawBone(0, 5);
    drawBone(5, 6);
    drawBone(6, 7);
    drawBone(7, 8);

    // Middle: 0-9-10-11-12
    drawBone(0, 9);
    drawBone(9, 10);
    drawBone(10, 11);
    drawBone(11, 12);

    // Ring: 0-13-14-15-16
    drawBone(0, 13);
    drawBone(13, 14);
    drawBone(14, 15);
    drawBone(15, 16);

    // Pinky: 0-17-18-19-20
    drawBone(0, 17);
    drawBone(17, 18);
    drawBone(18, 19);
    drawBone(19, 20);

    // Connect MCPs: 5-9-13-17
    drawBone(5, 9);
    drawBone(9, 13);
    drawBone(13, 17);

    // Draw joints (dots)
    for (var point in points) {
      canvas.drawCircle(point, jointRadius, jointPaint);
    }
    
    // Highlight tips
    final tipPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    final tips = [4, 8, 12, 16, 20];
    for (var t in tips) {
      if (t < points.length) {
        canvas.drawCircle(points[t], jointRadius * 1.3, tipPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HandSkeletonPainter oldDelegate) {
    return oldDelegate.keypoints != keypoints ||
        oldDelegate.jointColor != jointColor ||
        oldDelegate.boneColor != boneColor;
  }
}

class HandSkeletonWidget extends StatelessWidget {
  final List<dynamic>? keypoints;
  final double width;
  final double height;
  final Color? backgroundColor;

  const HandSkeletonWidget({
    Key? key,
    required this.keypoints,
    this.width = 120,
    this.height = 120,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (keypoints == null || keypoints!.length < 21) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.gesture, color: Colors.grey, size: 30),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.deepPurple.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade100, width: 1),
      ),
      child: CustomPaint(
        painter: HandSkeletonPainter(keypoints: keypoints!),
      ),
    );
  }
}
