import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/network_status_card.dart';
import '../widgets/sos_button.dart';
import '../widgets/quick_action_card.dart';
import 'features_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void _fetchLocationAndPrompt(AppProvider provider) async {
    await provider.fetchLiveLocation();
    if (mounted && provider.isLastLocationIpFallback) {
      _showIpLocationSuccessDialog(context, provider.liveLocation);
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch real location via browser Geolocation API on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocationAndPrompt(context.read<AppProvider>());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _animated(int idx, Widget child) {
    return child;
  }

  void _showSafeBeaconSheet(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final active = provider.isSafeBeaconActive;
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: AppColors.ink, width: 1.5),
                  left: BorderSide(color: AppColors.ink, width: 1.5),
                  right: BorderSide(color: AppColors.ink, width: 1.5),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.ink.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Safe Beacon Mode',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create a proactive safety session before entering risky environments.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (active) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.greenDark,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.ink, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SESSION ACTIVE',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.greenMain,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${provider.safeBeaconElapsedTime} elapsed',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.greenMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Walking home · ${provider.safeBeaconStartTimeText}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.greenMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.greenLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.ink, width: 1.2),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.location_on_rounded, color: AppColors.greenDarker, size: 20),
                                const SizedBox(height: 4),
                                Text(
                                  'Location Logged',
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ink),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.greenLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.ink, width: 1.2),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.access_time_filled_rounded, color: AppColors.greenDarker, size: 20),
                                const SizedBox(height: 4),
                                Text(
                                  'Timestamps Stored',
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ink),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.redLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.ink, width: 1.2),
                      ),
                      child: Text(
                        'If an SOS triggers during this session, your beacon history attaches automatically.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.redDark,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        provider.toggleSafeBeacon();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.redMain,
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
                        alignment: Alignment.center,
                        child: Text(
                          'End Session',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
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
                          const Icon(Icons.shield_outlined, color: AppColors.textLight, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            'Session Inactive',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Safe Beacon tracks and stores coordinates offline as you walk, serving as a flight recorder for your safety.',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        provider.toggleSafeBeacon();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.greenMain,
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
                        alignment: Alignment.center,
                        child: Text(
                          'Start Proactive Session',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
        );
      },
    );
  }

  void _showRescueNetworkSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.canvas,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppColors.ink, width: 1.5),
              left: BorderSide(color: AppColors.ink, width: 1.5),
              right: BorderSide(color: AppColors.ink, width: 1.5),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Community Rescue Network',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Nearby users can help relay alerts through a decentralized safety network.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.greenDarker,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Each hop strengthens reach without needing cellular infrastructure.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  _buildNodeItem('Priya\'s Device (Sister)', 'In Range · Relayed', AppColors.greenText),
                  const SizedBox(height: 8),
                  _buildNodeItem('Ravi\'s Device (Friend)', 'In Range · Relayed', AppColors.greenText),
                  const SizedBox(height: 8),
                  _buildNodeItem('Community Node #284', 'In Range · Verified', AppColors.textLight),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.redLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.ink, width: 1.2),
                ),
                child: Text(
                  '● Your SOS is part of someone else\'s relay too.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.redDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
    );
  }

  Widget _buildNodeItem(String name, String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink, width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.phone_android_rounded, color: AppColors.ink, size: 18),
              const SizedBox(width: 10),
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  int _currentTab = 0;

  Widget _buildDashboard(BuildContext context, AppProvider provider) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Header
            _animated(
              0,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.redMain,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.ink,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SheShield Mesh',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Emergency Response System',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => provider.setOnline(!provider.isOnline),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: provider.isOnline
                            ? AppColors.greenLight
                            : AppColors.redLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.ink,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: provider.isOnline
                                  ? AppColors.greenText
                                  : AppColors.redMain,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            provider.isOnline ? 'Online' : 'Offline',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: provider.isOnline
                                  ? AppColors.greenDarker
                                  : AppColors.redDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Network Status Card
            _animated(1, const NetworkStatusCard()),

            const SizedBox(height: 12),
            // Live Location Strip
            _animated(1, _buildLocationStrip(provider)),

            const SizedBox(height: 28),

            // SOS Button
            _animated(
              2,
              Center(
                child: SOSButton(
                  onPressed: () {
                    context.read<AppProvider>().createNewAlert();
                    Navigator.of(context).pushNamed('/alert-creation');
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Quick Actions
            _animated(
              3,
              Text(
                'Quick Actions',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _animated(
              4,
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.people_rounded,
                          label: 'Trusted Contacts',
                          subtitle: '${provider.contacts.length} contacts',
                          color: AppColors.greenText,
                          onTap: () =>
                              Navigator.of(context).pushNamed('/contacts'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.history_rounded,
                          label: 'Emergency History',
                          subtitle: '${provider.history.length} alerts',
                          color: AppColors.redMain,
                          onTap: () =>
                              Navigator.of(context).pushNamed('/history'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.track_changes_rounded,
                          label: 'Safe Beacon Mode',
                          subtitle:
                              provider.isSafeBeaconActive ? 'Active (${provider.safeBeaconElapsedTime})' : 'Tap to Start',
                          color: const Color(0xFFF59E0B),
                          onTap: () => _showSafeBeaconSheet(context, provider),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.groups_rounded,
                          label: 'Rescue Network',
                          subtitle: '3 nodes in range',
                          color: const Color(0xFFEC4899),
                          onTap: () => _showRescueNetworkSheet(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  QuickActionCard(
                    icon: Icons.forum_rounded,
                    label: 'Offline AI Voice Assistant',
                    subtitle: 'Aria · Gemma 3n Safety Guidance',
                    color: const Color(0xFF8B5CF6),
                    fullWidth: true,
                    onTap: () => Navigator.of(context).pushNamed('/ai-assistant'),
                  ),
                  const SizedBox(height: 12),
                  QuickActionCard(
                    icon: Icons.hub_rounded,
                    label: 'About Mesh Network',
                    subtitle: 'How device-to-device relay works',
                    color: AppColors.ink,
                    fullWidth: true,
                    onTap: () => Navigator.of(context).pushNamed('/about'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Bottom note
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.ink,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 14,
                      color: AppColors.greenDarker,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Works even during network shutdowns',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.greenDarker,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        border: Border(
          top: BorderSide(color: AppColors.ink, width: 2.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.shield_rounded,
                label: 'Safety Features',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.greenMain : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: isSelected 
                ? Border.all(color: AppColors.ink, width: 2.0)
                : Border.all(color: Colors.transparent, width: 2.0),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: AppColors.ink,
                      blurRadius: 0,
                      offset: Offset(2, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppColors.ink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    final List<Widget> pages = [
      _buildDashboard(context, provider),
      const FeaturesScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: pages[_currentTab],
      bottomNavigationBar: _buildBottomNav(),
    );
  }
  void _showLocationPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.canvas,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.ink, width: 2),
        ),
        title: Text(
          'Location Permission Guide',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Real-time tracking requires location permissions in your browser and device.',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            _buildPermissionStep('🌐', 'Browser Allow', 'Click the lock/padlock 🔒 or info icon next to the URL in your browser address bar. Set Location access to "Allow", then tap the refresh button.'),
            const SizedBox(height: 12),
            _buildPermissionStep('📱', 'Mobile App Settings', 'Go to Settings > Apps > SheShield > Permissions, and enable the Location permission.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Got it',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionStep(String emoji, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationOptionsDialog(BuildContext context, AppProvider provider) {
    final textCtrl = TextEditingController(text: provider.locationError != null ? '' : provider.liveLocation);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.canvas,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.ink, width: 2),
        ),
        title: Text(
          'Update Location',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set your exact location manually if the automatic detection is wrong or blocked.',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textCtrl,
              autofocus: true,
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.ink),
              decoration: InputDecoration(
                labelText: 'Exact Location / Coordinates',
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textLight),
                prefixIcon: const Icon(Icons.my_location_rounded, color: AppColors.ink),
                filled: true,
                fillColor: AppColors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.ink, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _fetchLocationAndPrompt(provider);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.ink, width: 1.2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Auto-Detect',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.greenDarker,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (provider.locationError != null) {
                        Navigator.pop(ctx);
                        _showLocationPermissionDialog(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: provider.locationError != null ? AppColors.ink : AppColors.textLight.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Permission Help',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: provider.locationError != null ? AppColors.ink : AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
                color: AppColors.textMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final typed = textCtrl.text.trim();
              if (typed.isNotEmpty) {
                provider.setManualLocation(typed);
              }
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStrip(AppProvider provider) {
    final Color bgColor;
    final Color textColor;
    final IconData icon;
    final String text;

    if (provider.locationFetching) {
      bgColor = AppColors.white;
      textColor = AppColors.textLight;
      icon = Icons.gps_not_fixed_rounded;
      text = 'Detecting your location...';
    } else if (provider.locationError != null) {
      bgColor = AppColors.redLight;
      textColor = AppColors.redDark;
      icon = Icons.location_off_rounded;
      text = 'Location permission required. Tap to enable.';
    } else {
      bgColor = AppColors.greenLight;
      textColor = AppColors.greenDarker;
      icon = Icons.my_location_rounded;
      text = provider.liveLocation;
    }

    return GestureDetector(
      onTap: () => _showLocationOptionsDialog(context, provider),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.ink,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: provider.locationFetching
                  ? CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    )
                  : Icon(icon, size: 14, color: textColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!provider.locationFetching) ...[
              const SizedBox(width: 6),
              Icon(
                provider.locationError != null ? Icons.help_outline_rounded : Icons.edit_location_alt_rounded,
                size: 14,
                color: textColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showIpLocationSuccessDialog(BuildContext context, String locationText) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.canvas,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.ink, width: 2),
        ),
        title: Row(
          children: [
            const Text('🌐 ', style: TextStyle(fontSize: 20)),
            Text(
              'IP Location Fetched',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Real-time location has been successfully fetched via IP Geolocation API key.',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.ink, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COORDINATES',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.greenDarker,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    locationText,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Okay',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
