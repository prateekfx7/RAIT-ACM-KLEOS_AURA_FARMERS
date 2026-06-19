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
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
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
                            color: AppColors.success.withOpacity(
                                _uploadComplete ? 1.0 : 0.6 + _wifiController.value * 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _uploadComplete
                                ? Icons.cloud_done_rounded
                                : Icons.wifi_rounded,
                            color: Colors.white,
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
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            _uploadComplete
                                ? 'Alert synced to emergency servers'
                                : 'Uploading emergency alert...',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.body,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _uploadComplete ? 'Upload Complete' : 'Uploading Emergency Alert',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
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
                                backgroundColor: AppColors.hairlineSoft,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _uploadComplete
                                      ? AppColors.success
                                      : AppColors.primary,
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
                                  color: AppColors.success,
                                  size: 36,
                                ),
                              )
                            else
                              Text(
                                '$_displayPercent%',
                                style: GoogleFonts.inter(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
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
                                color: isDone ? AppColors.success : AppColors.hairline,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                size: 12,
                                color: isDone ? Colors.white : AppColors.mutedSoft,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$m%',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDone ? AppColors.success : AppColors.mutedSoft,
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
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '✓  Alert Synced Successfully',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            )
                          : Text(
                              key: const ValueKey('uploading'),
                              'Uploading encrypted alert packet...',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.muted,
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

              // Notify contacts button
              AnimatedOpacity(
                opacity: _uploadComplete ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: ElevatedButton.icon(
                  onPressed: _uploadComplete
                      ? () {
                          context.read<AppProvider>().deliverAlert();
                          Navigator.of(context)
                              .pushReplacementNamed('/alert-delivered');
                        }
                      : null,
                  icon: const Icon(Icons.notifications_rounded, size: 18),
                  label: const Text('Notify Contacts'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Signal Path',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          _pathNode(
            Icons.phone_android_rounded,
            'Your Device',
            'Alert originated here',
            AppColors.primary,
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
            const Color(0xFF3B82F6),
            _displayPercent >= 75,
          ),
          _pathConnector(_displayPercent >= 75),
          _pathNode(
            Icons.local_hospital_rounded,
            'Emergency Responder',
            _uploadComplete ? 'Alert received & processed' : 'Awaiting upload...',
            AppColors.success,
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
            color: isActive ? color : AppColors.hairline,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: isActive ? Colors.white : AppColors.mutedSoft, size: 18),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.ink : AppColors.muted,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isActive ? AppColors.body : AppColors.mutedSoft,
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
        color: isActive ? AppColors.primary.withOpacity(0.3) : AppColors.hairline,
      ),
    );
  }
}
