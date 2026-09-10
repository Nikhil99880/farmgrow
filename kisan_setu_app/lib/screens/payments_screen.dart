import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/custom_app_bar.dart';
import '../models/transaction_model.dart';

class PaymentsScreen extends StatelessWidget {
  final bool isEmbeddedInNav;

  const PaymentsScreen({
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
              title: 'My Payments / मेरे भुगतान',
              showBackButton: true,
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'My Payments / मेरे भुगतान',
                  style: AppTypography.headlineLarge(color: AppColors.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  'Track your recent crop sales and government disbursements.',
                  style: AppTypography.bodyMedium(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 20),

                // Bento Summary Cards
                _buildSummaryBentoCards(),
                const SizedBox(height: 24),

                // Transaction Feed Section
                Text(
                  'Recent Transactions / हाल के लेनदेन',
                  style: AppTypography.headlineSmall(color: AppColors.onSurface),
                ),
                const SizedBox(height: 14),

                // List of Transaction Cards
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: TransactionItem.sampleTransactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final txn = TransactionItem.sampleTransactions[index];
                    return _buildTransactionCard(context, txn);
                  },
                ),
                const SizedBox(height: 24),

                // Load more
                Center(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All transactions up to date / सभी लेनदेन अपडेट हैं')),
                      );
                    },
                    child: Text(
                      'Load More Transactions / और देखें',
                      style: AppTypography.labelLarge(color: AppColors.primary),
                    ),
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

  Widget _buildSummaryBentoCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 480;

        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          children: [
            // Received Card
            Expanded(
              flex: isWide ? 1 : 0,
              child: Container(
                width: isWide ? null : double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL RECEIVED (THIS SEASON)',
                      style: AppTypography.labelSmall(color: AppColors.primaryFixed).copyWith(
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹ 1,45,000',
                      style: AppTypography.headlineLarge(color: AppColors.onPrimary).copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'कुल प्राप्त राशि (इस मौसम में)',
                      style: AppTypography.bodySmall(color: AppColors.primaryFixedDim),
                    ),
                  ],
                ),
              ),
            ),
            if (isWide) const SizedBox(width: 14) else const SizedBox(height: 14),

            // Pending Card
            Expanded(
              flex: isWide ? 1 : 0,
              child: Container(
                width: isWide ? null : double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.secondary, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.secondary,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PENDING PROCESSING',
                      style: AppTypography.labelSmall(color: AppColors.secondary).copyWith(
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹ 32,500',
                      style: AppTypography.headlineLarge(color: AppColors.onSecondaryContainer).copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'प्रक्रिया में (लंबित)',
                      style: AppTypography.bodySmall(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransactionItem txn) {
    Color leftBarColor;
    Color iconBgColor;
    Color iconColor;
    Color badgeBg;
    Color badgeTextColor;
    String badgeText;
    IconData badgeIcon;

    switch (txn.status) {
      case PaymentStatus.completed:
        leftBarColor = AppColors.primaryContainer;
        iconBgColor = AppColors.mintCardSurface;
        iconColor = AppColors.primary;
        badgeBg = AppColors.mintCardSurface;
        badgeTextColor = AppColors.primary;
        badgeText = 'Completed';
        badgeIcon = Icons.check_circle;
        break;
      case PaymentStatus.pending:
        leftBarColor = AppColors.secondary;
        iconBgColor = AppColors.secondaryContainer;
        iconColor = AppColors.onSecondaryContainer;
        badgeBg = AppColors.secondaryContainer;
        badgeTextColor = AppColors.onSecondaryContainer;
        badgeText = 'Pending';
        badgeIcon = Icons.schedule;
        break;
      case PaymentStatus.actionRequired:
        leftBarColor = AppColors.error;
        iconBgColor = AppColors.errorContainer;
        iconColor = AppColors.error;
        badgeBg = AppColors.error;
        badgeTextColor = AppColors.onError;
        badgeText = 'Action Required';
        badgeIcon = Icons.error;
        break;
    }

    final isActionReq = txn.status == PaymentStatus.actionRequired;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: isActionReq ? AppColors.errorContainer.withOpacity(0.4) : AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isActionReq ? AppColors.error : AppColors.outlineVariant,
          width: isActionReq ? 2 : 1.5,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left color accent bar
            Container(width: 6, color: leftBarColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon circle
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: leftBarColor.withOpacity(0.5)),
                          ),
                          child: Icon(txn.icon, color: iconColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        // Title & Meta
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      txn.displayTitle,
                                      style: AppTypography.labelLarge(color: AppColors.onSurface),
                                    ),
                                  ),
                                  Text(
                                    '₹ ${txn.amount.toStringAsFixed(0)}',
                                    style: AppTypography.headlineSmall(
                                      color: isActionReq ? AppColors.error : AppColors.primary,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${txn.date} • Ref: ${txn.reference}${txn.quantity != null ? ' • Qty: ${txn.quantity}' : ''}',
                                style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Badge & Action Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: leftBarColor, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(badgeIcon, size: 14, color: badgeTextColor),
                              const SizedBox(width: 4),
                              Text(
                                badgeText,
                                style: AppTypography.labelSmall(color: badgeTextColor).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (txn.status == PaymentStatus.completed)
                          TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Downloading Receipt for ${txn.reference}...')),
                              );
                            },
                            icon: const Icon(Icons.download, size: 16),
                            label: const Text('Receipt / रसीद'),
                          )
                        else if (txn.actionPrompt != null && !isActionReq)
                          Text(
                            txn.actionPrompt!,
                            style: AppTypography.labelSmall(color: AppColors.onSurfaceVariant).copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),

                    if (isActionReq) ...[
                      const SizedBox(height: 10),
                      Text(
                        txn.actionPrompt!,
                        style: AppTypography.bodySmall(color: AppColors.error).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.onError,
                          minimumSize: const Size.fromHeight(42),
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/onboarding/dbt'),
                        child: const Text('Update Bank Details / बैंक विवरण अपडेट करें'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
