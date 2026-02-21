import 'package:flutter/material.dart';

class QuantWarningBlackRock extends StatelessWidget {
  final Map<String, dynamic> forecastData;

  const QuantWarningBlackRock({Key? key, required this.forecastData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parsing Data dari Backend
    final warningData = forecastData['quant_signal_advanced'];

    // Jika format lama (string) atau tidak ada data, jangan render widget advanced ini
    if (warningData == null || warningData is! Map) {
      return const SizedBox.shrink();
    }

    final String level = warningData['level'] ?? 'NEUTRAL';
    final String message = warningData['message'] ?? 'No significant signal';
    final String iconStr = warningData['icon'] ?? 'ℹ️';
    final String colorStr = warningData['color'] ?? 'secondary';

    // Mapping Warna Bootstrap/Backend ke Flutter
    Color getSignalColor(String colorName) {
      switch (colorName.toLowerCase()) {
        case 'danger':
          return const Color(0xFFFF3B30); // iOS Red
        case 'success':
          return const Color(0xFF34C759); // iOS Green
        case 'warning':
          return const Color(0xFFFF9500); // iOS Orange
        case 'primary':
          return const Color(0xFF007AFF); // iOS Blue
        case 'secondary':
          return Colors.grey;
        default:
          return Colors.grey;
      }
    }

    Color baseColor = getSignalColor(colorStr);

    // Secondary Warnings (jika ada)
    final List<dynamic> secondary = warningData['secondary'] ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.1), // Transparansi latar belakang
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: baseColor.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Level + Exp Return
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: baseColor.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Text(iconStr, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.toUpperCase(),
                        style: TextStyle(
                          color: baseColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.0,
                        ),
                        maxLines: 2, // Allow wrapping for long levels
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            "AI FORECAST: ",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Flexible(
                            // Prevent overflow on small screens
                            child: Text(
                              "${forecastData['expected_return_30d_%'] ?? 0}% (30 Hari)",
                              style: TextStyle(
                                color:
                                    (forecastData['expected_return_30d_%'] ??
                                            0) >=
                                        0
                                    ? const Color(0xFF34C759)
                                    : const Color(0xFFFF3B30),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Branding removed as per user request
              ],
            ),
          ),

          // Body: Pesan Utama
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Footer: Secondary Warnings (jika ada)
          if (secondary.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: baseColor.withOpacity(0.2), height: 12),
                  const SizedBox(height: 4),
                  ...secondary
                      .map(
                        (w) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.arrow_right,
                                size: 14,
                                color: baseColor.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  w.toString(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
