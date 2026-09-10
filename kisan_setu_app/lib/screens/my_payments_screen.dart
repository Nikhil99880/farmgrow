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
/// SCREEN 11: MY PAYMENTS SCREEN
/// ---------------------------------------------------------------------------
class MyPaymentsScreen extends StatefulWidget {
  final VoidCallback? onGoToSuvidha;
  final VoidCallback? onBack;

  const MyPaymentsScreen({super.key, this.onGoToSuvidha, this.onBack});

  @override
  State<MyPaymentsScreen> createState() => _MyPaymentsScreenState();
}

class _MyPaymentsScreenState extends State<MyPaymentsScreen> {
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
          _isHindi ? 'मेरे डीबीटी भुगतान' : 'My DBT Payments',
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
              // Bento Payment Summary Cards (2 Columns)
              Row(
                children: [
                  // Total Received
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.darkEmerald,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkEmerald.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isHindi ? 'कुल प्राप्त राशि' : 'TOTAL RECEIVED',
                            style: const TextStyle(color: Color(0xFFAFEFDD), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '₹ 1,45,000',
                            style: TextStyle(color: AppColors.amberGold, fontSize: 20, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isHindi ? 'इस रबी सीजन' : 'Active Rabi Season',
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Pending DBT Processing
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.amberLight,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.accentAmber),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isHindi ? 'प्रक्रियाधीन डीबीटी' : 'PENDING DBT',
                            style: const TextStyle(color: Color(0xFF5D4037), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '₹ 32,500',
                            style: TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isHindi ? 'बैंक क्लीयरेंस 24 घंटे में' : 'Bank credit within 24h',
                            style: const TextStyle(color: Color(0xFF5D4037), fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Recent Transactions List
              Text(
                _isHindi ? 'लेनदेन का इतिहास' : 'Direct Credit History',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkEmerald),
              ),
              const SizedBox(height: 10),

              // TXN 1: Wheat Sale Completed
              _buildTransactionCard(
                title: _isHindi ? 'गेहूँ खरीद (सोनीपत मंडी)' : 'Wheat Sale (Sonipat Mandi)',
                date: '12 May 2024 • Qty: 20 Qtl',
                ref: 'Ref: TXN-89234190',
                amount: '₹ 45,000',
                status: _isHindi ? 'जमा हुआ ✓' : 'Credited ✓',
                statusBg: AppColors.lightEmerald,
                statusColor: AppColors.primaryEmerald,
                hasReceipt: true,
              ),

              const SizedBox(height: 12),

              // TXN 2: Paddy Procurement Processing
              _buildTransactionCard(
                title: _isHindi ? 'धान खरीद (करनाल मंडी)' : 'Paddy Procurement (Karnal Mandi)',
                date: '10 May 2024 • Qty: 15 Qtl',
                ref: 'Ref: PRQ-11094821',
                amount: '₹ 32,500',
                status: _isHindi ? 'बैंक प्रक्रियाधीन ⏳' : 'Bank Processing ⏳',
                statusBg: AppColors.amberLight,
                statusColor: AppColors.accentAmber,
                hasReceipt: false,
              ),

              const SizedBox(height: 12),

              // TXN 3: Fertilizer Subsidy
              _buildTransactionCard(
                title: _isHindi ? 'उर्वरक सब्सिडी प्रत्यक्ष जमा' : 'Fertilizer DBT Subsidy',
                date: '02 May 2024 • Scheme #481',
                ref: 'Ref: SUB-992140',
                amount: '₹ 12,500',
                status: _isHindi ? 'जमा हुआ ✓' : 'Credited ✓',
                statusBg: AppColors.lightEmerald,
                statusColor: AppColors.primaryEmerald,
                hasReceipt: true,
              ),

              const SizedBox(height: 24),

              // Next Action Button: Go to Kisan Suvidha
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.onGoToSuvidha != null) {
                      widget.onGoToSuvidha!();
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
                      const Icon(Icons.spa, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isHindi ? 'किसान सुविधा योजनाएं देखें' : 'View Kisan Suvidha Schemes',
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

  Widget _buildTransactionCard({
    required String title,
    required String date,
    required String ref,
    required String amount,
    required String status,
    required Color statusBg,
    required Color statusColor,
    required bool hasReceipt,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              Text(amount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.darkEmerald)),
            ],
          ),
          const SizedBox(height: 4),
          Text(date, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          Text(ref, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              if (hasReceipt)
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.primaryEmerald,
                        content: Text('Downloading Official DBT Receipt $ref...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download, size: 16, color: AppColors.primaryEmerald),
                  label: Text(_isHindi ? 'रसीद डाउनलोड' : 'Receipt', style: const TextStyle(color: AppColors.primaryEmerald, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
