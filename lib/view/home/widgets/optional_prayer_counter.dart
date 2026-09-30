part of '../home_page.dart';

class OptionalPrayerCounter extends StatelessWidget {
  const OptionalPrayerCounter({super.key});

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.primary,
        ),
        child: Icon(icon, color: colorScheme.onPrimary, size: 24),
      ),
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    UserStateController controller,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.resetCounterDialogTitle),
        content: Text(l10n.resetCounterDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.resetCounterDialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.resetCounterDialogConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.setOptionalPrayerCounter(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userStateController = context.watch<UserStateController>();
    final counter = userStateController.currentUserState.optionalPrayerCounter;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final containerBg = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFEDF1EE);

    return Container(
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconButton(
                context: context,
                icon: Icons.remove,
                onTap: () => userStateController.decrementOptionalPrayer(),
              ),
              Text(
                '$counter',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              _buildIconButton(
                context: context,
                icon: Icons.add,
                onTap: () => userStateController.incrementOptionalPrayer(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _confirmReset(context, userStateController, l10n),
            icon: const Icon(Icons.restart_alt, size: 18),
            label: Text(l10n.resetCounter),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
