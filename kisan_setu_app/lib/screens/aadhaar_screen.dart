import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/vertical_stepper.dart';
import '../state/app_state.dart';

class AadhaarScreen extends StatefulWidget {
  const AadhaarScreen({super.key});

  @override
  State<AadhaarScreen> createState() => _AadhaarScreenState();
}

class _AadhaarScreenState extends State<AadhaarScreen> {
  final TextEditingController _aadhaarController = TextEditingController(text: '2345 6789 3942');
  bool _consentGiven = true;

  @override
  void dispose() {
    _aadhaarController.dispose();
    super.dispose();
  }

  void _onVerify() {
    if (!_consentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the DBT consent to proceed')),
      );
      return;
    }
    AppState().linkAadhaar(_aadhaarController.text);
    Navigator.pushNamed(context, '/onboarding/dbt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Kisan Setu',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Getting Started / शुरू करें',
                  style: AppTypography.headlineLarge(color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete these steps to access all services.',
                  style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 20),

                // Onboarding Stepper Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: const VerticalProgressStepper(
                    steps: [
                      StepperItemData(
                        title: '1. Profile Setup',
                        subtitle: 'Completed',
                        state: StepState.completed,
                      ),
                      StepperItemData(
                        title: '2. Aadhaar Linking',
                        subtitle: 'Current Step',
                        state: StepState.active,
                        icon: Icons.fingerprint,
                      ),
                      StepperItemData(
                        title: '3. Land Details',
                        state: StepState.pending,
                      ),
                      StepperItemData(
                        title: '4. Bank Account for DBT',
                        state: StepState.pending,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Active Action Card
                Card(
                  clipBehavior: Clip.antiAlias,
                  color: AppColors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Green Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: AppColors.primary,
                        child: Row(
                          children: [
                            const Icon(Icons.fingerprint, color: AppColors.onPrimary, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Step 2: Link Aadhaar',
                              style: AppTypography.headlineSmall(color: AppColors.onPrimary),
                            ),
                          ],
                        ),
                      ),

                      // Body
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '12-Digit Aadhaar Number / आधार संख्या',
                              style: AppTypography.labelLarge(color: AppColors.onSurface),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _aadhaarController,
                              keyboardType: TextInputType.number,
                              maxLength: 14,
                              style: AppTypography.bodyLarge(color: AppColors.onSurface),
                              decoration: const InputDecoration(
                                counterText: '',
                                suffixIcon: Icon(Icons.lock, color: AppColors.outline),
                                hintText: 'XXXX XXXX XXXX',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your data is secured and encrypted with UIDAI.',
                              style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 16),

                            // Consent Checkbox
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _consentGiven,
                                  activeColor: AppColors.primary,
                                  onChanged: (val) => setState(() => _consentGiven = val ?? false),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'I hereby give my consent to Kisan Setu to use my Aadhaar details for verification and direct benefit transfers (DBT) as per the government guidelines.',
                                      style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Button
                            ElevatedButton(
                              onPressed: _onVerify,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.how_to_reg, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Verify via Face/OTP / सत्यापित करें',
                                    style: AppTypography.labelLarge(color: AppColors.onPrimaryContainer),
                                  ),
                                ],
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
          ),
        ),
      ),
    );
  }
}
