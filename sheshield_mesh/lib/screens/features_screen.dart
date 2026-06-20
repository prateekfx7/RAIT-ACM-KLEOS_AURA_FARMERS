import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/device_mockup_frame.dart';
import '../widgets/community_network_widget.dart';

class FeaturesScreen extends StatefulWidget {
  const FeaturesScreen({super.key});

  @override
  State<FeaturesScreen> createState() => _FeaturesScreenState();
}

class _FeaturesScreenState extends State<FeaturesScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<String> _titles = [
    'Offline SOS',
    'Mesh Relay',
    'Shake-to-SOS',
    'Trusted Contacts',
    'Safe Beacon Mode',
    'Community Rescue',
  ];

  final List<String> _descriptions = [
    'Save SOS alert data locally without any internet connection.',
    'Relay emergency signals hop-by-hop from device to device.',
    'Firmly shake your device 3 times to trigger hands-free SOS activation.',
    'Add contacts to be notified automatically once connectivity is restored.',
    'Start a proactive tracking session before entering risky situations.',
    'Contribute and benefit from a decentralized emergency relay network.',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Safety Features'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header Intro
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mesh Protocol Prototype',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.redMain,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _titles[_currentPage],
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 38,
                    child: Text(
                      _descriptions[_currentPage],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Horizontally Swipable Mockup PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: 6,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                        value = (1 - (value.abs() * 0.08)).clamp(0.9, 1.0);
                      }
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Center(
                        child: DeviceMockupFrame(
                          child: _buildMockupContent(index),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                final active = _currentPage == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.redMain : AppColors.ink.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: active ? AppColors.ink : Colors.transparent,
                      width: 1,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMockupContent(int index) {
    switch (index) {
      case 0:
        return _buildCard1();
      case 1:
        return _buildCard2();
      case 2:
        return _buildCard3();
      case 3:
        return _buildCard4();
      case 4:
        return _buildCard5();
      case 5:
        return _buildCard6();
      default:
        return Container();
    }
  }

  Widget _buildCard1() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Offline SOS',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.ink),
          ),
          Text(
            'No internet needed',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.redLight,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: AppColors.ink, width: 1),
            ),
            child: Text(
              '● No connectivity detected',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.redDark),
            ),
          ),
          const Spacer(),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.redMain,
                border: Border.all(color: AppColors.ink, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.ink,
                    blurRadius: 0,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SOS',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    Text(
                      'Single Tap',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STORED LOCALLY',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.greenMain, letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                Text(
                  'Alert ID, timestamp & last known location are saved on-device the instant you press SOS — before any network is needed.',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard2() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mesh Relay',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.ink),
          ),
          Text(
            'Signal hops device to device',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.ink, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.ink,
                  blurRadius: 0,
                  offset: Offset(3, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildRelayStep('📱', 'Your device', 'SOS created', AppColors.redLight, AppColors.redDark),
                _buildRelayDivider(),
                _buildRelayStep('📡', 'Nearby device', 'Relayed via Bluetooth LE', AppColors.greenLight, AppColors.greenText),
                _buildRelayDivider(),
                _buildRelayStep('☁️', 'Backend', 'Awaiting connectivity', AppColors.canvas, AppColors.textLight),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.greenLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.ink, width: 1.2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '3',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.greenDark),
                      ),
                      Text(
                        'nodes in range',
                        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.greenLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.ink, width: 1.2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'BLE',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.greenDark),
                      ),
                      Text(
                        '+ Nearby API',
                        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRelayStep(String emoji, String title, String subtitle, Color bg, Color textColor) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.ink, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 14)),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.ink),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: textColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRelayDivider() {
    return Container(
      width: 2,
      height: 16,
      color: AppColors.ink,
      margin: const EdgeInsets.only(left: 15, top: 2, bottom: 2),
    );
  }

  Widget _buildCard3() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shake-to-SOS',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.ink),
          ),
          Text(
            'Hands-free activation',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
          const Spacer(),
          Center(
            child: SizedBox(
              width: 110,
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.redLight.withValues(alpha: 0.6),
                      border: Border.all(color: AppColors.ink, width: 1),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.redMedium.withValues(alpha: 0.7),
                      border: Border.all(color: AppColors.ink, width: 1),
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.redMain,
                      border: Border.all(color: AppColors.ink, width: 1.5),
                    ),
                    child: const Center(
                      child: Text('📳', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Shake 3× firmly to trigger',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.ink),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.ink, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.ink,
                  blurRadius: 0,
                  offset: Offset(3, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sensitivity',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.ink),
                    ),
                    Text(
                      'Medium',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: AppColors.ink, width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 55,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.redMain,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const Spacer(flex: 45),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.ink, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.ink,
                  blurRadius: 0,
                  offset: Offset(3, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cancel countdown',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.ink),
                ),
                Text(
                  '5s',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.redDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard4() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trusted Contacts',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.ink),
          ),
          Text(
            'Notified once network returns',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.ink, width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.greenMain,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Text('P', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppColors.ink)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Priya Sharma', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.ink)),
                      Text('Sister', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.ink, width: 1),
                  ),
                  child: Text('Queued', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.greenDarker)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.ink, width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.greenMedium,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Text('R', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppColors.ink)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ravi Mehta', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.ink)),
                      Text('Friend', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.ink, width: 1),
                  ),
                  child: Text('Queued', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.ink, width: 1.5),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.ink,
                  blurRadius: 0,
                  offset: Offset(3, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '+ Add contact (1 slot left)',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.ink),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.redLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.ink, width: 1.2),
            ),
            child: Row(
              children: [
                const Text('📶', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Connectivity restored — sending alerts now',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.redDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard5() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Safe Beacon',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.ink),
          ),
          Text(
            'Proactive safety session',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.greenDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.ink, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SESSION ACTIVE',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.greenMedium, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  '14:32 elapsed',
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.greenMain),
                ),
                const SizedBox(height: 2),
                Text(
                  'Walking home · started 9:28 PM',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.greenMedium),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.greenLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.ink, width: 1.2),
                  ),
                  child: Column(
                    children: [
                      const Text('📍', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        'Location logged',
                        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.ink),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.greenLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.ink, width: 1.2),
                  ),
                  child: Column(
                    children: [
                      const Text('⏱', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        'Timestamps stored',
                        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.ink),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.redLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.ink, width: 1.2),
            ),
            child: Text(
              'If an SOS triggers during this session, your beacon history attaches automatically.',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.redDark, height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.redMain,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: AppColors.ink, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              'End session',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard6() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Rescue',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.ink),
          ),
          Text(
            'Decentralized relay network',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
          const Spacer(),
          const SizedBox(
            height: 150,
            child: CommunityNetworkWidget(),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.ink, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '3 community nodes confirmed relay',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.greenDark),
                ),
                const SizedBox(height: 2),
                Text(
                  'Each hop strengthens reach without needing telecom infra',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.redLight,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: AppColors.ink, width: 1),
            ),
            child: Text(
              '● Your SOS is part of someone\'s relay too',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.redDark),
            ),
          ),
        ],
      ),
    );
  }
}
