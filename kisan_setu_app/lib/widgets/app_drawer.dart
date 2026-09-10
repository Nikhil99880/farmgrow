import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../state/app_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // User Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                border: Border(
                  bottom: BorderSide(color: AppColors.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'RS',
                      style: AppTypography.headlineMedium(
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppState().farmerName,
                          style: AppTypography.headlineSmall(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: ${AppState().farmerId} | ${AppState().village}',
                          style: AppTypography.bodySmall(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.agriculture,
                    title: 'My Farm / मेरा खेत',
                    onTap: () {
                      Navigator.pop(context);
                      AppState().setNavIndex(0);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.analytics,
                    title: 'Track / ट्रैक करें',
                    onTap: () {
                      Navigator.pop(context);
                      AppState().setNavIndex(1);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.payments,
                    title: 'Payments / भुगतान',
                    onTap: () {
                      Navigator.pop(context);
                      AppState().setNavIndex(2);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.cloud,
                    title: 'Weather / मौसम',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Weather: 28°C, Clear Sky • Sonipat Hub'),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.trending_up,
                    title: 'Market Rates / मंडी भाव',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Wheat MSP: ₹2,425/Qtl • Mustard: ₹5,950/Qtl'),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.support_agent,
                    title: 'Support / सहायता',
                    onTap: () {
                      Navigator.pop(context);
                      AppState().setNavIndex(3);
                    },
                  ),
                ],
              ),
            ),

            // Footer
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  AppState().logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: Text(
                  'Logout / लॉगआउट',
                  style: AppTypography.labelLarge(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: AppTypography.labelLarge(color: AppColors.onSurface),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}
