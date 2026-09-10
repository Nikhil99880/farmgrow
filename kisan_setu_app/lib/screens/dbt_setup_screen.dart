import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/custom_app_bar.dart';
import '../state/app_state.dart';

class DbtSetupScreen extends StatefulWidget {
  const DbtSetupScreen({super.key});

  @override
  State<DbtSetupScreen> createState() => _DbtSetupScreenState();
}

class _DbtSetupScreenState extends State<DbtSetupScreen> {
  final TextEditingController _bankNameController = TextEditingController(text: 'State Bank of India');
  final TextEditingController _accountController = TextEditingController(text: '341256789012');
  final TextEditingController _ifscController = TextEditingController(text: 'SBIN0001234');
  bool _obscureAccount = true;
  bool _dbtEnabled = true;

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  void _onCompleteSetup() {
    AppState().setDbtEnabled(_dbtEnabled);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.primary,
        content: Text('Bank Details & DBT Setup Completed Successfully!'),
      ),
    );
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Bank Details / बैंक विवरण',
        showBackButton: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Aadhaar Verified Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mintCardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(
                      left: BorderSide(color: AppColors.primary, width: 4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aadhaar Verified / आधार सत्यापित',
                              style: AppTypography.headlineSmall(color: AppColors.primary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your Aadhaar ending in **3942 has been successfully linked. Please confirm your bank details below for Direct Benefit Transfer (DBT).',
                              style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Form Card
                Card(
                  color: AppColors.surfaceContainerLowest,
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
                          'Primary Account Details / खाता विवरण',
                          style: AppTypography.headlineSmall(color: AppColors.onSurface),
                        ),
                        const SizedBox(height: 16),

                        // Bank Name
                        Text('Bank Name / बैंक का नाम', style: AppTypography.labelLarge()),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _bankNameController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            fillColor: AppColors.surfaceContainerLow,
                            suffixIcon: Icon(Icons.lock_outline, color: AppColors.outline),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Fetched automatically from Aadhaar NPCI mapper',
                            style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 16),

                        // Account Number
                        Text('Account Number / खाता संख्या', style: AppTypography.labelLarge()),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _accountController,
                          obscureText: _obscureAccount,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureAccount ? Icons.visibility_off : Icons.visibility,
                                color: AppColors.outline,
                              ),
                              onPressed: () => setState(() => _obscureAccount = !_obscureAccount),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Ensure this matches your bank passbook',
                            style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 16),

                        // IFSC
                        Text('IFSC Code / आईएफएससी कोड', style: AppTypography.labelLarge()),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _ifscController,
                          textCapitalization: TextCapitalization.characters,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Enable DBT Switch Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Enable DBT Link / डीबीटी सक्षम करें',
                              style: AppTypography.headlineSmall(color: AppColors.onSurface),
                            ),
                          ),
                          Switch(
                            value: _dbtEnabled,
                            activeColor: AppColors.primary,
                            onChanged: (val) => setState(() => _dbtEnabled = val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'I consent to receiving government subsidies and MSP sales payouts directly to this bank account via Aadhaar linkage.',
                        style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Complete CTA Button
                ElevatedButton(
                  onPressed: _onCompleteSetup,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_user, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Complete Setup / सेटअप पूरा करें',
                        style: AppTypography.labelLarge(color: AppColors.onPrimaryContainer),
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
