import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SOSButton extends StatefulWidget {
  final VoidCallback onPressed;

  const SOSButton({super.key, required this.onPressed});

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _pressController;
  late Animation<double> _pulseAnim;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pressScale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handlePress() async {
    HapticFeedback.heavyImpact();
    await _pressController.forward();
    await _pressController.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _pressController]),
      builder: (context, child) {
        return GestureDetector(
          onTap: _handlePress,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rings
              ...List.generate(3, (i) {
                final delay = i * 0.25;
                final value = ((_pulseController.value + delay) % 1.0);
                return Transform.scale(
                  scale: _pressScale.value,
                  child: Container(
                    width: 130 + i * 30 + value * 20,
                    height: 130 + i * 30 + value * 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.error
                          .withOpacity((0.12 - i * 0.03) * (1 - value * 0.5)),
                    ),
                  ),
                );
              }),
              // Main button
              Transform.scale(
                scale: _pressScale.value * _pulseAnim.value,
                child: child,
              ),
            ],
          ),
        );
      },
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            colors: [
              Color(0xFFFF4444),
              AppColors.error,
            ],
            center: Alignment(-0.3, -0.3),
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: AppColors.error.withOpacity(0.2),
              blurRadius: 40,
              offset: const Offset(0, 16),
              spreadRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sos_rounded,
              color: Colors.white,
              size: 42,
            ),
            const SizedBox(height: 4),
            Text(
              'PRESS & HOLD',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.85),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
