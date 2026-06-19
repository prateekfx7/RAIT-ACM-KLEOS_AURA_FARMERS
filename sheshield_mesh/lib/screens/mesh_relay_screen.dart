import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';

class MeshRelayScreen extends StatefulWidget {
  const MeshRelayScreen({super.key});

  @override
  State<MeshRelayScreen> createState() => _MeshRelayScreenState();
}

class _MeshRelayScreenState extends State<MeshRelayScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _lineController;
  late AnimationController _stepsController;

  int _currentStep = 0;
  int _relayCount = 0;
  final List<String> _stepLabels = [
    'Your Device',
    'Nearby Device Found',
    'Relay Successful',
    'Awaiting Connectivity',
  ];
  final List<IconData> _stepIcons = [
    Icons.phone_android_rounded,
    Icons.devices_other_rounded,
    Icons.done_all_rounded,
    Icons.wifi_find_rounded,
  ];
  final List<Color> _stepColors = [
    AppColors.primary,
    const Color(0xFF8B5CF6),
    AppColors.success,
    AppColors.warning,
  ];

  bool _showContinue = false;
  String? _nearbyDeviceId;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _stepsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _nearbyDeviceId = context.read<AppProvider>().currentAlert?.nearbyDeviceId;

    _runSimulation();
  }

  void _runSimulation() async {
    // Step 0: Your device
    setState(() => _currentStep = 0);
    await Future.delayed(const Duration(milliseconds: 800));

    // Step 1: Nearby device found
    if (!mounted) return;
    setState(() => _currentStep = 1);
    _lineController.forward();
    await Future.delayed(const Duration(milliseconds: 900));

    // Step 2: Relay successful
    if (!mounted) return;
    setState(() {
      _currentStep = 2;
      _relayCount = 1;
    });
    context.read<AppProvider>().updateAlertRelayCount(1);
    await Future.delayed(const Duration(milliseconds: 900));

    // Step 3: Awaiting connectivity
    if (!mounted) return;
    setState(() {
      _currentStep = 3;
      _showContinue = true;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _lineController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Mesh Relay'),
        leading: const SizedBox(),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Relay Count Badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.08),
                      const Color(0xFF8B5CF6).withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '$_relayCount',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Relay Count',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.muted,
                          ),
                        ),
                        Text(
                          _relayCount == 0
                              ? 'Searching for nearby devices...'
                              : 'Alert successfully relayed!',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Mesh Visualization
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Column(
                  children: [
                    Text(
                      'Mesh Relay Simulation',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Device visualization
                    _buildMeshVisualization(),

                    const SizedBox(height: 24),

                    // Step indicators
                    ...List.generate(_stepLabels.length, (i) {
                      return _buildStepItem(i);
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Info Cards
              if (_nearbyDeviceId != null && _currentStep >= 1)
                _buildInfoCard(
                  Icons.devices_other_rounded,
                  'Nearby Device ID',
                  _nearbyDeviceId!,
                  AppColors.primary,
                ),

              if (_currentStep >= 1) ...[
                const SizedBox(height: 12),
                _buildInfoCard(
                  Icons.inventory_2_rounded,
                  'Alert Packet',
                  'Encrypted · 2.4 KB · AES-256',
                  const Color(0xFF8B5CF6),
                ),
              ],

              if (_currentStep >= 2) ...[
                const SizedBox(height: 12),
                _buildInfoCard(
                  Icons.check_circle_rounded,
                  'Signal Status',
                  'Successfully Relayed via Bluetooth LE',
                  AppColors.success,
                ),
              ],

              if (_currentStep >= 3) ...[
                const SizedBox(height: 12),
                _buildInfoCard(
                  Icons.wifi_find_rounded,
                  'Connectivity',
                  'Monitoring for internet access...',
                  AppColors.warning,
                ),
              ],

              const SizedBox(height: 28),

              // Continue Button
              AnimatedOpacity(
                opacity: _showContinue ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: AnimatedSlide(
                  offset: _showContinue ? Offset.zero : const Offset(0, 0.2),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  child: ElevatedButton.icon(
                    onPressed: _showContinue
                        ? () => Navigator.of(context)
                            .pushReplacementNamed('/connectivity-restored')
                        : null,
                    icon: const Icon(Icons.wifi_rounded, size: 18),
                    label: const Text('Continue Simulation'),
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
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeshVisualization() {
    return SizedBox(
      height: 200,
      child: CustomPaint(
        size: const Size(double.infinity, 200),
        painter: _MeshPainter(
          step: _currentStep,
          animation: _pulseController,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildDeviceNode(
              label: 'Your Device',
              icon: Icons.phone_android_rounded,
              color: AppColors.primary,
              isActive: _currentStep >= 0,
              isPulsing: _currentStep == 0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _lineController,
                  builder: (context, _) {
                    return Icon(
                      Icons.arrow_downward_rounded,
                      color: _currentStep >= 1
                          ? AppColors.primary
                          : AppColors.hairline,
                      size: 20,
                    );
                  },
                ),
              ],
            ),
            _buildDeviceNode(
              label: 'Relay Device',
              icon: Icons.devices_other_rounded,
              color: const Color(0xFF8B5CF6),
              isActive: _currentStep >= 1,
              isPulsing: _currentStep == 1,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_downward_rounded,
                  color: _currentStep >= 2 ? AppColors.success : AppColors.hairline,
                  size: 20,
                ),
              ],
            ),
            _buildDeviceNode(
              label: 'Network',
              icon: Icons.wifi_rounded,
              color: AppColors.success,
              isActive: _currentStep >= 3,
              isPulsing: _currentStep == 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceNode({
    required String label,
    required IconData icon,
    required Color color,
    required bool isActive,
    required bool isPulsing,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                if (isPulsing)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 60 + (_pulseController.value * 20),
                    height: 60 + (_pulseController.value * 20),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1 * (1 - _pulseController.value)),
                      shape: BoxShape.circle,
                    ),
                  ),
                child!,
              ],
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isActive ? color : AppColors.hairlineSoft,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : AppColors.mutedSoft,
              size: 22,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isActive ? color : AppColors.mutedSoft,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepItem(int index) {
    final isCompleted = _currentStep > index;
    final isCurrent = _currentStep == index;
    final isUpcoming = _currentStep < index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success
                  : isCurrent
                      ? _stepColors[index]
                      : AppColors.hairline,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : _stepIcons[index],
              size: 14,
              color: isUpcoming ? AppColors.mutedSoft : Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _stepLabels[index],
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isUpcoming ? AppColors.mutedSoft : AppColors.ink,
              ),
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _stepColors[index].withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Active',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _stepColors[index],
                ),
              ),
            ),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Done',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value2, child) {
        return Opacity(
          opacity: value2,
          child: Transform.translate(
            offset: Offset(0, (1 - value2) * 12),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
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
        ),
      ),
    );
  }
}

class _MeshPainter extends CustomPainter {
  final int step;
  final Animation<double> animation;

  _MeshPainter({required this.step, required this.animation})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw connecting lines between device nodes
    final paint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (step >= 1) {
      paint.color = AppColors.primary.withOpacity(0.3 + animation.value * 0.2);
      // Line from your device to relay device would be drawn here
      // The actual device nodes are drawn by the widget tree
    }
  }

  @override
  bool shouldRepaint(_MeshPainter oldDelegate) => true;
}
