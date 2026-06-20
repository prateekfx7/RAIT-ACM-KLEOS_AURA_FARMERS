import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('About Mesh Network'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.greenMain,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.ink, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.hub_rounded,
                        color: AppColors.ink,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SheShield Mesh Network',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'When internet and cellular networks are unavailable, SheShield Mesh stores emergency alerts locally and relays them through nearby devices until connectivity is restored.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Visual Diagram
              Text(
                'How It Works',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 12),

              _buildDiagram(),

              const SizedBox(height: 24),

              // Features Grid
              Text(
                'Key Features',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _featureCard(
                    Icons.offline_bolt_rounded,
                    'Offline First',
                    'Stores alerts locally without internet',
                    AppColors.redMain,
                  ),
                  _featureCard(
                    Icons.bluetooth_rounded,
                    'Bluetooth Relay',
                    'Forwards via device proximity',
                    const Color(0xFF3B82F6),
                  ),
                  _featureCard(
                    Icons.lock_rounded,
                    'Encrypted',
                    'AES-256 end-to-end encryption',
                    AppColors.greenText,
                  ),
                  _featureCard(
                    Icons.people_rounded,
                    'Multi-Hop',
                    'Alert hops across device network',
                    const Color(0xFF8B5CF6),
                  ),
                  _featureCard(
                    Icons.track_changes_rounded,
                    'Safe Beacon Mode',
                    'Create a proactive safety session before entering risky environments.',
                    const Color(0xFFF59E0B),
                  ),
                  _featureCard(
                    Icons.groups_rounded,
                    'Community Rescue',
                    'Nearby users can help relay alerts through a decentralized safety network.',
                    const Color(0xFFEC4899),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Tech Specs
              Text(
                'Technical Details',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
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
                    _specRow('Protocol', 'Bluetooth Low Energy (BLE 5.0)'),
                    const Divider(height: 20, thickness: 1.2, color: AppColors.ink),
                    _specRow('Encryption', 'AES-256 + RSA-2048'),
                    const Divider(height: 20, thickness: 1.2, color: AppColors.ink),
                    _specRow('Max Relay Hops', '32 devices'),
                    const Divider(height: 20, thickness: 1.2, color: AppColors.ink),
                    _specRow('Alert Packet Size', '~2.4 KB'),
                    const Divider(height: 20, thickness: 1.2, color: AppColors.ink),
                    _specRow('Range per Hop', '~100 meters'),
                    const Divider(height: 20, thickness: 1.2, color: AppColors.ink),
                    _specRow('Storage', 'Local encrypted SQLite'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Mission Statement
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.ink, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.greenMain,
                      blurRadius: 0,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🛡️ Our Mission',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.greenMain,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No woman should be silenced by a network shutdown. SheShield Mesh ensures that your SOS always reaches help — no matter what.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagram() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          _diagramStep(
            Icons.phone_android_rounded,
            'Phone A (Victim)',
            'No internet · SOS stored locally',
            AppColors.redMain,
            AppColors.redLight,
          ),
          _diagramConnector(AppColors.ink),
          _diagramStep(
            Icons.devices_other_rounded,
            'Phone B (Nearby)',
            'Receives alert via Bluetooth relay',
            AppColors.greenText,
            AppColors.greenLight,
          ),
          _diagramConnector(AppColors.ink),
          _diagramStep(
            Icons.wifi_rounded,
            'Internet Restored',
            'Phone B uploads to emergency servers',
            const Color(0xFF3B82F6),
            const Color(0xFFE3F2FD),
          ),
          _diagramConnector(AppColors.ink),
          _diagramStep(
            Icons.local_hospital_rounded,
            'Emergency Responder',
            'Alert received · Contacts notified',
            AppColors.greenDarker,
            AppColors.greenMain,
          ),
        ],
      ),
    );
  }

  Widget _diagramStep(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    Color bg,
  ) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.ink, width: 1.2),
          ),
          child: Icon(icon, size: 22, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _diagramConnector(Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 21),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 2,
                height: 8,
                color: AppColors.ink,
              ),
              const Icon(Icons.arrow_downward_rounded, size: 14, color: AppColors.ink),
              Container(
                width: 2,
                height: 8,
                color: AppColors.ink,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureCard(
      IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.ink, width: 1.2),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _specRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
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
    );
  }
}
