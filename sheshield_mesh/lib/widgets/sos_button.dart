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
    );

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
                    width: 140 + i * 30 + value * 20,
                    height: 140 + i * 30 + value * 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.redMain
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
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.redMain,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.redMain.withOpacity(0.45),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SOS',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Single Tap',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
