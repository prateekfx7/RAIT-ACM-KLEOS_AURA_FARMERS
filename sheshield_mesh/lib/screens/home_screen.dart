import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/network_status_card.dart';
import '../widgets/sos_button.dart';
import '../widgets/quick_action_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late List<Animation<double>> _itemFades;
  late List<Animation<Offset>> _itemSlides;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _itemFades = List.generate(5, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(i * 0.12, (i * 0.12) + 0.4, curve: Curves.easeOut),
        ),
      );
    });

    _itemSlides = List.generate(5, (i) {
      return Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
          .animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(i * 0.12, (i * 0.12) + 0.4, curve: Curves.easeOut),
        ),
      );
    });

    _staggerController.forward();

    // Fetch real location via browser Geolocation API on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().fetchLiveLocation();
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Widget _animated(int idx, Widget child) {
    return FadeTransition(
      opacity: _itemFades[idx],
      child: SlideTransition(
        position: _itemSlides[idx],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
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
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF9C95FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
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
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Emergency Response System',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.muted,
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
                              ? AppColors.successLight
                              : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: provider.isOnline
                                ? AppColors.success.withOpacity(0.3)
                                : AppColors.error.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: provider.isOnline
                                    ? AppColors.success
                                    : AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              provider.isOnline ? 'Online' : 'Offline',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: provider.isOnline
                                    ? AppColors.success
                                    : AppColors.error,
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
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
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
                            color: AppColors.primary,
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
                            color: const Color(0xFF10B981),
                            onTap: () =>
                                Navigator.of(context).pushNamed('/history'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    QuickActionCard(
                      icon: Icons.hub_rounded,
                      label: 'About Mesh Network',
                      subtitle: 'How device-to-device relay works',
                      color: const Color(0xFF8B5CF6),
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
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Works even during network shutdowns',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
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
      ),
    );
  }
  Widget _buildLocationStrip(AppProvider provider) {
    final Color color;
    final IconData icon;
    final String text;

    if (provider.locationFetching) {
      color = AppColors.muted;
      icon = Icons.gps_not_fixed_rounded;
      text = 'Detecting your location...';
    } else if (provider.locationError != null) {
      color = AppColors.warning;
      icon = Icons.location_off_rounded;
      text = 'Location: ${provider.locationError}';
    } else {
      color = AppColors.success;
      icon = Icons.my_location_rounded;
      text = provider.liveLocation;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: provider.locationFetching
                ? CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  )
                : Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!provider.locationFetching) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => provider.fetchLiveLocation(),
              child: Icon(Icons.refresh_rounded, size: 14, color: color),
            ),
          ],
        ],
      ),
    );
  }
}
