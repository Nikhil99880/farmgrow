import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/custom_app_bar.dart';
import '../models/crop_model.dart';
import '../state/app_state.dart';

class BookSlotScreen extends StatefulWidget {
  const BookSlotScreen({super.key});

  @override
  State<BookSlotScreen> createState() => _BookSlotScreenState();
}

class _BookSlotScreenState extends State<BookSlotScreen> {
  String _selectedCenter = 'Sonipat Main Mandi';
  final List<String> _centers = [
    'Sonipat Main Mandi (Shortest Queue / सबसे छोटी कतार)',
    'Panipat North Hub',
    'Rohtak Central Hub',
  ];

  int _selectedDay = 12;
  Crop _selectedCrop = Crop.sampleCrops[0];
  final TextEditingController _qtyController = TextEditingController(text: '50');
  String _selectedSlot = 'morning';

  double get _quantity => double.tryParse(_qtyController.text) ?? 0.0;
  double get _estimatedPayout => _quantity * _selectedCrop.mspPerQtl;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _onConfirmBooking() {
    AppState().createBooking(
      centerId: 'mandi_1',
      centerName: _selectedCenter.split(' (').first,
      centerHindi: 'सोनीपत मुख्य मंडी',
      date: DateTime(2023, 10, _selectedDay),
      crop: _selectedCrop,
      quantityQuintals: _quantity,
      estimatedPayout: _estimatedPayout,
      timeSlotTitle: _selectedSlot == 'morning' ? 'Morning / सुबह' : 'Evening / शाम',
      timeSlotHours: _selectedSlot == 'morning' ? '08:00 AM - 12:00 PM' : '02:00 PM - 06:00 PM',
    );
    Navigator.pushNamed(context, '/mandi-token');
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Book Slot / स्लॉट बुक करें',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Center Selection
                      _buildSectionTitle('1. Select Center / केंद्र चुनें'),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primaryContainer.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer, size: 14, color: AppColors.primaryContainer),
                            const SizedBox(width: 4),
                            Text(
                              'Recommended (Shortest Queue) / अनुशंसित (सबसे छोटी कतार)',
                              style: AppTypography.labelSmall(color: AppColors.primaryContainer).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _centers.first,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          fillColor: AppColors.surfaceContainerLowest,
                        ),
                        items: _centers.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(c, style: AppTypography.bodyMedium(color: AppColors.onSurface)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCenter = val);
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ensure you select a center within 50km radius.',
                        style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 24),

                      // Section 2: Date Selection
                      _buildSectionTitle('2. Select Date / तिथि चुनें'),
                      const SizedBox(height: 8),
                      _buildCalendarCard(),
                      const SizedBox(height: 24),

                      // Section 3: Crop Selection
                      _buildSectionTitle('3. Select Crop & Quantity / फसल और मात्रा'),
                      const SizedBox(height: 12),
                      _buildCropCarousel(),
                      const SizedBox(height: 16),

                      // Quantity & Payout Grid
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Quantity (Quintals) *', style: AppTypography.labelLarge()),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _qtyController,
                                  keyboardType: TextInputType.number,
                                  style: AppTypography.headlineSmall(color: AppColors.primary),
                                  decoration: InputDecoration(
                                    fillColor: AppColors.surfaceContainerLowest,
                                    suffixText: 'Qtl',
                                    suffixStyle: AppTypography.labelLarge(color: AppColors.onSurfaceVariant),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 4),
                                Text('1 Quintal = 100 kg (Max 500 Qtl)',
                                    style: AppTypography.labelSmall(color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Est. MSP Payout', style: AppTypography.labelLarge()),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.mintCardSurface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.mintCardBorder),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currencyFormatter.format(_estimatedPayout),
                                        style: AppTypography.headlineSmall(color: AppColors.primary).copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '100% DBT to Bank',
                                          style: AppTypography.labelSmall(color: AppColors.onPrimary).copyWith(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Section 4: Time Slot
                      _buildSectionTitle('4. Select Time / समय चुनें'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeSlotCard(
                              id: 'morning',
                              titleEn: 'Morning',
                              titleHi: 'सुबह',
                              hours: '08:00 AM - 12:00 PM',
                              icon: Icons.light_mode,
                              isFast: true,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildTimeSlotCard(
                              id: 'evening',
                              titleEn: 'Evening',
                              titleHi: 'शाम',
                              hours: '02:00 PM - 06:00 PM',
                              icon: Icons.dark_mode,
                              isFast: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Notice Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryFixed,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info, color: AppColors.primaryContainer, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estimated Load / अनुमानित भार',
                                    style: AppTypography.labelLarge(color: AppColors.onTertiaryFixed),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Please ensure your vehicle arrives 30 minutes before the slot time. Expected wait time is ~45 mins.',
                                    style: AppTypography.bodySmall(color: AppColors.onTertiaryFixedVariant),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Sticky Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border(
                top: BorderSide(color: AppColors.primaryContainer, width: 2),
              ),
            ),
            child: SafeArea(
              top: false,
              child: ElevatedButton(
                onPressed: _onConfirmBooking,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Confirm Booking / बुकिंग की पुष्टि करें',
                      style: AppTypography.headlineSmall(color: AppColors.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.headlineSmall(color: AppColors.primaryContainer),
    );
  }

  Widget _buildCalendarCard() {
    return Card(
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {},
                ),
                Text(
                  'October 2023 / अक्टूबर',
                  style: AppTypography.labelLarge(color: AppColors.onSurface),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) {
                return SizedBox(
                  width: 32,
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: AppTypography.labelMedium(color: AppColors.onSurfaceVariant),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // Days Grid
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(28, (index) {
                final day = index + 1;
                final isSelected = day == _selectedDay;
                Color dotColor = AppColors.primary;
                if (day >= 19 && day <= 20) dotColor = AppColors.error;
                if (day >= 24 && day <= 25) dotColor = AppColors.secondary;

                return InkWell(
                  onTap: () => setState(() => _selectedDay = day),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.secondaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: AppColors.secondary, width: 2) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: AppTypography.bodySmall(
                            color: isSelected ? AppColors.onSecondaryContainer : AppColors.onSurface,
                          ).copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(AppColors.primary, 'Available / उपलब्ध'),
                _buildLegendItem(AppColors.error, 'Full / पूर्ण'),
                _buildLegendItem(AppColors.secondary, 'Fast Filling / सीमित'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: AppTypography.labelSmall(color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildCropCarousel() {
    return SizedBox(
      height: 125,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: Crop.sampleCrops.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final crop = Crop.sampleCrops[index];
          final isSelected = crop.id == _selectedCrop.id;

          return InkWell(
            onTap: () => setState(() => _selectedCrop = crop),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 140,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.mintCardSurface : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                  width: isSelected ? 2.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(crop.icon, size: 32, color: AppColors.primary),
                  const SizedBox(height: 6),
                  Text(
                    crop.displayName,
                    textAlign: TextAlign.center,
                    style: AppTypography.labelMedium(
                      color: isSelected ? AppColors.primary : AppColors.onSurface,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    crop.formattedMsp,
                    style: AppTypography.labelSmall(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlotCard({
    required String id,
    required String titleEn,
    required String titleHi,
    required String hours,
    required IconData icon,
    required bool isFast,
  }) {
    final isSelected = _selectedSlot == id;

    return InkWell(
      onTap: () => setState(() => _selectedSlot = id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mintCardSurface : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.outlineVariant,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          children: [
            if (isFast)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'FAST',
                    style: AppTypography.labelSmall(color: AppColors.onSecondary).copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primaryContainer : AppColors.outline,
            ),
            const SizedBox(height: 6),
            Text(
              '$titleEn / $titleHi',
              style: AppTypography.labelLarge(
                color: isSelected ? AppColors.primaryContainer : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              hours,
              style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
