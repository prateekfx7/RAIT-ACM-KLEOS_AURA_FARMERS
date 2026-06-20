import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';

class ConnectivityRestoredScreen extends StatefulWidget {
  const ConnectivityRestoredScreen({super.key});

  @override
  State<ConnectivityRestoredScreen> createState() =>
      _ConnectivityRestoredScreenState();
}

class _ConnectivityRestoredScreenState extends State<ConnectivityRestoredScreen>
    with TickerProviderStateMixin {
  late AnimationController _uploadController;
  late AnimationController _wifiController;
  late AnimationController _successController;

  double _uploadProgress = 0.0;
  bool _uploadComplete = false;
  int _displayPercent = 0;
  final List<int> _milestones = [0, 25, 50, 75, 100];

  @override
  void initState() {
    super.initState();

    _uploadController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _wifiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _runUpload();
  }

  void _runUpload() async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Animate through milestones
    for (int i = 1; i < _milestones.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 700));
      setState(() {
        _uploadProgress = _milestones[i] / 100.0;
        _displayPercent = _milestones[i];
      });
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _uploadComplete = true);
    _wifiController.stop();
    _successController.forward();
    context.read<AppProvider>().setOnline(true);

    // Auto-navigate to Alert Delivered screen after upload is complete
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    context.read<AppProvider>().deliverAlert();
    Navigator.of(context).pushReplacementNamed('/alert-delivered');
  }

  @override
  void dispose() {
    _uploadController.dispose();
    _wifiController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Connectivity Restored'),
        leading: const SizedBox(),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Internet Available Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.ink,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedBuilder(
                      animation: _wifiController,
                      builder: (context, child) {
                        return Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.greenMain,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.ink,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            _uploadComplete
                                ? Icons.cloud_done_rounded
                                : Icons.wifi_rounded,
                            color: AppColors.ink,
                            size: 22,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Internet Available',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            _uploadComplete
                                ? 'Alert synced to emergency servers'
                                : 'Uploading emergency alert...',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.greenDarker,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Upload Progress Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.ink, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _uploadComplete ? 'Upload Complete' : 'Uploading Emergency Alert',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Progress circle
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: AnimatedBuilder(
                            animation: _successController,
                            builder: (context, _) {
                              return CircularProgressIndicator(
                                value: _uploadProgress,
                                strokeWidth: 8,
                                backgroundColor: AppColors.canvas,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _uploadComplete
                                      ? AppColors.greenMain
                                      : AppColors.redMain,
                                ),
                                strokeCap: StrokeCap.round,
                              );
                            },
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_uploadComplete)
                              ScaleTransition(
                                scale: CurvedAnimation(
                                  parent: _successController,
                                  curve: Curves.elasticOut,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.greenDarker,
                                  size: 36,
                                ),
                              )
                            else
                              Text(
                                '$_displayPercent%',
                                style: GoogleFonts.inter(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.redMain,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Milestone indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _milestones.map((m) {
                        final isDone = _displayPercent >= m;
                        return Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isDone ? AppColors.greenMain : AppColors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.ink,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.check,
                                size: 12,
                                color: isDone ? AppColors.ink : AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$m%',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: isDone ? AppColors.greenDarker : AppColors.textLight,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Status text
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _uploadComplete
                          ? Container(
                              key: const ValueKey('done'),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.greenLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.ink, width: 1),
                              ),
                              child: Text(
                                '✓  Alert Synced Successfully',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.greenDarker,
                                ),
                              ),
                            )
                          : Text(
                              key: const ValueKey('uploading'),
                              'Uploading encrypted alert packet...',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Signal path
              _buildSignalPath(),

              const SizedBox(height: 28),

              // Automated progression indicator
              AnimatedOpacity(
                opacity: _uploadComplete ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.greenLight,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.ink),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Notifying contacts automatically...',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignalPath() {
    return Container(
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
            'Signal Path',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          _pathNode(
            Icons.phone_android_rounded,
            'Your Device',
            'Alert originated here',
            AppColors.redMain,
            true,
          ),
          _pathConnector(true),
          _pathNode(
            Icons.devices_other_rounded,
            'Relay Device',
            'Packet forwarded via Bluetooth',
            const Color(0xFF8B5CF6),
            _displayPercent >= 25,
          ),
          _pathConnector(_displayPercent >= 25),
          _pathNode(
            Icons.cloud_rounded,
            'Emergency Servers',
            'Uploading to responder network',
            AppColors.ink,
            _displayPercent >= 75,
          ),
          _pathConnector(_displayPercent >= 75),
          _pathNode(
            Icons.local_hospital_rounded,
            'Emergency Responder',
            _uploadComplete ? 'Alert received & processed' : 'Awaiting upload...',
            AppColors.greenText,
            _uploadComplete,
          ),
        ],
      ),
    );
  }

  Widget _pathNode(IconData icon, String title, String subtitle, Color color, bool isActive) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? color : AppColors.canvas,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.ink, width: 1.5),
          ),
          child: Icon(
            icon,
            color: isActive
                ? (color == AppColors.ink ? Colors.white : AppColors.ink)
                : AppColors.textLight,
            size: 18,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isActive ? AppColors.ink : AppColors.textLight,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.textMuted : AppColors.textLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pathConnector(bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(left: 17),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 2,
        height: 20,
        color: isActive ? AppColors.ink : AppColors.textLight.withValues(alpha: 0.3),
      ),
    );
  }
}
