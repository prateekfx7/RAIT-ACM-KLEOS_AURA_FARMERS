import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';

class AlertDeliveredScreen extends StatefulWidget {
  const AlertDeliveredScreen({super.key});

  @override
  State<AlertDeliveredScreen> createState() => _AlertDeliveredScreenState();
}

class _AlertDeliveredScreenState extends State<AlertDeliveredScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _rippleController;
  late AnimationController _itemsController;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _itemsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _checkController.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _itemsController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _rippleController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final alert = provider.currentAlert;
    final formatter = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Alert Delivered'),
        leading: const SizedBox(),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Success animation
              SizedBox(
                height: 160,
                child: Center(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_checkController, _rippleController]),
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ripple rings
                          ...List.generate(3, (i) {
                            final delay = i * 0.3;
                            final progress = ((_rippleController.value + delay) % 1.0);
                            return Opacity(
                              opacity: (1 - progress) * 0.4,
                              child: Container(
                                width: 60 + progress * 80,
                                height: 60 + progress * 80,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.success,
                                    width: 1.5,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }),
                          // Main circle
                          ScaleTransition(
                            scale: CurvedAnimation(
                              parent: _checkController,
                              curve: Curves.elasticOut,
                            ),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.success.withOpacity(0.35),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Title
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _checkController,
                  curve: Curves.easeIn,
                ),
                child: Text(
                  'Emergency Alert Delivered',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              // Delivery Status Cards
              AnimatedBuilder(
                animation: _itemsController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _itemsController.value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - _itemsController.value) * 20),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    _deliveryItem(
                      Icons.shield_rounded,
                      'Emergency Alert Delivered',
                      'Alert reached emergency responders',
                    ),
                    const SizedBox(height: 10),
                    _deliveryItem(
                      Icons.people_rounded,
                      'Trusted Contacts Notified',
                      '${provider.contacts.length} contacts alerted',
                    ),
                    const SizedBox(height: 10),
                    _deliveryItem(
                      Icons.history_rounded,
                      'Emergency Event Logged',
                      'Stored in encrypted history',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Alert Details Card
              AnimatedBuilder(
                animation: _itemsController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _itemsController.value,
                    child: child,
                  );
                },
                child: Container(
                  width: double.infinity,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alert Details',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _alertDetailRow(
                        'Alert ID',
                        alert?.id ?? 'SOS-UNKNOWN',
                      ),
                      const Divider(height: 20, color: AppColors.hairlineSoft),
                      _alertDetailRow(
                        'Delivery Time',
                        alert?.deliveredAt != null
                            ? formatter.format(alert!.deliveredAt!)
                            : formatter.format(DateTime.now()),
                      ),
                      const Divider(height: 20, color: AppColors.hairlineSoft),
                      _alertDetailRow(
                        'Relay Count',
                        '${alert?.relayCount ?? 1} device relay',
                      ),
                      const Divider(height: 20, color: AppColors.hairlineSoft),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.muted,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '✓  Delivered',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Buttons
              AnimatedBuilder(
                animation: _itemsController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _itemsController.value,
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<AppProvider>().clearCurrentAlert();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/home',
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home_rounded, size: 18),
                      label: const Text('Return Home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.read<AppProvider>().clearCurrentAlert();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/history',
                          (route) => route.settings.name == '/home',
                        );
                      },
                      icon: const Icon(Icons.history_rounded, size: 18),
                      label: const Text('View History'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deliveryItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
        ],
      ),
    );
  }

  Widget _alertDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
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
