import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeviceMockupFrame extends StatelessWidget {
  final Widget child;

  const DeviceMockupFrame({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 580,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: const Color(0xFF0E0F0C),
          width: 8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28), // 36 border radius minus 8 border width
        child: Column(
          children: [
            // Simulated Status Bar
            Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '9:41',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0E0F0C),
                    ),
                  ),
                  Text(
                    '●●●',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0E0F0C),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            // Screen Content
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
