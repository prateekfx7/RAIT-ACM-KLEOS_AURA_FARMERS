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
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.06),
                      const Color(0xFF8B5CF6).withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.hub_rounded,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SheShield Mesh Network',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'When internet and cellular networks are unavailable, SheShield Mesh stores emergency alerts locally and relays them through nearby devices until connectivity is restored.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.body,
                        height: 1.6,
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
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
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
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
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
                childAspectRatio: 1.3,
                children: [
                  _featureCard(
                    Icons.offline_bolt_rounded,
                    'Offline First',
                    'Stores alerts locally without internet',
                    AppColors.primary,
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
                    const Color(0xFF10B981),
                  ),
                  _featureCard(
                    Icons.people_rounded,
                    'Multi-Hop',
                    'Alert hops across device network',
                    const Color(0xFF8B5CF6),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Tech Specs
              Text(
                'Technical Details',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Column(
                  children: [
                    _specRow('Protocol', 'Bluetooth Low Energy (BLE 5.0)'),
                    const Divider(height: 20, color: AppColors.hairlineSoft),
                    _specRow('Encryption', 'AES-256 + RSA-2048'),
                    const Divider(height: 20, color: AppColors.hairlineSoft),
                    _specRow('Max Relay Hops', '32 devices'),
                    const Divider(height: 20, color: AppColors.hairlineSoft),
                    _specRow('Alert Packet Size', '~2.4 KB'),
                    const Divider(height: 20, color: AppColors.hairlineSoft),
                    _specRow('Range per Hop', '~100 meters'),
                    const Divider(height: 20, color: AppColors.hairlineSoft),
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
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🛡️ Our Mission',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No woman should be silenced by a network shutdown. SheShield Mesh ensures that your SOS always reaches help — no matter what.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFFD1D5DB),
                        height: 1.6,
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
        children: [
          _diagramStep(
            Icons.phone_android_rounded,
            'Phone A (Victim)',
            'No internet · SOS stored locally',
            AppColors.error,
            true,
          ),
          _diagramConnector(AppColors.primary),
          _diagramStep(
            Icons.devices_other_rounded,
            'Phone B (Nearby)',
            'Receives alert via Bluetooth relay',
            AppColors.primary,
            true,
          ),
          _diagramConnector(AppColors.success),
          _diagramStep(
            Icons.wifi_rounded,
            'Internet Restored',
            'Phone B uploads to emergency servers',
            const Color(0xFF3B82F6),
            true,
          ),
          _diagramConnector(AppColors.success),
          _diagramStep(
            Icons.local_hospital_rounded,
            'Emergency Responder',
            'Alert received · Contacts notified',
            AppColors.success,
            true,
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
    bool isActive,
  ) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
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
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.muted,
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
                color: color.withOpacity(0.3),
              ),
              Icon(Icons.arrow_downward_rounded, size: 14, color: color),
              Container(
                width: 2,
                height: 8,
                color: color.withOpacity(0.3),
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
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.muted,
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
    );
  }
}
