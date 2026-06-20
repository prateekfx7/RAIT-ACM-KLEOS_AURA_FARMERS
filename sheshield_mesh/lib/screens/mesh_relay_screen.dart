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
    AppColors.redMain,
    const Color(0xFF8B5CF6),
    AppColors.greenText,
    AppColors.greenDarker,
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

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/connectivity-restored');
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
                  color: _relayCount == 0 ? AppColors.redLight : AppColors.greenLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.ink,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _relayCount == 0 ? AppColors.redMain : AppColors.greenMain,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.ink,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$_relayCount',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: _relayCount == 0 ? Colors.white : AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Relay Hops',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _relayCount == 0 ? AppColors.redDark : AppColors.greenDarker,
                          ),
                        ),
                        Text(
                          _relayCount == 0
                              ? 'Searching for nearby devices...'
                              : 'Alert successfully relayed!',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
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
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.ink, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      'Mesh Relay Simulation',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
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
                  AppColors.ink,
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
                  AppColors.greenText,
                ),
              ],

              if (_currentStep >= 3) ...[
                const SizedBox(height: 12),
                _buildInfoCard(
                  Icons.wifi_find_rounded,
                  'Connectivity',
                  'Monitoring for internet access...',
                  AppColors.redMain,
                ),
              ],

              const SizedBox(height: 28),

              // Automated progression indicator
              AnimatedOpacity(
                opacity: _showContinue ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: AnimatedSlide(
                  offset: _showContinue ? Offset.zero : const Offset(0, 0.2),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
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
                          'Proceeding automatically...',
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
                      color: color.withValues(alpha: 0.1 * (1 - _pulseController.value)),
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
              color: isActive ? color : AppColors.canvas,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.ink,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : AppColors.textLight,
              size: 22,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isActive ? AppColors.ink : AppColors.textLight,
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

    final Color itemColor = isCompleted
        ? AppColors.greenMain
        : isCurrent
            ? _stepColors[index]
            : AppColors.white;

    final Color iconColor = isCompleted
        ? AppColors.ink
        : isCurrent
            ? Colors.white
            : AppColors.textLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: itemColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.ink,
                width: 1.5,
              ),
            ),
            child: Icon(
              isCompleted ? Icons.check : _stepIcons[index],
              size: 14,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _stepLabels[index],
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                color: isUpcoming ? AppColors.textLight : AppColors.ink,
              ),
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _stepColors[index].withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.ink, width: 1),
              ),
              child: Text(
                'Active',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: _stepColors[index],
                ),
              ),
            ),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.ink, width: 1),
              ),
              child: Text(
                'Done',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.greenDarker,
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
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.ink, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.ink, width: 1),
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
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight,
                    ),
                  ),
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
