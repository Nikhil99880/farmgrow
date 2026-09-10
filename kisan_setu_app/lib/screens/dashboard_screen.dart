import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../state/app_state.dart';
import 'quality_check_screen.dart';
import 'payments_screen.dart';
import 'help_center_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final currentIndex = AppState().currentNavIndex;

        return Scaffold(
          backgroundColor: AppColors.surface,
          drawer: const AppDrawer(),
          appBar: CustomAppBar(
            title: 'Kisan Setu',
            showMenuButton: true,
            showVoiceGuide: true,
            showLanguageSelector: true,
          ),
          body: IndexedStack(
            index: currentIndex,
            children: const [
              DashboardHomeView(),
              QualityCheckScreen(isEmbeddedInNav: true),
              PaymentsScreen(isEmbeddedInNav: true),
              HelpCenterScreen(isEmbeddedInNav: true),
            ],
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: currentIndex,
            onTap: (index) => AppState().setNavIndex(index),
          ),
        );
      },
    );
  }
}

class DashboardHomeView extends StatelessWidget {
  const DashboardHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Queue Status Card
              _buildLiveQueueCard(context),
              const SizedBox(height: 24),

              // Main Actions Grid (2x2)
              _buildActionGrid(context),
              const SizedBox(height: 24),

              // Recent Activity Section
              _buildRecentActivity(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveQueueCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryContainer, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Queue Status',
                      style: AppTypography.headlineSmall(color: AppColors.primaryFixed),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'कतार की स्थिति • Sonipat Mandi',
                      style: AppTypography.bodySmall(color: AppColors.primaryFixedDim),
                    ),
                  ],
                ),
                const Icon(
                  Icons.timer,
                  size: 36,
                  color: AppColors.secondaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Queue progress box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${AppState().queueAheadCount}',
                        style: AppTypography.headlineLarge(color: AppColors.secondaryFixed).copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'people ahead / लोग आगे',
                        style: AppTypography.labelLarge(color: AppColors.primaryFixed),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Thick high-contrast progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 12,
                      color: AppColors.primaryContainer,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: Container(color: AppColors.secondaryContainer),
                          ),
                          const Expanded(
                            flex: 3,
                            child: SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Est. Wait: ${AppState().queueWaitTime} / अनुमानित समय',
                      style: AppTypography.labelMedium(color: AppColors.primaryFixed),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;

        return GridView.count(
          crossAxisCount: isWide ? 2 : 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: isWide ? 2.2 : 3.2,
          children: [
            _buildActionTile(
              context: context,
              icon: Icons.calendar_add_on,
              titleEn: 'Book Slot',
              titleHi: 'स्लॉट बुक करें',
              onTap: () => Navigator.pushNamed(context, '/book-slot'),
            ),
            _buildActionTile(
              context: context,
              icon: Icons.local_shipping,
              titleEn: 'Track Order',
              titleHi: 'ऑर्डर ट्रैक करें',
              onTap: () => Navigator.pushNamed(context, '/track'),
            ),
            _buildActionTile(
              context: context,
              icon: Icons.account_balance_wallet,
              titleEn: 'My Payments',
              titleHi: 'मेरे भुगतान',
              onTap: () => Navigator.pushNamed(context, '/payments'),
            ),
            _buildActionTile(
              context: context,
              icon: Icons.groups,
              titleEn: 'Queue History',
              titleHi: 'कतार इतिहास',
              onTap: () => Navigator.pushNamed(context, '/mandi-token'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String titleEn,
    required String titleHi,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.surfaceBright,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outlineVariant, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleEn,
                      style: AppTypography.headlineSmall(color: AppColors.primary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      titleHi,
                      style: AppTypography.bodyMedium(color: AppColors.onSurface).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 8),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.secondaryContainer, width: 4),
            ),
          ),
          child: Text(
            'Recent Activity / हाल की गतिविधि',
            style: AppTypography.headlineSmall(color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.mintCardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.mintCardBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppColors.onPrimary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wheat Sale Complete',
                      style: AppTypography.labelLarge(color: AppColors.onTertiaryFixedVariant),
                    ),
                    Text(
                      'Today, 10:30 AM • Ref: #8901B',
                      style: AppTypography.bodySmall(color: AppColors.onTertiaryFixedVariant),
                    ),
                  ],
                ),
              ),
              Text(
                '₹15,400',
                style: AppTypography.headlineSmall(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
