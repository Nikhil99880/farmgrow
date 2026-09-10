import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../state/app_state.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showMenuButton;
  final bool showVoiceGuide;
  final bool showLanguageSelector;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showMenuButton = false,
    this.showVoiceGuide = false,
    this.showLanguageSelector = false,
    this.onBack,
    this.onMenu,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  tooltip: 'Go back',
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                )
              else if (showMenuButton)
                IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.primary),
                  tooltip: 'Open menu',
                  onPressed: onMenu ?? () => Scaffold.of(context).openDrawer(),
                ),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.headlineMedium(color: AppColors.primary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showVoiceGuide) ...[
                AnimatedBuilder(
                  animation: AppState(),
                  builder: (context, _) {
                    final isVoiceActive = AppState().isVoiceGuideActive;
                    return InkWell(
                      onTap: () {
                        AppState().toggleVoiceGuide();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isVoiceActive
                                  ? 'Voice Guide Stopped / आवाज गाइड बंद'
                                  : 'Voice Guide Activated / आवाज गाइड शुरू हो गई',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isVoiceActive
                              ? AppColors.secondaryFixed
                              : AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.secondary,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isVoiceActive
                                  ? Icons.record_voice_over
                                  : Icons.volume_up,
                              size: 16,
                              color: AppColors.onSecondaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Voice Guide',
                              style: AppTypography.labelMedium(
                                color: AppColors.onSecondaryContainer,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
              if (showLanguageSelector) ...[
                PopupMenuButton<AppLanguage>(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.outline),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.language, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          AppState().currentLanguage.nativeLabel,
                          style: AppTypography.labelMedium(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  onSelected: (lang) => AppState().setLanguage(lang),
                  itemBuilder: (context) => AppLanguage.values.map((lang) {
                    return PopupMenuItem(
                      value: lang,
                      child: Text('${lang.nativeLabel} (${lang.englishLabel})'),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
