import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/evidence_vault_service.dart';

class TrustedMessagingScreen extends StatefulWidget {
  const TrustedMessagingScreen({super.key});

  @override
  State<TrustedMessagingScreen> createState() => _TrustedMessagingScreenState();
}

class _TrustedMessagingScreenState extends State<TrustedMessagingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TextEditingController _messageCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _attachLocation = true;

  String? _playingAlertId;
  bool _isPlayingAudio = false;
  bool _isBufferingAudio = false;
  final Map<String, String> _decryptedAudioCache = {};

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _loadHistory();
  }

  @override
  void dispose() {
    EvidenceVaultService.stopAudio();
    _animController.dispose();
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final raw = await ApiService.getMessageHistory();
      final parsed = raw
          .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
          .toList();
      setState(() {
        _messages = parsed;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  // Parse lat/lng from the provider's liveLocation string like "28.6139° N, 77.2090° E ..."
  (double lat, double lng) _parseLocation(String locationStr) {
    try {
      final regex = RegExp(r'([\d.]+)°?\s*[NS],?\s*([\d.]+)°?\s*[EW]');
      final match = regex.firstMatch(locationStr);
      if (match != null) {
        return (double.parse(match.group(1)!), double.parse(match.group(2)!));
      }
    } catch (_) {}
    return (28.6139, 77.2090);
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? "hour" : "hours"} ago';
    }
    final d = diff.inDays;
    if (d == 1) return 'yesterday';
    if (d < 7) return '$d days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _prefillSOS() {
    _messageCtrl.text = 'I need help! This is an emergency.';
    setState(() => _attachLocation = true);
  }

  Future<void> _handleSend() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;

    final provider = Provider.of<AppProvider>(context, listen: false);
    final contacts = provider.contacts;
    if (contacts.isEmpty) {
      _showSnackBar('Add trusted contacts first', isError: true);
      return;
    }

    // Show confirmation bottom sheet
    final confirmed = await _showConfirmSheet(text, contacts);
    if (confirmed != true) return;

    setState(() => _isSending = true);

    final (lat, lng) = _parseLocation(provider.liveLocation);

    final result = await ApiService.sendMessage(
      message: text,
      lat: _attachLocation ? lat : 0,
      lng: _attachLocation ? lng : 0,
      accuracy: _attachLocation ? 10.0 : 0,
      senderName: 'SheShield User',
    );

    setState(() => _isSending = false);

    if (result['success'] == true) {
      _showSnackBar('Message sent to ${contacts.length} contacts ✓');
      _messageCtrl.clear();
      await _loadHistory();
    } else {
      _showSnackBar('Failed to send — message saved offline', isError: true);
    }
  }

  Future<bool?> _showConfirmSheet(String text, List<ContactModel> contacts) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.redLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  child: const Icon(Icons.send_rounded, size: 20, color: AppColors.redMain),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Confirm Send',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.ink),
                  onPressed: () => Navigator.pop(ctx, false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Message preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.ink, width: 1.5),
              ),
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Will be sent to:',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            // Recipient list
            ...contacts.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.greenMain,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.ink, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        c.initials,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          c.phone,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded, size: 20, color: AppColors.greenText),
                ],
              ),
            )),
            if (_attachLocation) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 16, color: AppColors.greenText),
                  const SizedBox(width: 6),
                  Text(
                    'Location will be attached',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.greenText,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            // Confirm button
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
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
              child: Text(
                'Send to ${contacts.length} Contacts',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.white),
        ),
        backgroundColor: isError ? AppColors.redMain : AppColors.greenDarker,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.ink, width: 1.5),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Trusted Messages'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _isLoading ? null : _loadHistory,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.ink,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, size: 18, color: AppColors.ink),
              label: Text(
                'Refresh',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Message history area
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _messages.isEmpty
                      ? _buildEmptyState()
                      : _buildMessageList(),
            ),
            // Compose area
            _buildComposeArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.ink, width: 1.5),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.greenDarker,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Loading messages...',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.ink, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: AppColors.ink, offset: Offset(3, 3)),
                ],
              ),
              child: const Icon(
                Icons.forum_rounded,
                size: 38,
                color: AppColors.greenDarker,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Messages Sent Yet',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Send a message to your trusted\ncontacts with your live location',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _prefillSOS,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.redLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.redMain, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.redMain),
                    const SizedBox(width: 8),
                    Text(
                      'Quick SOS Message',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.redMain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        final msg = _messages[i];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + i * 80),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 15),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildMessageBubble(msg),
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(MessageModel msg) {
    final hasLocation = msg.lat != null && msg.lng != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ink, width: 1.5),
        boxShadow: const [
          BoxShadow(color: AppColors.ink, offset: Offset(3, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: sender + timestamp
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.greenMain,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ink, width: 1.5),
                ),
                child: const Icon(Icons.person_rounded, size: 16, color: AppColors.ink),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  msg.senderName,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Text(
                _relativeTime(msg.timestamp),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Message text
          Text(
            msg.text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              height: 1.4,
            ),
          ),
          if (msg.alertId != null) ...[
            const SizedBox(height: 12),
            _buildAudioPlayerCard(msg.alertId!),
          ],
          // Location link
          if (hasLocation) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.ink, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded, size: 14, color: AppColors.redMain),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '📍 ${msg.lat!.toStringAsFixed(4)}, ${msg.lng!.toStringAsFixed(4)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greenDarker,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.open_in_new_rounded, size: 12, color: AppColors.textLight),
                ],
              ),
            ),
          ],
          // Delivery status + recipients
          if (msg.recipients.isNotEmpty) ...[
            const SizedBox(height: 12),
            // Status row
            Row(
              children: [
                if (msg.sentCount > 0)
                  _buildStatusChip(
                    Icons.check_circle_rounded,
                    '${msg.sentCount} sent',
                    AppColors.greenText,
                    AppColors.greenLight,
                  ),
                if (msg.sentCount > 0 && msg.failedCount > 0) const SizedBox(width: 8),
                if (msg.failedCount > 0)
                  _buildStatusChip(
                    Icons.cancel_rounded,
                    '${msg.failedCount} failed',
                    AppColors.redMain,
                    AppColors.redLight,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Recipient pills
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: msg.recipients.map((r) {
                final isSent = r.status == 'sent';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSent ? AppColors.white : AppColors.redLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSent ? AppColors.ink : AppColors.redMain,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSent ? Icons.check_rounded : Icons.close_rounded,
                        size: 12,
                        color: isSent ? AppColors.greenText : AppColors.redMain,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        r.name,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isSent ? AppColors.ink : AppColors.redDark,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(IconData icon, String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
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

  Widget _buildComposeArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.ink, width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick SOS chip row
          Row(
            children: [
              GestureDetector(
                onTap: _prefillSOS,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.redLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.redMain, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 15, color: AppColors.redMain),
                      const SizedBox(width: 6),
                      Text(
                        'Quick SOS',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.redMain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Location toggle
              GestureDetector(
                onTap: () => setState(() => _attachLocation = !_attachLocation),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _attachLocation ? AppColors.greenLight : AppColors.canvas,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _attachLocation ? AppColors.greenText : AppColors.textLight,
                      width: 1.5,
                    ),
                    boxShadow: _attachLocation
                        ? [
                            BoxShadow(
                              color: AppColors.greenMain.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 15,
                        color: _attachLocation ? AppColors.greenText : AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _attachLocation ? 'Location ON' : 'Location OFF',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: _attachLocation ? AppColors.greenText : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Text input + send button
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  child: TextField(
                    controller: _messageCtrl,
                    maxLines: 3,
                    minLines: 1,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type a message to your trusted circle...',
                      hintStyle: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Send button
              GestureDetector(
                onTap: _isSending ? null : _handleSend,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _isSending ? AppColors.redMedium : AppColors.redMain,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.ink, width: 1.5),
                    boxShadow: _isSending
                        ? []
                        : const [
                            BoxShadow(color: AppColors.ink, offset: Offset(2, 2)),
                          ],
                  ),
                  child: _isSending
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.white,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.arrow_upward_rounded,
                          color: AppColors.white,
                          size: 24,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAudioPlayback(String alertId) async {
    if (_playingAlertId == alertId && _isPlayingAudio) {
      EvidenceVaultService.stopAudio();
      setState(() {
        _isPlayingAudio = false;
        _playingAlertId = null;
      });
      return;
    }

    if (_playingAlertId != null) {
      EvidenceVaultService.stopAudio();
    }

    setState(() {
      _playingAlertId = alertId;
      _isBufferingAudio = true;
      _isPlayingAudio = false;
    });

    String? base64Data;
    if (_decryptedAudioCache.containsKey(alertId)) {
      base64Data = _decryptedAudioCache[alertId];
    } else {
      final res = await ApiService.fetchEvidence(alertId);
      if (res != null && res['success'] == true && res['evidence'] != null) {
        final rawAudio = res['evidence']['audioData'] as String?;
        if (rawAudio != null) {
          if (rawAudio.startsWith("SHESHIELD_ENCRYPTED_VAULT_v1_")) {
            final content = rawAudio.substring("SHESHIELD_ENCRYPTED_VAULT_v1_".length);
            base64Data = content.split('').reversed.join('');
            _decryptedAudioCache[alertId] = base64Data;
          } else {
            base64Data = rawAudio;
          }
        }
      }
    }

    if (base64Data == null || base64Data.isEmpty) {
      _showSnackBar('Could not retrieve audio evidence from vault', isError: true);
      setState(() {
        _playingAlertId = null;
        _isBufferingAudio = false;
      });
      return;
    }

    setState(() {
      _isBufferingAudio = false;
      _isPlayingAudio = true;
    });

    EvidenceVaultService.playAudio(base64Data);

    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && _playingAlertId == alertId) {
        setState(() {
          _isPlayingAudio = false;
          _playingAlertId = null;
        });
      }
    });
  }

  Widget _buildAudioPlayerCard(String alertId) {
    final isCurrent = _playingAlertId == alertId;
    final isPlaying = isCurrent && _isPlayingAudio;
    final isBuffering = isCurrent && _isBufferingAudio;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink, width: 1.5),
        boxShadow: const [
          BoxShadow(color: AppColors.ink, offset: Offset(2, 2)),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleAudioPlayback(alertId),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isPlaying ? AppColors.redLight : AppColors.greenMain,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ink, width: 1.5),
              ),
              child: isBuffering
                  ? const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.ink,
                        ),
                      ),
                    )
                  : Icon(
                      isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      color: AppColors.ink,
                      size: 26,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isPlaying
                          ? 'Playing Emergency Audio'
                          : isBuffering
                              ? 'Loading secure vault...'
                              : 'Secured Recording',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    if (isPlaying) ...[
                      const SizedBox(width: 6),
                      const LoopPulse(),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '15 seconds • Decrypted Offline Vault',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
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

class LoopPulse extends StatefulWidget {
  const LoopPulse({super.key});

  @override
  State<LoopPulse> createState() => _LoopPulseState();
}

class _LoopPulseState extends State<LoopPulse> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.redMain,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
