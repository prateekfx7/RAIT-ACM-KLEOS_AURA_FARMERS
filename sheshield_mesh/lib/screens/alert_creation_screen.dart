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
                  color: _step == 1 ? AppColors.successLight : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _step == 1
                        ? AppColors.success.withOpacity(0.3)
                        : AppColors.primary.withOpacity(0.2),
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
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
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 16),
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
                              fontWeight: FontWeight.w700,
                              color: _step == 1 ? AppColors.success : AppColors.primary,
                            ),
                          ),
                          Text(
                            _step == 0
                                ? 'Preparing your emergency packet'
                                : 'Stored offline, ready for relay',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.muted,
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
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.hairline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alert Details',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _detailRow(
                      Icons.fingerprint_rounded,
                      'Alert ID',
                      alert?.id ?? 'Generating...',
                      AppColors.primary,
                    ),
                    const Divider(height: 24, color: AppColors.hairlineSoft),
                    _detailRow(
                      Icons.access_time_rounded,
                      'Timestamp',
                      formatter.format(now),
                      AppColors.body,
                    ),
                    const Divider(height: 24, color: AppColors.hairlineSoft),
                    _detailRow(
                      Icons.location_on_rounded,
                      'Live Location',
                      alert?.location ?? provider.liveLocation,
                      const Color(0xFF10B981),
                    ),
                    const Divider(height: 24, color: AppColors.hairlineSoft),
                    _detailRow(
                      Icons.offline_bolt_rounded,
                      'Network Status',
                      'No Internet — Offline Mode',
                      AppColors.error,
                    ),
                    const Divider(height: 24, color: AppColors.hairlineSoft),
                    _detailRow(
                      Icons.save_rounded,
                      'Storage',
                      'Stored Locally',
                      AppColors.warning,
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
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity Log',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
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
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  color: AppColors.body,
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
                            decoration: const BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
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
                              color: AppColors.muted,
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
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
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
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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
