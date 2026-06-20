// lib/screens/mesh_relay_screen.dart
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
  int _currentStep = 0;
  int _relayCount = 0;
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

    _nearbyDeviceId = context.read<AppProvider>().currentAlert?.nearbyDeviceId ?? "DEV-AURA94";

    _runSimulation();
  }

  void _runSimulation() async {
    // Step 0: Scan nearby nodes
    setState(() => _currentStep = 0);
    await Future.delayed(const Duration(milliseconds: 1500));

    // Step 1: Calculate priorities & select node
    if (!mounted) return;
    setState(() => _currentStep = 1);
    _lineController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));

    // Step 2: Relay to priority node (Node C)
    if (!mounted) return;
    setState(() {
      _currentStep = 2;
      _relayCount = 1;
    });
    context.read<AppProvider>().updateAlertRelayCount(1);
    await Future.delayed(const Duration(milliseconds: 1500));

    // Step 3: Awaiting connectivity
    if (!mounted) return;
    setState(() {
      _currentStep = 3;
      _showContinue = true;
    });

    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/connectivity-restored');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Dynamic Mesh Routing'),
        leading: const SizedBox(),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.ink,
                      offset: Offset(3, 3),
                    )
                  ],
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
                    Expanded(
                      child: Column(
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
                                ? 'Analyzing priority nodes...'
                                : 'Alert successfully relayed!',
                            style: GoogleFonts.inter(
                              fontSize: 15,
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

              const SizedBox(height: 20),

              // Dynamic Priority Scoring Board
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.ink, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.ink,
                      offset: Offset(3, 3),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.orangeAccent),
                        const SizedBox(width: 8),
                        Text(
                          'Dynamic Routing Scoreboard',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Formula: (Battery * 0.4) + (Signal * 0.3) + (Mobility * 0.3)',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const Divider(color: AppColors.ink, thickness: 1.2, height: 20),
                    
                    // Node A
                    _buildScoreRow(
                      name: 'Aura Node A',
                      battery: '88%',
                      signal: '-62dBm',
                      mobility: 'Stationary',
                      score: '78',
                      isWinner: false,
                    ),
                    const SizedBox(height: 8),
                    // Node B
                    _buildScoreRow(
                      name: 'Aura Node B',
                      battery: '15%',
                      signal: '-89dBm',
                      mobility: 'Moving away',
                      score: '18',
                      isWinner: false,
                    ),
                    const SizedBox(height: 8),
                    // Node C
                    _buildScoreRow(
                      name: 'Aura Node C',
                      battery: '65%',
                      signal: '-70dBm',
                      mobility: 'Moving to Network',
                      score: '82',
                      isWinner: true,
                    ),

                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.ink, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.greenText, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Prioritized Node C: Best path selected due to active target convergence mobility.',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.greenDarker,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Mesh Visualization
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.ink, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.ink,
                      offset: Offset(3, 3),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Visual Hop Routing Path',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildMeshVisualization(),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Info Cards
              _buildInfoCard(
                Icons.analytics_rounded,
                'Optimal Path Selected',
                _currentStep >= 1 ? 'Target (You) -> Node C -> Gateway Device' : 'Analyzing priority scores...',
                AppColors.ink,
              ),

              const SizedBox(height: 12),
              _buildInfoCard(
                Icons.inventory_2_rounded,
                'Emergency Alert Packet',
                'Encrypted · 2.4 KB · Local Reverse-Block Encryption',
                const Color(0xFF8B5CF6),
              ),

              if (_relayCount > 0) ...[
                const SizedBox(height: 12),
                _buildInfoCard(
                  Icons.wifi_find_rounded,
                  'Gateway State',
                  'Forwarding packet: Monitoring for active network upload...',
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
                          'Uploading vault evidence to gateway...',
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

  Widget _buildScoreRow({
    required String name,
    required String battery,
    required String signal,
    required String mobility,
    required String score,
    required bool isWinner,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isWinner ? AppColors.greenLight : AppColors.canvas.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWinner ? AppColors.greenText : AppColors.ink,
          width: isWinner ? 1.8 : 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    if (isWinner) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.greenMain,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.ink, width: 1),
                        ),
                        child: Text(
                          'PRIORITY',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '🔋 $battery   📶 $signal   🏃 $mobility',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isWinner ? AppColors.greenMain : AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.ink, width: 1.2),
            ),
            child: Text(
              'Score: $score',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeshVisualization() {
    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildDeviceNode(
            label: 'You',
            icon: Icons.phone_android_rounded,
            color: AppColors.primary,
            isActive: _currentStep >= 0,
            isPulsing: _currentStep == 0,
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: _currentStep >= 2 ? AppColors.greenText : AppColors.textLight,
            size: 24,
          ),
          _buildDeviceNode(
            label: 'Node C (Relay)',
            icon: Icons.done_all_rounded,
            color: AppColors.greenText,
            isActive: _currentStep >= 2,
            isPulsing: _currentStep == 1,
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: _currentStep >= 3 ? AppColors.greenDarker : AppColors.textLight,
            size: 24,
          ),
          _buildDeviceNode(
            label: 'Gateway Device',
            icon: Icons.wifi_rounded,
            color: AppColors.greenDarker,
            isActive: _currentStep >= 3,
            isPulsing: _currentStep == 3,
          ),
        ],
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
                    width: 54 + (_pulseController.value * 16),
                    height: 54 + (_pulseController.value * 16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12 * (1 - _pulseController.value)),
                      shape: BoxShape.circle,
                    ),
                  ),
                child!,
              ],
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 48,
            height: 48,
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
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: isActive ? AppColors.ink : AppColors.textLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: 1.2),
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
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
