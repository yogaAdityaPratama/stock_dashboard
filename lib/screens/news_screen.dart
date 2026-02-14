import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgGradientStart = Color(0xFF1A0A2E);
    const bgGradientEnd = Color(0xFF0A0214);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Market News',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgGradientStart, bgGradientEnd],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeadlineNews(),
              const SizedBox(height: 24),
              _buildNewsSectionTitle('Top Stories'),
              const SizedBox(height: 12),
              _buildNewsItem(
                context,
                'IHSG Menguat ke Level 7.300 di Tengah Optimisme Pasar Global',
                'Ekonomi',
                '10 mins ago',
              ),
              _buildNewsItem(
                context,
                'Saham Sektor Teknologi Pimpin Kenaikan di Sesi Pertama',
                'Saham',
                '25 mins ago',
              ),
              _buildNewsItem(
                context,
                'Inflasi AS Lebih Rendah dari Ekspektasi, Sinyal Positif bagi Suku Bunga',
                'Global',
                '1 hour ago',
              ),
              _buildNewsItem(
                context,
                'Initial Public Offering (IPO) Perusahaan AI Lokal Menarik Minat Investor Retail',
                'IPO',
                '2 hours ago',
              ),
              _buildNewsItem(
                context,
                'Bank Indonesia Pertahankan Suku Bunga Acuan di Angka 6%',
                'Perbankan',
                '4 hours ago',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeadlineNews() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('asset/bg.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'BREAKING',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Analisa AI: 5 Saham dengan Potensi Multibagger di Sektor Renewable Energy',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Berdasarkan pengolahan data AI StockID...',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNewsItem(
    BuildContext context,
    String title,
    String tag,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tag.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFC800FF),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Text('•', style: TextStyle(color: Colors.white24)),
              const SizedBox(width: 8),
              Text(
                time,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
