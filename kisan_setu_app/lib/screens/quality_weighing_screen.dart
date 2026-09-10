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
/// SCREEN 10: QUALITY & WEIGHING SCREEN
/// ---------------------------------------------------------------------------
class QualityWeighingScreen extends StatefulWidget {
  final VoidCallback? onGoToPayments;
  final VoidCallback? onBack;

  const QualityWeighingScreen({super.key, this.onGoToPayments, this.onBack});

  @override
  State<QualityWeighingScreen> createState() => _QualityWeighingScreenState();
}

class _QualityWeighingScreenState extends State<QualityWeighingScreen> {
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
          _isHindi ? 'गुणवत्ता एवं धर्मकांटा तौल' : 'Quality & Weighment',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lot Number & Crop Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkEmerald,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isHindi ? 'लॉट संख्या' : 'LOT IDENTIFIER',
                          style: const TextStyle(color: Color(0xFFAFEFDD), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Lot #8902A • Wheat',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.amberGold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('GRADE A', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.textDark)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 1. Moisture & Laboratory Assaying Card
              _buildSectionTitle(_isHindi ? '1. लैब गुणवत्ता एवं नमी परीक्षण' : '1. Lab Assaying & Moisture Test'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.primaryEmerald.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: AppColors.lightEmerald, shape: BoxShape.circle),
                          child: const Icon(Icons.science, color: AppColors.primaryEmerald, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isHindi ? 'डिजिटल नमी विश्लेषक' : 'Digital Moisture Analyzer',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                              ),
                              const Text('Tested with certified electronic sensor', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.lightEmerald, borderRadius: BorderRadius.circular(8)),
                          child: const Text('PASSED ✓', style: TextStyle(color: AppColors.primaryEmerald, fontWeight: FontWeight.bold, fontSize: 10)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 3 Metric Boxes
                    Row(
                      children: [
                        _buildQualityMetricBox(
                          label: _isHindi ? 'नमी (Moisture)' : 'Moisture',
                          value: '12.5%',
                          limit: '< 14.0% Standard',
                          isPassed: true,
                        ),
                        const SizedBox(width: 8),
                        _buildQualityMetricBox(
                          label: _isHindi ? 'कचरा (Foreign)' : 'Foreign Matter',
                          value: '0.8%',
                          limit: '< 2.0% Standard',
                          isPassed: true,
                        ),
                        const SizedBox(width: 8),
                        _buildQualityMetricBox(
                          label: _isHindi ? 'क्षतिग्रस्त (Damaged)' : 'Damaged Grain',
                          value: '1.2%',
                          limit: '< 2.0% Standard',
                          isPassed: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Electronic Weighbridge (Dharmkanta)
              _buildSectionTitle(_isHindi ? '2. इलेक्ट्रॉनिक धर्मकांटा तौल विवरण' : '2. Electronic Weighbridge (Dharmkanta)'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildWeightColumn(_isHindi ? 'सकल भार (Gross)' : 'Gross Weight', '62.40 Qtl', 'Tractor + Crop'),
                        const SizedBox(width: 8),
                        _buildWeightColumn(_isHindi ? 'खाली भार (Tare)' : 'Tare Weight', '12.10 Qtl', 'Empty Trolley'),
                        const SizedBox(width: 8),
                        _buildWeightColumn(_isHindi ? 'शुद्ध फसल (Net)' : 'Net Crop Weight', '50.30 Qtl', 'Final Procurement', isNet: true),
                      ],
                    ),

                    const Divider(height: 24, thickness: 1),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.primaryEmerald),
                            const SizedBox(width: 6),
                            Text(
                              _isHindi ? 'बोरी संख्या: 125 बोरी (40 किग्रा)' : 'Bagging: 125 Bags (40kg)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Text(
                          'Calibrated Digital Sensor',
                          style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Helpline Call Button
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling Mandi Assayer Help Desk: 1800-180-1551')),
                  );
                },
                icon: const Icon(Icons.call, color: AppColors.primaryEmerald),
                label: Text(
                  _isHindi ? 'सहायता केंद्र से संपर्क करें' : 'Call Mandi Weighbridge Help Desk',
                  style: const TextStyle(color: AppColors.primaryEmerald, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: AppColors.primaryEmerald, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),

              const SizedBox(height: 20),

              // Sticky Proceed CTA Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.onGoToPayments != null) {
                      widget.onGoToPayments!();
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
                      const Icon(Icons.payments, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isHindi ? 'डीबीटी भुगतान एवं रसीद देखें' : 'View DBT Payment & Receipt',
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

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark));
  }

  Widget _buildQualityMetricBox({
    required String label,
    required String value,
    required String limit,
    required bool isPassed,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted), maxLines: 1),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryEmerald)),
            const SizedBox(height: 2),
            Text(limit, style: const TextStyle(fontSize: 8.5, color: Colors.grey, fontWeight: FontWeight.bold), maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightColumn(String label, String value, String sub, {bool isNet = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: isNet ? AppColors.lightEmerald : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isNet ? AppColors.primaryEmerald : AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: isNet ? AppColors.darkEmerald : AppColors.textMuted), maxLines: 1),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isNet ? AppColors.darkEmerald : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(fontSize: 9, color: Colors.grey), maxLines: 1),
          ],
        ),
      ),
    );
  }
}
