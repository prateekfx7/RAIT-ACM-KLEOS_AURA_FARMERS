import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import 'package:intl/intl.dart';

class AlertCreationScreen extends StatefulWidget {
  const AlertCreationScreen({super.key});

  @override
  State<AlertCreationScreen> createState() => _AlertCreationScreenState();
}

class _AlertCreationScreenState extends State<AlertCreationScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _checkController;
  int _step = 0; // 0=loading, 1=done
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _runSimulation();
  }

  void _runSimulation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _logs.add('Generating unique Alert ID...'));

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _logs.add('Capturing timestamp...'));

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _logs.add('Fetching last known location...'));

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _logs.add('Encrypting alert packet...');
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _logs.add('Storing offline — ready for relay');
      _step = 1;
    });
    _shimmerController.stop();
    _checkController.forward();
    context.read<AppProvider>().updateAlertStatus('Stored Offline');

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/mesh-relay');
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final alert = provider.currentAlert;
    final now = DateTime.now();
    final formatter = DateFormat('dd MMM yyyy, HH:mm:ss');

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Creating Alert'),
        leading: const SizedBox(), // no back during creation
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _step == 1 ? AppColors.greenLight : AppColors.redLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.ink,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    if (_step == 0)
                      AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, _) {
                          return SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.ink,
                              ),
                              value: _shimmerController.value,
                            ),
                          );
                        },
                      )
                    else
                      ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _checkController,
                          curve: Curves.elasticOut,
                        ),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.greenMain,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: AppColors.ink, size: 16),
                        ),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _step == 0 ? 'Generating Alert...' : 'Alert Created',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            _step == 0
                                ? 'Preparing your emergency packet'
                                : 'Stored offline, ready for relay',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _step == 1 ? AppColors.greenDarker : AppColors.redDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Alert Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.ink, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alert Details',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _detailRow(
                      Icons.fingerprint_rounded,
                      'Alert ID',
                      alert?.id ?? 'Generating...',
                      AppColors.ink,
                    ),
                    const Divider(height: 24, color: Color(0x1F000000)),
                    _detailRow(
                      Icons.access_time_rounded,
                      'Timestamp',
                      formatter.format(now),
                      AppColors.textMuted,
                    ),
                    const Divider(height: 24, color: Color(0x1F000000)),
                    _detailRow(
                      Icons.location_on_rounded,
                      'Live Location',
                      alert?.location ?? provider.liveLocation,
                      AppColors.greenText,
                    ),
                    const Divider(height: 24, color: Color(0x1F000000)),
                    _detailRow(
                      Icons.offline_bolt_rounded,
                      'Network Status',
                      'No Internet — Offline Mode',
                      AppColors.redMain,
                    ),
                    const Divider(height: 24, color: Color(0x1F000000)),
                    _detailRow(
                      Icons.save_rounded,
                      'Storage',
                      'Stored Locally',
                      AppColors.greenDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Activity Log
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.ink, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity Log',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._logs.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              margin: const EdgeInsets.only(top: 1),
                              decoration: BoxDecoration(
                                color: AppColors.greenMain,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.ink, width: 1),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: AppColors.ink,
                                size: 10,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (_step == 0 && _logs.isNotEmpty)
                      Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.redLight,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.ink, width: 1),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 8,
                                height: 8,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.ink,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Processing...',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.redDark,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.ink, width: 1),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
