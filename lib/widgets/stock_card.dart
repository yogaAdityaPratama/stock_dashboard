import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget Kartu Saham yang Reusable (Dapat digunakan kembali)
///
/// Widget ini menampilkan informasi ringkas saham termasuk:
/// - Kode Saham (Ticker)
/// - Nama Perusahaan
/// - Harga Terkini (Format Rupiah)
/// - Perubahan Harga (Persentase)
/// - Logo Perusahaan
///
/// Mengikuti prinsip Clean Code dan OOP untuk enkapsulasi UI.
class StockCard extends StatelessWidget {
  final String code;
  final String name;
  final double price;
  final double changePercentage;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const StockCard({
    super.key,
    required this.code,
    required this.name,
    required this.price,
    required this.changePercentage,
    this.onTap,
    this.onLongPress,
  });

  /// Factory constructor untuk membuat StockCard dari Map dinamis
  /// Berguna ketika data berasal dari JSON/API yang belum dimodelkan secara ketat.
  factory StockCard.fromMap(
    Map<String, dynamic> data, {
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return StockCard(
      code: data['code']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      // Konversi aman ke double untuk harga dan perubahan
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      changePercentage: (data['change'] as num?)?.toDouble() ?? 0.0,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isPositive = changePercentage >= 0;
    // Warna hijau terang untuk positif, merah untuk negatif
    final Color trendColor = isPositive
        ? const Color(0xFF39FF14)
        : Colors.redAccent;

    // Formatter untuk mata uang Indonesia (Rp 1.000.000)
    // Menggunakan locale 'id_ID' untuk pemisah ribuan titik
    final NumberFormat priceFormatter = NumberFormat('#,##0', 'id_ID');
    final String formattedPrice = priceFormatter
        .format(price)
        .replaceAll(',', '.');

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          // Gradient halus untuk memberikan kesan modern dan premium
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.06),
              Colors.white.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Bagian Kiri: Kode Saham dan Nama Perusahaan
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: GoogleFonts.robotoMono(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Bagian Tengah-Kanan: Harga dan Perubahan
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp $formattedPrice',
                    style: GoogleFonts.robotoMono(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Icons.arrow_drop_up_rounded
                            : Icons.arrow_drop_down_rounded,
                        color: trendColor,
                        size: 18,
                      ),
                      Text(
                        '${changePercentage.toStringAsFixed(2)}%',
                        style: GoogleFonts.robotoMono(
                          color: trendColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bagian Kanan Jauh: Logo Perusahaan
            const SizedBox(width: 12),
            _buildCompanyLogo(trendColor),
          ],
        ),
      ),
    );
  }

  /// Membangun widget logo perusahaan dengan fallback yang kuat
  Widget _buildCompanyLogo(Color trendColor) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'asset/logos/$code.png', // Mencoba memuat dari aset lokal
          fit: BoxFit.cover,
          errorBuilder: (context, assetError, assetStack) {
            // Jika aset lokal gagal, coba ambil dari jaringan
            return CachedNetworkImage(
              imageUrl: 'https://assets.stockbit.com/logos/companies/$code.png',
              fit: BoxFit.cover,
              // Placeholder saat memuat
              placeholder: (context, url) => Container(
                color: Colors.white.withValues(alpha: 0.05),
                child: const Center(
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
              // Widget fallback jika gambar jaringan juga gagal (menampilkan inisial)
              errorWidget: (context, url, error) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        trendColor.withValues(alpha: 0.2),
                        trendColor.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      code.length >= 2
                          ? code.substring(0, 2).toUpperCase()
                          : code.toUpperCase(),
                      style: GoogleFonts.robotoMono(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
