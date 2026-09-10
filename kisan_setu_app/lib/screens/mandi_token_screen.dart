import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/qr_code_widget.dart';
import '../state/app_state.dart';

class MandiTokenScreen extends StatelessWidget {
  const MandiTokenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = AppState().currentBooking;
    final dateFormatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Confirmation / पुष्टि',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                // Success Badge
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 44,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Booking Confirmed',
                  style: AppTypography.headlineLarge(color: AppColors.primary),
                ),
                Text(
                  'बुकिंग पक्की हो गई',
                  style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 24),

                // Token Card
                Card(
                  clipBehavior: Clip.antiAlias,
                  color: AppColors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      // Deep Green Top Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: AppColors.primary,
                        child: Column(
                          children: [
                            Text(
                              'TOKEN NUMBER / टोकन नंबर',
                              style: AppTypography.labelMedium(color: AppColors.onPrimary).copyWith(
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              booking.tokenNumber,
                              style: AppTypography.headlineLarge(color: AppColors.onPrimary).copyWith(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // QR & Details Section
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // QR Code
                            HighContrastQrCode(
                              data: 'KISAN_SETU_TOKEN_${booking.tokenNumber}_${booking.farmerId}_LOT_${booking.lotNumber}',
                              size: 190,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Scan at Mandi Gate\nमंडी गेट पर स्कैन करें',
                              textAlign: TextAlign.center,
                              style: AppTypography.labelMedium(color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 12),

                            // Details
                            _buildDetailRow('Farmer Name / किसान का नाम', booking.farmerName),
                            _buildDetailRow('Mandi Center / मंडी केंद्र', booking.centerName),
                            _buildDetailRow('Crop & Qty / फसल व मात्रा', '${booking.crop.nameEn} (${booking.quantityQuintals.toStringAsFixed(0)} Qtl)'),
                            _buildDetailRow('Date / तारीख', dateFormatter.format(booking.date)),
                            _buildDetailRow('Time Slot / समय', booking.timeSlotHours, isLast: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Offline Notice Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondaryFixed, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off, color: AppColors.onSecondaryContainer, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'This token works without internet.',
                              style: AppTypography.bodyMedium(color: AppColors.onSecondaryContainer).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'यह टोकन बिना इंटरनेट के भी काम करेगा।',
                              style: AppTypography.bodySmall(color: AppColors.onSecondaryContainer),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Token PDF saved to device / टोकन डाउनलोड हो गया')),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.download, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Download Token / टोकन डाउनलोड करें',
                        style: AppTypography.labelLarge(color: AppColors.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
                  },
                  child: Text(
                    'Back to Dashboard / मुख्य पृष्ठ पर जाएं',
                    style: AppTypography.labelLarge(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.labelMedium(color: AppColors.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTypography.bodyLarge(color: AppColors.primary).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
