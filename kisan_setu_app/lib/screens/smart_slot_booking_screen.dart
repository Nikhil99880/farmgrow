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
/// SCREEN 7: SMART SLOT BOOKING SCREEN
/// ---------------------------------------------------------------------------
class SmartSlotBookingScreen extends StatefulWidget {
  final VoidCallback? onConfirmBooking;
  final VoidCallback? onBack;

  const SmartSlotBookingScreen({super.key, this.onConfirmBooking, this.onBack});

  @override
  State<SmartSlotBookingScreen> createState() => _SmartSlotBookingScreenState();
}

class _SmartSlotBookingScreenState extends State<SmartSlotBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController(text: '50');

  String _selectedCenter = 'Sonipat Main Mandi (Shortest Queue)';
  String _selectedCrop = 'Wheat';
  double _selectedMspRate = 2425.0;
  String _selectedSlot = 'morning'; // 'morning' or 'evening'
  DateTime _selectedDate = DateTime.now();
  bool _isHindi = false;

  final List<String> _centers = [
    'Sonipat Main Mandi (Shortest Queue)',
    'Karnal Grain Market Hub',
    'Panipat North Procurement Center',
  ];

  final List<Map<String, dynamic>> _crops = [
    {'name': 'Wheat', 'hindi': 'गेहूँ', 'msp': 2425.0, 'icon': Icons.grass},
    {'name': 'Paddy', 'hindi': 'धान', 'msp': 2320.0, 'icon': Icons.eco},
    {'name': 'Mustard', 'hindi': 'सरसों', 'msp': 5950.0, 'icon': Icons.spa},
    {'name': 'Gram', 'hindi': 'चना', 'msp': 5440.0, 'icon': Icons.grain},
  ];

  double get _totalPayout {
    final qty = double.tryParse(_qtyController.text) ?? 0.0;
    return qty * _selectedMspRate;
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

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
          _isHindi ? 'स्मार्ट स्लॉट बुकिंग' : 'Smart Slot Booking',
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Procurement Center Selector
                      _buildSectionTitle(_isHindi ? '1. खरीद केंद्र चुनें' : '1. Select Procurement Center'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCenter,
                        isExpanded: true,
                        decoration: _dropdownDecoration(icon: Icons.storefront),
                        items: _centers.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)))).toList(),
                        onChanged: (val) => setState(() => _selectedCenter = val!),
                      ),

                      const SizedBox(height: 20),

                      // 2. Crop Selector with live MSP Rates
                      _buildSectionTitle(_isHindi ? '2. फसल चुनें (एमएसपी दर सहित)' : '2. Choose Crop (Live MSP Rate)'),
                      const SizedBox(height: 10),
                      Row(
                        children: _crops.map((c) {
                          final isSel = _selectedCrop == c['name'];
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCrop = c['name'] as String;
                                    _selectedMspRate = c['msp'] as double;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSel ? AppColors.amberLight : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSel ? AppColors.accentAmber : AppColors.borderSubtle,
                                      width: isSel ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(c['icon'] as IconData, color: isSel ? AppColors.accentAmber : AppColors.primaryEmerald, size: 22),
                                      const SizedBox(height: 4),
                                      Text(
                                        _isHindi ? c['hindi'] as String : c['name'] as String,
                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: isSel ? AppColors.textDark : AppColors.textMuted),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₹${(c['msp'] as double).toStringAsFixed(0)}/Q',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? AppColors.darkEmerald : Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // 3. Quantity in Quintals & Instant Live MSP Calculator
                      _buildSectionTitle(_isHindi ? '3. मात्रा (क्विंटल) एवं अनुमानित भुगतान' : '3. Quantity & Live Payout Calculation'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _qtyController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.darkEmerald),
                              decoration: InputDecoration(
                                hintText: '50',
                                suffixText: _isHindi ? 'क्विंटल (Qtl)' : 'Quintals (Qtl)',
                                suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryEmerald),
                                prefixIcon: const Icon(Icons.scale, color: AppColors.primaryEmerald),
                                filled: true,
                                fillColor: const Color(0xFFFAFAFA),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.lightEmerald,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.primaryEmerald.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_isHindi ? 'कुल सरकारी एमएसपी भुगतान:' : 'Est. Total MSP Payout:', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                      Text(
                                        '₹ ${_totalPayout.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.darkEmerald),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: AppColors.primaryEmerald, borderRadius: BorderRadius.circular(10)),
                                    child: const Text('100% DBT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 4. Time Slot Selection
                      _buildSectionTitle(_isHindi ? '4. समय स्लॉट चुनें' : '4. Select Arrival Time Slot'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedSlot = 'morning'),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _selectedSlot == 'morning' ? AppColors.amberLight : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _selectedSlot == 'morning' ? AppColors.accentAmber : AppColors.borderSubtle,
                                    width: _selectedSlot == 'morning' ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.light_mode, color: _selectedSlot == 'morning' ? AppColors.accentAmber : AppColors.textMuted, size: 24),
                                    const SizedBox(height: 4),
                                    Text(_isHindi ? 'सुबह' : 'Morning', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const Text('08:00 AM - 12:00 PM', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedSlot = 'evening'),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _selectedSlot == 'evening' ? AppColors.amberLight : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _selectedSlot == 'evening' ? AppColors.accentAmber : AppColors.borderSubtle,
                                    width: _selectedSlot == 'evening' ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.dark_mode, color: _selectedSlot == 'evening' ? AppColors.accentAmber : AppColors.textMuted, size: 24),
                                    const SizedBox(height: 4),
                                    Text(_isHindi ? 'शाम' : 'Evening', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const Text('02:00 PM - 06:00 PM', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Sticky Bottom CTA Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.onConfirmBooking != null) {
                      widget.onConfirmBooking!();
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
                      const Icon(Icons.check_circle, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isHindi ? 'बुकिंग की पुष्टि करें / टोकन बनाएं' : 'Confirm Booking & Issue Token',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
    );
  }

  InputDecoration _dropdownDecoration({IconData? icon}) {
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: AppColors.primaryEmerald) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryEmerald, width: 2),
      ),
    );
  }
}
