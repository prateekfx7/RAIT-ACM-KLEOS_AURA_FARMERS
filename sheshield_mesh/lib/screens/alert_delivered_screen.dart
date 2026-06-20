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

    // Auto-return to home after showing the success screen
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (mounted) {
        context.read<AppProvider>().clearCurrentAlert();
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      }
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
                                color: AppColors.greenMain,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.ink,
                                  width: 2.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.ink,
                                    blurRadius: 0,
                                    offset: Offset(4, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: AppColors.ink,
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
                    fontWeight: FontWeight.w900,
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
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alert Details',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _alertDetailRow(
                        'Alert ID',
                        alert?.id ?? 'SOS-UNKNOWN',
                      ),
                      const Divider(height: 20, color: Color(0x1F000000)),
                      _alertDetailRow(
                        'Delivery Time',
                        alert?.deliveredAt != null
                            ? formatter.format(alert!.deliveredAt!)
                            : formatter.format(DateTime.now()),
                      ),
                      const Divider(height: 20, color: Color(0x1F000000)),
                      _alertDetailRow(
                        'Relay Count',
                        '${alert?.relayCount ?? 1} device relay',
                      ),
                      const Divider(height: 20, color: Color(0x1F000000)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textLight,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.greenLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.ink, width: 1),
                            ),
                            child: Text(
                              '✓  Delivered',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.greenDarker,
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
                        backgroundColor: AppColors.redMain,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(color: AppColors.ink, width: 1.5),
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
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.ink,
                        elevation: 0,
                        side: const BorderSide(color: AppColors.ink, width: 1.5),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ink, width: 1.5),
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
            child: Icon(icon, color: AppColors.ink, size: 18),
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
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppColors.greenText, size: 20),
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
          style: GoogleFonts.inter(
            fontSize: 13,
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
    );
  }
}
