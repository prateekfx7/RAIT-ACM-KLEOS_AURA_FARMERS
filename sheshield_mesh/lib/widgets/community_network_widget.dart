import 'dart:math' as math;
import 'package:flutter/material.dart';

class CommunityNetworkWidget extends StatefulWidget {
  const CommunityNetworkWidget({super.key});

  @override
  State<CommunityNetworkWidget> createState() => _CommunityNetworkWidgetState();
}

class _CommunityNetworkWidgetState extends State<CommunityNetworkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 220,
        height: 220,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Custom Paint for Connection lines and Ripples
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _NetworkPainter(
                      progress: _controller.value,
                    ),
                  );
                },
              ),
            ),
            // Center location pin (📍)
            const Positioned(
              left: 90,
              top: 90,
              child: _NodeAvatar(
                icon: '📍',
                backgroundColor: Color(0xFFD03238),
                borderColor: Colors.transparent,
                size: 40,
                textColor: Colors.white,
              ),
            ),
            // User Node 1 (Top Left)
            const Positioned(
              left: 20,
              top: 30,
              child: _NodeAvatar(
                icon: '👤',
                backgroundColor: Color(0xFFE2F6D5),
                borderColor: Color(0xFF9FE870),
                size: 34,
              ),
            ),
            // User Node 2 (Top Right)
            const Positioned(
              left: 160,
              top: 20,
              child: _NodeAvatar(
                icon: '👤',
                backgroundColor: Color(0xFFE2F6D5),
                borderColor: Color(0xFF9FE870),
                size: 34,
              ),
            ),
            // User Node 3 (Bottom Right)
            const Positioned(
              left: 175,
              top: 140,
              child: _NodeAvatar(
                icon: '👤',
                backgroundColor: Color(0xFFE2F6D5),
                borderColor: Color(0xFF9FE870),
                size: 34,
              ),
            ),
            // User Node 4 (Bottom Left - Inactive/Relaying)
            const Positioned(
              left: 15,
              top: 150,
              child: _NodeAvatar(
                icon: '👤',
                backgroundColor: Color(0xFFE8EBE6),
                borderColor: Color(0xFF868685),
                size: 34,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NodeAvatar extends StatelessWidget {
  final String icon;
  final Color backgroundColor;
  final Color borderColor;
  final double size;
  final Color? textColor;

  const _NodeAvatar({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.size,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: borderColor == Colors.transparent
            ? null
            : Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(
            fontSize: size * 0.45,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _NetworkPainter extends CustomPainter {
  final double progress;

  _NetworkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Node locations (matching coordinates in UI)
    final nodes = [
      const Offset(20 + 17, 30 + 17),    // Node 1 (Center: x = left + radius, y = top + radius)
      const Offset(160 + 17, 20 + 17),   // Node 2
      const Offset(175 + 17, 140 + 17),  // Node 3
      const Offset(15 + 17, 150 + 17),   // Node 4
    ];

    final isGreen = [true, true, true, false]; // Nodes 1, 2, 3 are green; Node 4 is grey

    // 1. Draw animated signal ripples from center
    final ripplePaint = Paint()
      ..color = const Color(0xFF9FE870).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Ripple 1
    double r1 = (progress * 110) % 110;
    ripplePaint.color = const Color(0xFF9FE870).withOpacity((1 - r1 / 110) * 0.25);
    canvas.drawCircle(center, r1, ripplePaint);

    // Ripple 2
    double r2 = ((progress + 0.5) * 110) % 110;
    ripplePaint.color = const Color(0xFF9FE870).withOpacity((1 - r2 / 110) * 0.25);
    canvas.drawCircle(center, r2, ripplePaint);

    // 2. Draw dashed lines from center to nodes
    for (int i = 0; i < nodes.length; i++) {
      final pColor = isGreen[i] ? const Color(0xFF9FE870) : const Color(0xFFCBD1C5);
      final linePaint = Paint()
        ..color = pColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      _drawDashedLine(canvas, center, nodes[i], linePaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    final distance = (p2 - p1).distance;
    final direction = (p2 - p1) / distance;
    
    double currentDistance = 0.0;
    
    // Shift dashes slightly over time for animated flow
    final offset = (progress * (dashWidth + dashSpace)) % (dashWidth + dashSpace);
    currentDistance += offset;

    while (currentDistance < distance) {
      final start = p1 + direction * currentDistance;
      final end = p1 + direction * math.min(currentDistance + dashWidth, distance);
      canvas.drawLine(start, end, paint);
      currentDistance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_NetworkPainter oldDelegate) => oldDelegate.progress != progress;
}
