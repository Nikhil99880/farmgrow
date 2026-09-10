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
/// SCREEN 12: KISAN SUVIDHA SCHEMES SCREEN
/// ---------------------------------------------------------------------------
class KisanSuvidhaScreen extends StatefulWidget {
  final VoidCallback? onGoToHelp;
  final VoidCallback? onBack;

  const KisanSuvidhaScreen({super.key, this.onGoToHelp, this.onBack});

  @override
  State<KisanSuvidhaScreen> createState() => _KisanSuvidhaScreenState();
}

class _KisanSuvidhaScreenState extends State<KisanSuvidhaScreen> {
  bool _isHindi = false;

  final List<Map<String, dynamic>> _schemes = [
    {
      'title': 'PM-KISAN Samman Nidhi',
      'hindiTitle': 'प्रधानमंत्री किसान सम्मान निधि',
      'benefit': '₹6,000 / Year in 3 Installments',
      'status': 'Active Beneficiary (सक्रिय)',
      'icon': Icons.account_balance,
      'color': Color(0xFF2E7D32),
    },
    {
      'title': 'Pradhan Mantri Fasal Bima (PMFBY)',
      'hindiTitle': 'प्रधानमंत्री फसल बीमा योजना',
      'benefit': 'Crop Loss & Weather Risk Coverage',
      'status': 'Policy Active #PMF-8921',
      'icon': Icons.shield_outlined,
      'color': Color(0xFF00838F),
    },
    {
      'title': 'National Agriculture Market (e-NAM)',
      'hindiTitle': 'राष्ट्रीय कृषि बाजार (ई-नाम)',
      'benefit': 'Direct Pan-India Mandi Bidding',
      'status': 'Registered Trader/Farmer',
      'icon': Icons.storefront,
      'color': Color(0xFF512DA8),
    },
    {
      'title': 'Subsidized Fertilizer & DAP Quota',
      'hindiTitle': 'उर्वरक एवं डीएपी सरकारी सब्सिडी',
      'benefit': 'Up to 70% Subsidy on Urea & DAP',
      'status': 'Quota Allocated',
      'icon': Icons.eco,
      'color': Color(0xFFF57F17),
    },
  ];

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
          _isHindi ? 'किसान सुविधा योजनाएं' : 'Kisan Suvidha Schemes',
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
              // Government Emblem Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.darkEmerald,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: AppColors.darkEmerald.withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.amberGold, borderRadius: BorderRadius.circular(8)),
                      child: const Text('GOVERNMENT OF INDIA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isHindi ? 'सरकारी कृषि योजनाएं एवं लाभ' : 'Government Agricultural Schemes',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isHindi
                          ? 'सभी सब्सिडी एवं सरकारी सहायता सीधे आपके बैंक खाते में।'
                          : 'Direct benefit transfer access for Indian farmers.',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFFAFEFDD)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Weather Alert Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.amberLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.accentAmber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wb_sunny, color: AppColors.accentAmber, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isHindi ? 'मौसम पूर्वानुमान (सोनीपत जिला)' : 'Weather Advisory: Sonipat',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textDark),
                          ),
                          Text(
                            _isHindi ? 'अगले 48 घंटों में साफ मौसम, फसल कटाई के लिए उत्तम।' : 'Clear skies next 48h. Ideal for harvesting & Mandi transport.',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF5D4037)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                _isHindi ? 'सक्रिय योजनाएं' : 'Active Schemes for You',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkEmerald),
              ),
              const SizedBox(height: 10),

              // Scheme Cards List
              ..._schemes.map((scheme) => _buildSchemeCard(scheme)).toList(),

              const SizedBox(height: 20),

              // Next CTA Button: Go to Help Center & AI Chat
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.onGoToHelp != null) {
                      widget.onGoToHelp!();
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
                      const Icon(Icons.support_agent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isHindi ? 'सहायता केंद्र एवं कृषि सहायक चैट' : 'Help Center & Krishi Sahayak Chat',
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

  Widget _buildSchemeCard(Map<String, dynamic> scheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (scheme['color'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(scheme['icon'] as IconData, color: scheme['color'] as Color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isHindi ? scheme['hindiTitle'] : scheme['title'],
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  scheme['benefit'],
                  style: const TextStyle(fontSize: 11.5, color: AppColors.darkEmerald, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  scheme['status'],
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
