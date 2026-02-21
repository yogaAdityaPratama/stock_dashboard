import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModeToggle extends StatelessWidget {
  final bool isAutoMode;
  final ValueChanged<bool> onChanged;

  const ModeToggle({
    super.key,
    required this.isAutoMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAutoMode
              ? const Color(0xFFC800FF).withValues(alpha: 0.3)
              : const Color(0xFF48CAE4).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: (isAutoMode ? const Color(0xFFC800FF) : const Color(0xFF48CAE4))
                .withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(
            label: 'AUTO',
            icon: Icons.auto_awesome_rounded,
            isSelected: isAutoMode,
            color: const Color(0xFFC800FF),
            onTap: () => onChanged(true),
          ),
          _buildOption(
            label: 'MANUAL',
            icon: Icons.tune_rounded,
            isSelected: !isAutoMode,
            color: const Color(0xFF48CAE4),
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : Colors.white38,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : Colors.white38,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
