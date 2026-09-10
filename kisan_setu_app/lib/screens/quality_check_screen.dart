import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/vertical_stepper.dart';

class QualityCheckScreen extends StatelessWidget {
  final bool isEmbeddedInNav;

  const QualityCheckScreen({
    super.key,
    this.isEmbeddedInNav = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isEmbeddedInNav
          ? null
          : const CustomAppBar(
              title: 'Track Procurement / ट्रैकिंग',
              showBackButton: true,
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Track Lot #8902A',
                  style: AppTypography.headlineLarge(color: AppColors.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  'Wheat Procurement • Center: Sonipat-Mandi',
                  style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 20),

                // Active Stage Card
                Card(
                  clipBehavior: Clip.antiAlias,
                  color: AppColors.surfaceBright,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      // Yellow Active Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryContainer,
                          border: Border(
                            bottom: BorderSide(color: AppColors.secondary, width: 2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.science, color: AppColors.onSecondaryContainer, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Moisture & Quality Test / गुणवत्ता जांच',
                                    style: AppTypography.headlineSmall(color: AppColors.onSecondaryContainer),
                                  ),
                                  Text(
                                    'Testing in Progress / जांच चल रही है',
                                    style: AppTypography.labelSmall(color: AppColors.onSecondaryContainer),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Active',
                                    style: AppTypography.labelSmall(color: AppColors.onSecondaryContainer).copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Metrics Body
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMetricTile(
                                    label: 'Moisture Level',
                                    value: '12.5%',
                                    target: 'Target: <14%',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildMetricTile(
                                    label: 'Foreign Matter',
                                    value: '0.8%',
                                    target: 'Target: <2%',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info, size: 20, color: AppColors.secondary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Your crop is currently being tested for moisture and foreign matter content.\nआपकी फसल की गुणवत्ता जांच की जा रही है।',
                                      style: AppTypography.bodySmall(color: AppColors.onSurface),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                _showQualityReportModal(context);
                              },
                              icon: const Icon(Icons.description, size: 18),
                              label: const Text('View Quality Report / रिपोर्ट देखें'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Lifecycle Stepper Card
                Card(
                  color: AppColors.surfaceBright,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Crop Lifecycle / फसल चक्र',
                          style: AppTypography.headlineSmall(color: AppColors.onSurface),
                        ),
                        const SizedBox(height: 20),
                        const VerticalProgressStepper(
                          steps: [
                            StepperItemData(
                              title: 'Slot Booked / स्लॉट बुक',
                              subtitle: 'Completed • 12 Oct, 08:15 AM',
                              state: StepState.completed,
                            ),
                            StepperItemData(
                              title: 'Gate Entry / गेट एंट्री',
                              subtitle: 'Completed • Token #42 Scanned',
                              state: StepState.completed,
                            ),
                            StepperItemData(
                              title: 'Quality Check & Lab Testing / गुणवत्ता जांच',
                              subtitle: 'In Progress • Lab Room 2',
                              state: StepState.active,
                              icon: Icons.science,
                            ),
                            StepperItemData(
                              title: 'Weighing & Bagging / वजन और भराई',
                              subtitle: 'Pending Weighbridge Allocation',
                              state: StepState.pending,
                              icon: Icons.scale,
                            ),
                            StepperItemData(
                              title: 'Receipt Generation / रसीद',
                              subtitle: 'Pending Weighment Slip',
                              state: StepState.pending,
                              icon: Icons.receipt_long,
                            ),
                            StepperItemData(
                              title: 'Payment Disbursement / भुगतान',
                              subtitle: 'Pending 100% DBT Transfer',
                              state: StepState.pending,
                              icon: Icons.payments,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Call Support Button
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Connecting to Mandi Helpdesk: 1800-180-1551...')),
                    );
                  },
                  icon: const Icon(Icons.call, color: AppColors.primary),
                  label: Text(
                    'Call Center Support / सहायता केंद्र',
                    style: AppTypography.labelLarge(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String target,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSmall(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.headlineSmall(color: AppColors.primary).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            target,
            style: AppTypography.labelSmall(color: AppColors.secondary).copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _showQualityReportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.surfaceContainerLowest,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lab Quality Report', style: AppTypography.headlineSmall(color: AppColors.primary)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              _buildReportItem('Sample ID', 'SMP-8902-WHT'),
              _buildReportItem('Grain Moisture', '12.5% (Grade A - Pass)'),
              _buildReportItem('Foreign Matter', '0.8% (Allowed <2.0%)'),
              _buildReportItem('Damaged Grains', '1.1% (Allowed <3.0%)'),
              _buildReportItem('Quality Certification', 'GOV-FCI-CERT-OK'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close / बंद करें'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportItem(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant)),
          Text(val, style: AppTypography.labelLarge(color: AppColors.primary)),
        ],
      ),
    );
  }
}
