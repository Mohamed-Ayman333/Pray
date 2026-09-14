part of '../home_page.dart';

class ViewSwitcher extends StatelessWidget {
  final bool isDayViewSelected;
  final Function(bool) onViewChanged;

  const ViewSwitcher({
    super.key,
    required this.isDayViewSelected,
    required this.onViewChanged,
  });

  Widget _buildButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedBg = isDark ? const Color(0xFF334155) : Colors.white;

    return Expanded(
      child: GestureDetector(
        onTap: () => onViewChanged(label == 'Day View'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFEDF1EE);

    return Container(
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildButton(
            context: context,
            icon: Icons.calendar_today_outlined,
            label: 'Day View',
            isSelected: isDayViewSelected,
          ),
          _buildButton(
            context: context,
            icon: Icons.grid_view_outlined,
            label: '30-Day View',
            isSelected: !isDayViewSelected,
          ),
        ],
      ),
    );
  }
}
