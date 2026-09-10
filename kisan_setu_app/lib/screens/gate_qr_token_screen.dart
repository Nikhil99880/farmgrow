import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryEmerald = Color(0xFF2E7D32);
  static const Color darkEmerald = Color(0xFF1B5E20);
  static const Color lightEmerald = Color(0xFFE8F5E9);
  static const Color accentAmber = Color(0xFFF57F17);
  static const Color amberGold = Color(0xFFFDD400);
  static const Color amberLight = Color(0xFFFFF9C4);
  static const Color background = Color(0xFFF9FBF9);
  static const Color cardSurface = Colors.white;
  static const Color textDark = Color(0xFF1C1B1B);
  static const Color textMuted = Color(0xFF55605A);
  static const Color borderSubtle = Color(0xFFCFD8DC);
  static const Color errorRed = Color(0xFFC62828);
}

/// ---------------------------------------------------------------------------
/// SCREEN 8: GATE QR TOKEN SCREEN (#42)
/// ---------------------------------------------------------------------------
class GateQrTokenScreen extends StatefulWidget {
  final VoidCallback? onTrackQueue;
  final VoidCallback? onBack;

  const GateQrTokenScreen({super.key, this.onTrackQueue, this.onBack});

  @override
  State<GateQrTokenScreen> createState() => _GateQrTokenScreenState();
}

class _GateQrTokenScreenState extends State<GateQrTokenScreen> {
  bool _isHindi = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkEmerald),
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          _isHindi ? 'मंडी गेट टोकन' : 'Mandi Gate Token',
          style: const TextStyle(
            color: AppColors.darkEmerald,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: ActionChip(
              avatar: const Icon(Icons.language, size: 16, color: AppColors.primaryEmerald),
              label: Text(_isHindi ? 'EN' : 'हिन्दी', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              backgroundColor: AppColors.amberLight,
              onPressed: () => setState(() => _isHindi = !_isHindi),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Confirmation Badge
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.primaryEmerald,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 10),
              Text(
                _isHindi ? 'स्लॉट बुकिंग पक्की हो गई!' : 'Booking Confirmed!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkEmerald,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isHindi ? 'मंडी प्रवेश द्वार पर यह क्यूआर कोड दिखाएं।' : 'Present this digital QR token at Mandi Gate 2.',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),

              const SizedBox(height: 20),

              // High-Contrast Token Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.borderSubtle, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header Strip with Big #42
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.darkEmerald,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _isHindi ? 'टोकन संख्या / GATE TOKEN' : 'OFFICIAL GATE TOKEN NUMBER',
                            style: const TextStyle(
                              color: Color(0xFFAFEFDD),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '#42',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: AppColors.amberGold,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Sonipat Main Mandi • Gate 2 Entry',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    // QR Code & Details
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // Scannable QR Container
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.textDark, width: 3),
                            ),
                            child: const Icon(
                              Icons.qr_code_2,
                              size: 160,
                              color: AppColors.textDark,
                            ),
                          ),

                          const SizedBox(height: 12),
                          Text(
                            _isHindi ? 'ऑटो-वेरिफिकेशन के लिए स्कैन करें' : 'Scan for instant gate barrier entry',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                          ),

                          const Divider(height: 32, thickness: 1),

                          // Token Metadata
                          _buildDetailRow(_isHindi ? 'किसान का नाम' : 'Farmer Name', 'Ram Singh (राम सिंह)'),
                          _buildDetailRow(_isHindi ? 'फसल एवं मात्रा' : 'Crop & Quantity', 'Wheat (गेहूँ) • 50 Quintals'),
                          _buildDetailRow(_isHindi ? 'तारीख एवं समय' : 'Date & Time Slot', 'Today • 08:00 AM - 12:00 PM'),
                          _buildDetailRow(_isHindi ? 'वाहन नंबर' : 'Vehicle Reg.', 'PB-10-EH-9821'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Offline Safe Badge
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.amberLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accentAmber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: AppColors.accentAmber, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isHindi
                            ? 'यह टोकन बिना इंटरनेट के भी मंडी गेट पर काम करेगा।'
                            : 'This digital token works 100% offline without internet at the gate.',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // CTA to Live Tracker
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.onTrackQueue != null) {
                      widget.onTrackQueue!();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_shipping, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isHindi ? 'लाइव कतार स्थिति ट्रैक करें' : 'Track Real-Time Queue Position',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        ],
      ),
    );
  }
}
