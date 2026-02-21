import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimeframeSelector extends StatelessWidget {
  final String selectedTimeframe;
  final ValueChanged<String> onChanged;

  const TimeframeSelector({
    super.key,
    required this.selectedTimeframe,
    required this.onChanged,
  });

  static const List<String> timeframes = [
    'Daily',
    'Weekly',
    'Monthly',
    '6-Monthly',
    'Year',
    'Long Term',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: timeframes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tf = timeframes[index];
          final isSelected = tf == selectedTimeframe;
          return _buildChip(tf, isSelected);
        },
      ),
    );
  }

  Widget _buildChip(String timeframe, bool isSelected) {
    final Color accentColor = _getTimeframeColor(timeframe);
    
    return GestureDetector(
      onTap: () => onChanged(timeframe),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.3),
                    accentColor.withValues(alpha: 0.1),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getTimeframeIcon(timeframe),
              size: 14,
              color: isSelected ? accentColor : Colors.white38,
            ),
            const SizedBox(width: 6),
            Text(
              timeframe,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTimeframeColor(String timeframe) {
    switch (timeframe) {
      case 'Daily':
        return const Color(0xFFFF6B6B);
      case 'Weekly':
        return const Color(0xFFFFE66D);
      case 'Monthly':
        return const Color(0xFF4ECDC4);
      case '6-Monthly':
        return const Color(0xFF48CAE4);
      case 'Year':
        return const Color(0xFFC800FF);
      case 'Long Term':
        return const Color(0xFF6C5CE7);
      default:
        return const Color(0xFF48CAE4);
    }
  }

  IconData _getTimeframeIcon(String timeframe) {
    switch (timeframe) {
      case 'Daily':
        return Icons.today_rounded;
      case 'Weekly':
        return Icons.view_week_rounded;
      case 'Monthly':
        return Icons.calendar_month_rounded;
      case '6-Monthly':
        return Icons.calendar_view_month_rounded;
      case 'Year':
        return Icons.calendar_today_rounded;
      case 'Long Term':
        return Icons.trending_up_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }
}
