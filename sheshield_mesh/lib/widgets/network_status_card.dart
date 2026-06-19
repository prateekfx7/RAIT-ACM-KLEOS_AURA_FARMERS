import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';

class NetworkStatusCard extends StatefulWidget {
  const NetworkStatusCard({super.key});

  @override
  State<NetworkStatusCard> createState() => _NetworkStatusCardState();
}

class _NetworkStatusCardState extends State<NetworkStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<AppProvider>().isOnline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isOnline ? AppColors.successLight : AppColors.errorLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOnline
              ? AppColors.success.withOpacity(0.3)
              : AppColors.error.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  if (!isOnline)
                    Container(
                      width: 44 + _pulseController.value * 12,
                      height: 44 + _pulseController.value * 12,
                      decoration: BoxDecoration(
                        color: AppColors.error
                            .withOpacity(0.08 * (1 - _pulseController.value)),
                        shape: BoxShape.circle,
                      ),
                    ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isOnline ? AppColors.success : AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Network Status',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isOnline ? AppColors.success : AppColors.error,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    isOnline ? 'Connected to Internet' : 'No Internet Connection',
                    key: ValueKey(isOnline),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isOnline ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isOnline
                      ? 'All emergency channels active'
                      : 'Mesh relay mode active',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isOnline
                        ? AppColors.success.withOpacity(0.7)
                        : AppColors.error.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.success : AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isOnline ? 'LIVE' : 'MESH',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isOnline ? AppColors.success : AppColors.error,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
